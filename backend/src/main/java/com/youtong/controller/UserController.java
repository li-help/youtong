package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.SysAccount;
import com.youtong.entity.User;
import com.youtong.service.SysAccountService;
import com.youtong.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController extends CrudController<User, Long> {
    private final SysAccountService accountService;

    public UserController(UserService service, SysAccountService accountService) {
        super(service, "status", new String[]{"name", "code", "phone"});
        this.accountService = accountService;
    }

    /** 当前登录账号信息（App 端用户资料） */
    @GetMapping("/me")
    public R me(@RequestAttribute("username") String username) {
        if (username == null) return R.fail("未登录");
        SysAccount account = accountService.getByUsername(username);
        if (account == null) return R.fail("用户不存在");
        Map<String, Object> data = new HashMap<>();
        data.put("id", account.getId());
        data.put("username", account.getUsername());
        data.put("nickname", account.getNickname());
        data.put("phone", account.getPhone());
        data.put("avatar", account.getAvatar());
        data.put("role", account.getRole());
        return R.ok(data);
    }

    /** 更新当前账号昵称（App 端修改资料） */
    @PostMapping("/profile")
    public R profile(@RequestAttribute("username") String username, @RequestBody Map<String, String> body) {
        if (username == null) return R.fail("未登录");
        SysAccount account = accountService.getByUsername(username);
        if (account == null) return R.fail("用户不存在");
        String nickname = body.get("nickname");
        if (nickname != null && !nickname.trim().isEmpty()) {
            account.setNickname(nickname.trim());
        }
        accountService.updateById(account);
        return R.ok("保存成功");
    }
}
