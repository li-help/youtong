package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.common.JwtUtil;
import com.youtong.common.PasswordEncoder;
import com.youtong.common.R;
import com.youtong.entity.SysAccount;
import com.youtong.service.SysAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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

    @PostMapping("/login")
    public R login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || password == null) {
            return R.fail("用户名和密码不能为空");
        }
        SysAccount account = accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", username));
        if (account == null || !PasswordEncoder.matches(password, account.getPassword())) {
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
        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            return R.fail("用户名和密码不能为空");
        }
        if (!PHONE_PATTERN.matcher(username).matches()) {
            return R.fail("请输入有效的手机号");
        }
        if (password.length() < 6) {
            return R.fail("密码长度不能少于6位");
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

    @PostMapping("/logout")
    public R logout() {
        // JWT 为无状态令牌，服务端无需维护会话；前端删除本地 token 即可
        return R.ok();
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
