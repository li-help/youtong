package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.youtong.common.JwtUtil;
import com.youtong.common.PasswordEncoder;
import com.youtong.common.R;
import com.youtong.common.ScanLoginManager;
import com.youtong.entity.SysAccount;
import com.youtong.service.SmsCodeService;
import com.youtong.service.SysAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private SysAccountService accountService;

    @Autowired
    private ScanLoginManager scanLoginManager;

    @Autowired
    private SmsCodeService smsCodeService;

    @Value("${wechat.miniapp.appid}")
    private String wxAppid;

    @Value("${wechat.miniapp.secret}")
    private String wxSecret;

    @Value("${wechat.miniapp.scan-page}")
    private String wxScanPage;

    // 微信接口返回 Content-Type 为 text/plain 而非 application/json，
    // 默认的 Jackson 转换器只认 application/json，会导致解析失败。
    // 这里构造一个额外支持 text/plain 的 RestTemplate。
    private final RestTemplate restTemplate = buildTextPlainRestTemplate();

    private static RestTemplate buildTextPlainRestTemplate() {
        RestTemplate template = new RestTemplate();
        for (var converter : new ArrayList<>(template.getMessageConverters())) {
            if (converter instanceof MappingJackson2HttpMessageConverter jackson) {
                List<MediaType> types = new ArrayList<>(jackson.getSupportedMediaTypes());
                if (!types.contains(MediaType.TEXT_PLAIN)) {
                    types.add(MediaType.TEXT_PLAIN);
                }
                jackson.setSupportedMediaTypes(types);
            }
        }
        return template;
    }

    // 微信全局 access_token 缓存（2 小时有效，提前 1 分钟刷新）
    private volatile String wxAccessToken;
    private volatile long wxAccessTokenExpireAt;

    /**
     * 调用微信 jscode2session 接口，用 code 换取 openid
     */
    private String getOpenidByCode(String code) {
        String url = UriComponentsBuilder
                .fromHttpUrl("https://api.weixin.qq.com/sns/jscode2session")
                .queryParam("appid", wxAppid)
                .queryParam("secret", wxSecret)
                .queryParam("js_code", code)
                .queryParam("grant_type", "authorization_code")
                .toUriString();
        @SuppressWarnings("unchecked")
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) {
            throw new RuntimeException("微信接口无响应");
        }
        Object errcode = res.get("errcode");
        if (errcode != null && !Integer.valueOf(0).equals(errcode)) {
            String errmsg = (String) res.getOrDefault("errmsg", "未知错误");
            throw new RuntimeException("微信接口错误：" + errmsg);
        }
        Object openid = res.get("openid");
        if (openid == null || openid.toString().isBlank()) {
            throw new RuntimeException("未获取到微信 openid");
        }
        return openid.toString();
    }

    /**
     * 获取微信全局 access_token（有效期 2 小时），带内存缓存，提前 1 分钟刷新。
     * 该凭证用于生成小程序码等需要服务端身份的接口。
     */
    private synchronized String getWxAccessToken() {
        long now = System.currentTimeMillis();
        if (wxAccessToken != null && now < wxAccessTokenExpireAt - 60_000) {
            return wxAccessToken;
        }
        String url = UriComponentsBuilder
                .fromHttpUrl("https://api.weixin.qq.com/cgi-bin/token")
                .queryParam("grant_type", "client_credential")
                .queryParam("appid", wxAppid)
                .queryParam("secret", wxSecret)
                .toUriString();
        @SuppressWarnings("unchecked")
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) {
            throw new RuntimeException("微信接口无响应");
        }
        Object errcode = res.get("errcode");
        if (errcode != null && !Integer.valueOf(0).equals(errcode)) {
            throw new RuntimeException("微信接口错误：" + res.getOrDefault("errmsg", "未知错误"));
        }
        Object token = res.get("access_token");
        if (token == null || token.toString().isBlank()) {
            throw new RuntimeException("未获取到微信 access_token");
        }
        Object expiresIn = res.get("expires_in");
        long expires = expiresIn instanceof Number ? ((Number) expiresIn).longValue() : 7200L;
        wxAccessToken = token.toString();
        wxAccessTokenExpireAt = now + expires * 1000L;
        return wxAccessToken;
    }

    @PostMapping("/login")
    public R login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || password == null) {
            return R.fail("用户名和密码不能为空");
        }
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", username));
        boolean passwordOk = false;
        try {
            passwordOk = account != null && PasswordEncoder.matches(password, account.getPassword());
        } catch (IllegalArgumentException e) {
            // 库中密码非合法 BCrypt 密文（如手动改库），按密码错误处理
            passwordOk = false;
        }
        if (account == null || !passwordOk) {
            return R.fail("用户名或密码错误");
        }
        if (account.getStatus() != null && account.getStatus() == 0) {
            return R.fail("账号已被禁用");
        }
        String token = JwtUtil.generate(account.getUsername(), account.getRole());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        Map<String, Object> user = new HashMap<>();
        user.put("id", account.getId());
        user.put("username", account.getUsername());
        user.put("nickname", account.getNickname());
        user.put("role", account.getRole());
        result.put("user", user);
        return R.ok(result);
    }

    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");

    @PostMapping("/register")
    public R register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        String code = body.get("code");
        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            return R.fail("用户名和密码不能为空");
        }
        if (!PHONE_PATTERN.matcher(username).matches()) {
            return R.fail("请输入有效的手机号");
        }
        if (password.length() < 6) {
            return R.fail("密码长度不能少于6位");
        }
        if (!smsCodeService.verify(username, code)) {
            return R.fail("验证码错误或已过期");
        }
        if (accountService.count(new QueryWrapper<SysAccount>().eq("username", username)) > 0) {
            return R.fail("该手机号已注册");
        }
        SysAccount account = new SysAccount();
        account.setUsername(username);
        account.setPassword(PasswordEncoder.encode(password));
        account.setNickname("用户" + username.substring(username.length() - 4));
        account.setRole("user");
        account.setStatus(1);
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        account.setCreatedAt(now);
        account.setUpdatedAt(now);
        accountService.save(account);
        return R.ok("注册成功");
    }

    /**
     * 发送短信验证码（注册 / 忘记密码共用）。
     * 演示环境（未配置短信网关）直接返回验证码，便于前端提示；
     * 正式环境经阿里云下发短信，不返回明文（code 字段为 null）。
     */
    @PostMapping("/sendCode")
    public R sendCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        if (phone == null || phone.isBlank()) {
            return R.fail("请输入手机号");
        }
        if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            return R.fail("请输入有效的手机号");
        }
        String code = smsCodeService.send(phone.trim());
        Map<String, Object> result = new HashMap<>();
        result.put("phone", phone.trim());
        // 仅演示模式返回明文；正式环境返回 null（验证码已通过短信下发）
        result.put("code", code);
        result.put("demo", code != null);
        result.put("expireSeconds", SmsCodeService.EXPIRE_MS / 1000);
        return R.ok(result);
    }

    /** 校验验证码是否正确（供忘记密码流程第一步使用） */
    @PostMapping("/checkCode")
    public R checkCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");
        if (phone == null || code == null || phone.isBlank() || code.isBlank()) {
            return R.fail("手机号和验证码不能为空");
        }
        if (!smsCodeService.verify(phone.trim(), code)) {
            return R.fail("验证码错误或已过期");
        }
        return R.ok();
    }

    /**
     * 通过手机号 + 验证码重置密码（忘记密码场景，无需原密码）。
     */
    @PostMapping("/resetPwdByCode")
    public R resetPwdByCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");
        String newPassword = body.get("newPassword");
        if (phone == null || phone.isBlank()) {
            return R.fail("请输入手机号");
        }
        if (code == null || code.isBlank()) {
            return R.fail("请输入验证码");
        }
        if (newPassword == null || newPassword.isBlank()) {
            return R.fail("请输入新密码");
        }
        if (newPassword.length() < 6) {
            return R.fail("新密码至少 6 位");
        }
        if (!smsCodeService.verify(phone.trim(), code)) {
            return R.fail("验证码错误或已过期");
        }
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", phone.trim()));
        if (account == null) {
            return R.fail("该手机号尚未注册");
        }
        account.setPassword(PasswordEncoder.encode(newPassword));
        accountService.updateById(account);
        return R.ok("密码重置成功");
    }

    @PostMapping("/logout")
    public R logout() {
        // JWT 为无状态令牌，服务端无需维护会话；前端删除本地 token 即可
        return R.ok();
    }

    /**
     * 手机号 + 验证码登录（C 端免密登录）。
     * 验证码正确即可登录：已注册用户直接登录；未注册用户自动注册后登录。
     * 用于"验证码登录"入口，与账号密码登录、微信登录并列。
     */
    @PostMapping("/phoneLogin")
    public R phoneLogin(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");
        if (phone == null || phone.isBlank() || code == null || code.isBlank()) {
            return R.fail("手机号和验证码不能为空");
        }
        if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            return R.fail("请输入有效的手机号");
        }
        if (!smsCodeService.verify(phone.trim(), code)) {
            return R.fail("验证码错误或已过期");
        }
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", phone.trim()));
        if (account == null) {
            // 未注册则自动注册（默认昵称取手机号后 4 位），验证码登录即注册
            account = new SysAccount();
            account.setUsername(phone.trim());
            // 密码字段必填但用户未设置，用 openid 兜底加密（与微信自动注册一致）
            account.setPassword(PasswordEncoder.encode(phone.trim()));
            account.setNickname("用户" + phone.trim().substring(phone.trim().length() - 4));
            account.setPhone(phone.trim());
            account.setRole("user");
            account.setStatus(1);
            String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            account.setCreatedAt(now);
            account.setUpdatedAt(now);
            accountService.save(account);
        }
        if (account.getStatus() != null && account.getStatus() == 0) {
            return R.fail("账号已被禁用");
        }
        String token = JwtUtil.generate(account.getUsername(), account.getRole());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        Map<String, Object> user = new HashMap<>();
        user.put("id", account.getId());
        user.put("username", account.getUsername());
        user.put("nickname", account.getNickname());
        user.put("role", account.getRole());
        result.put("user", user);
        return R.ok(result);
    }

    /**
     * 重置密码：通过"原密码 + 新密码"校验后修改（账号密码登录场景）。
     * 验证码重置需短信服务，此处采用原密码校验方式。
     */
    @PostMapping("/resetPwd")
    public R resetPwd(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String oldPwd = body.get("oldPassword");
        String newPwd = body.get("newPassword");
        if (username == null || username.isBlank()) {
            return R.fail("请输入账号");
        }
        if (oldPwd == null || oldPwd.isBlank() || newPwd == null || newPwd.isBlank()) {
            return R.fail("请填写原密码与新密码");
        }
        if (newPwd.length() < 6) {
            return R.fail("新密码至少 6 位");
        }
        SysAccount account = accountService.getByUsername(username);
        if (account == null) {
            return R.fail("账号不存在");
        }
        if (!PasswordEncoder.matches(oldPwd, account.getPassword())) {
            return R.fail("原密码不正确");
        }
        account.setPassword(PasswordEncoder.encode(newPwd));
        accountService.updateById(account);
        return R.ok("密码重置成功");
    }

    /**
     * 微信小程序一键登录
     * 前端调用 uni.login 获取 code 后传入，后端用 code 调用微信
     * jscode2session 接口换取真实 openid，自动完成注册或登录。
     */
    @PostMapping("/wechatLogin")
    public R wechatLogin(@RequestBody Map<String, String> body) {
        String code = body.get("code");
        if (code == null || code.isBlank()) {
            return R.fail("缺少微信登录凭证 code");
        }
        String openid;
        try {
            openid = getOpenidByCode(code);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
        try {
            return R.ok(loginByOpenid(openid));
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    /**
     * 按 openid 查找或自动注册微信用户，并签发登录 token。
     * 小程序一键登录与扫码登录共用。
     */
    private Map<String, Object> loginByOpenid(String openid) {
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("openid", openid));
        if (account == null) {
            // 自动注册新用户
            account = new SysAccount();
            String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            account.setUsername(openid);
            account.setPassword(PasswordEncoder.encode(openid));
            account.setNickname("微信用户" + openid.substring(openid.length() - 6));
            account.setPhone("");
            account.setOpenid(openid);
            account.setRole("user");
            account.setStatus(1);
            account.setCreatedAt(now);
            account.setUpdatedAt(now);
            accountService.save(account);
        }
        if (account.getStatus() != null && account.getStatus() == 0) {
            throw new RuntimeException("账号已被禁用");
        }
        String token = JwtUtil.generate(account.getUsername(), account.getRole());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        Map<String, Object> user = new HashMap<>();
        user.put("id", account.getId());
        user.put("username", account.getUsername());
        user.put("nickname", account.getNickname());
        user.put("role", account.getRole());
        result.put("user", user);
        return result;
    }

    // ===================== 微信扫码登录（PC / Web 端） =====================

    /**
     * 1) 创建扫码登录 ticket，并返回微信小程序码图片地址。
     * 预检微信配置：拿不到 access_token 时提前报错，避免前端只看到图片 502。
     */
    @PostMapping("/scanLogin/create")
    public R scanLoginCreate() {
        String ticket = scanLoginManager.create();
        try {
            getWxAccessToken();
        } catch (RuntimeException e) {
            scanLoginManager.remove(ticket);
            return R.fail("微信配置错误：" + e.getMessage());
        }
        Map<String, Object> result = new HashMap<>();
        result.put("ticket", ticket);
        result.put("expireSeconds", ScanLoginManager.EXPIRE_MS / 1000);
        result.put("qrcode", "/api/auth/scanLogin/wxacode/" + ticket);
        return R.ok(result);
    }

    /**
     * 2) 返回微信"小程序码"PNG 图片流。
     * 用户用微信扫码后直接打开小程序 pages/scan/confirm 确认页（scene 携带 ticket）。
     */
    @GetMapping("/scanLogin/wxacode/{ticket}")
    public ResponseEntity<byte[]> wxacode(@PathVariable String ticket) {
        if (ticket == null || ticket.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        // 先尝试缓存 token；若微信判定 token 失效，强制刷新后重试一次
        // （微信的 access_token 是全局唯一凭证，任何一方重新获取都会使旧 token 立即失效）
        ResponseEntity<byte[]> res = callWxacode(ticket, getWxAccessToken());
        if (isTokenInvalid(res)) {
            forceRefreshWxAccessToken();
            res = callWxacode(ticket, getWxAccessToken());
        }
        return res;
    }

    /** 调用微信 getwxacodeunlimit 生成小程序码，统一异常为 JSON 透出错误信息 */
    private ResponseEntity<byte[]> callWxacode(String ticket, String accessToken) {
        try {
            String url = "https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=" + accessToken;
            Map<String, Object> payload = new HashMap<>();
            payload.put("scene", ticket);
            payload.put("page", wxScanPage);
            payload.put("width", 320);
            payload.put("check_path", false);
            // 注意：Spring 6.1+ 的 RestTemplate 不再自动设置 Content-Length，
            // 而微信会校验该头，缺失会返回 412 Precondition Failed。
            // 因此先序列化 JSON body，再手动设置 Content-Length。
            byte[] jsonBody = new ObjectMapper().writeValueAsBytes(payload);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setContentLength(jsonBody.length);
            ResponseEntity<byte[]> res = restTemplate.postForEntity(
                    url, new HttpEntity<>(jsonBody, headers), byte[].class);
            byte[] data = res.getBody();
            if (data == null || data.length == 0) {
                return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body("{\"code\":502,\"msg\":\"微信返回空响应\"}".getBytes(StandardCharsets.UTF_8));
            }
            // 成功时返回图片二进制；失败时微信返回 JSON（如页面未发布 41030）
            String text = new String(data, StandardCharsets.UTF_8);
            if (text.trim().startsWith("{")) {
                return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(data);
            }
            HttpHeaders respHeaders = new HttpHeaders();
            respHeaders.setContentType(MediaType.IMAGE_JPEG);
            respHeaders.setCacheControl("no-store");
            return new ResponseEntity<>(data, respHeaders, HttpStatus.OK);
        } catch (Exception e) {
            // 透出异常信息，便于定位（如 412 access_token 失效 / 网络超时 / JSON 序列化等）
            String msg = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(("{\"code\":502,\"msg\":\"生成小程序码失败:" + msg + "\"}").getBytes(StandardCharsets.UTF_8));
        }
    }

    /** 判断失败是否为 access_token 失效/过期导致（可安全重试） */
    private boolean isTokenInvalid(ResponseEntity<byte[]> res) {
        byte[] body = res.getBody();
        if (body == null) {
            return false;
        }
        String text = new String(body, StandardCharsets.UTF_8);
        // 微信返回的 HTTP 错误码/异常信息
        if (text.contains("412") || text.contains("401") || text.contains("40001")
                || text.contains("42001") || text.contains("41001") || text.contains("40014")) {
            return true;
        }
        // 微信 JSON 错误码形式 {"errcode":40001,...}
        return text.matches(".*\"errcode\"\\s*:\\s*(40001|42001|41001|40014).*");
    }

    /** 强制刷新微信 access_token（清缓存后重新获取） */
    private synchronized void forceRefreshWxAccessToken() {
        wxAccessToken = null;
        wxAccessTokenExpireAt = 0;
        getWxAccessToken();
    }

    /**
     * 3) PC 端轮询扫码状态。
     * 返回 status: waiting / scanned / confirmed / expired / not_found
     * 当 status=confirmed 时附带 token，前端据此完成登录。
     */
    @PostMapping("/scanLogin/check")
    public R scanLoginCheck(@RequestBody Map<String, String> body) {
        String ticket = body.get("ticket");
        if (ticket == null || ticket.isBlank()) {
            return R.fail("缺少 ticket");
        }
        return R.ok(scanLoginManager.check(ticket));
    }

    /** 3.5) 手机端扫码进入确认页时调用，把状态置为"已扫码"（PC 端及时提示） */
    @PostMapping("/scanLogin/marked")
    public R scanLoginMarked(@RequestBody Map<String, String> body) {
        String ticket = body.get("ticket");
        if (ticket == null || ticket.isBlank()) {
            return R.fail("缺少 ticket");
        }
        if (!scanLoginManager.markScanned(ticket)) {
            return R.fail("二维码已失效，请刷新重试");
        }
        return R.ok();
    }

    /**
     * 4) 手机端确认登录：小程序扫码确认页调用 uni.login 拿到 code 后传入，
     * 后端用 code 换真实 openid，自动注册/登录并写入 ticket，PC 端轮询即可登录。
     */
    @PostMapping("/scanLogin/confirm")
    public R scanLoginConfirm(@RequestBody Map<String, String> body) {
        String ticket = body.get("ticket");
        String code = body.get("code");
        if (ticket == null || ticket.isBlank()) {
            return R.fail("缺少 ticket");
        }
        if (code == null || code.isBlank()) {
            return R.fail("缺少微信登录凭证 code");
        }
        String openid;
        try {
            openid = getOpenidByCode(code);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
        Map<String, Object> result;
        try {
            result = loginByOpenid(openid);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
        boolean ok = scanLoginManager.confirm(ticket, (String) result.get("token"), openid);
        if (!ok) {
            return R.fail("二维码已失效，请刷新重试");
        }
        return R.ok(result);
    }

    /** 根据 Authorization 头中的 JWT 返回当前登录用户信息 */
    @PostMapping("/info")
    public R info(jakarta.servlet.http.HttpServletRequest request) {
        String auth = request.getHeader("Authorization");
        String token = (auth != null && auth.startsWith("Bearer ")) ? auth.substring(7) : null;
        if (token == null) {
            return R.fail("未登录或登录已过期");
        }
        Map<String, Object> claims = JwtUtil.parse(token);
        if (claims == null) {
            return R.fail("未登录或登录已过期");
        }
        String username = (String) claims.get("sub");
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", username));
        if (account == null) {
            return R.fail("账号不存在");
        }
        Map<String, Object> user = new HashMap<>();
        user.put("id", account.getId());
        user.put("username", account.getUsername());
        user.put("nickname", account.getNickname());
        user.put("role", account.getRole());
        return R.ok(user);
    }
}
