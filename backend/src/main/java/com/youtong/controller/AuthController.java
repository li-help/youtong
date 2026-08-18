package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.youtong.common.JwtUtil;
import com.youtong.common.PasswordEncoder;
import com.youtong.common.R;
import com.youtong.common.ScanLoginManager;
import com.youtong.entity.SysAccount;
import com.youtong.service.SmsCodeService;
import com.youtong.service.SysAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
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

    private final RestTemplate restTemplate = new RestTemplate();

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
     * 演示环境直接返回验证码，便于前端提示；接入短信网关后改为不返回明文。
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
        result.put("code", code); // 演示环境返回明文，便于联调
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

    // ===================== 微信扫码登录（PC / Web 端） =====================

    /**
     * 1) 创建扫码登录 ticket，并返回二维码图片地址。
     * 二维码内容为一个可被微信识别的 URL（演示环境指向本系统扫码确认页）。
     */
    @PostMapping("/scanLogin/create")
    public R scanLoginCreate() {
        String ticket = scanLoginManager.create();
        String qrContent = "https://youtong.example.com/scan?ticket=" + ticket;
        Map<String, Object> result = new HashMap<>();
        result.put("ticket", ticket);
        result.put("expireSeconds", ScanLoginManager.EXPIRE_MS / 1000);
        result.put("qrcode", "/api/auth/qrcode/" + ticket);
        result.put("qrContent", qrContent);
        return R.ok(result);
    }

    /** 2) 返回二维码 PNG 图片流 */
    @GetMapping("/qrcode/{ticket}")
    public ResponseEntity<byte[]> qrcode(@PathVariable String ticket) {
        String content = "https://youtong.example.com/scan?ticket=" + ticket;
        try {
            QRCodeWriter writer = new QRCodeWriter();
            BitMatrix matrix = writer.encode(content, BarcodeFormat.QR_CODE, 320, 320);
            BufferedImage image = MatrixToImageWriter.toBufferedImage(matrix);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", out);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_PNG);
            return new ResponseEntity<>(out.toByteArray(), headers, HttpStatus.OK);
        } catch (WriterException | java.io.IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
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

    /**
     * 4) 确认登录（演示用：真实环境由微信 OAuth 回调或手机端确认触发）。
     * 这里使用已存在的 openid 账户进行登录并写入 token。
     */
    @PostMapping("/scanLogin/confirm")
    public R scanLoginConfirm(@RequestBody Map<String, String> body) {
        String ticket = body.get("ticket");
        String openid = body.get("openid");
        if (ticket == null || ticket.isBlank()) {
            return R.fail("缺少 ticket");
        }
        // 若未传 openid，使用演示账户 openid，确保流程可跑通
        if (openid == null || openid.isBlank()) {
            openid = "wx_demo_openid";
        }
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("openid", openid));
        if (account == null) {
            // 自动注册
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
        String token = JwtUtil.generate(account.getUsername(), account.getRole());
        boolean ok = scanLoginManager.confirm(ticket, token, openid);
        if (!ok) {
            return R.fail("二维码已失效，请刷新重试");
        }
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
