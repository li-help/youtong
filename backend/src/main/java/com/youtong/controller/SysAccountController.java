package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.common.PasswordEncoder;
import com.youtong.common.R;
import com.youtong.entity.SysAccount;
import com.youtong.service.SysAccountService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sys/account")
public class SysAccountController extends CrudController<SysAccount, Long> {
    public SysAccountController(SysAccountService service) {
        super(service, "status", new String[]{"username", "nickname"});
    }

    @Override
    @PostMapping
    public R save(@RequestBody SysAccount entity) {
        String pwd = entity.getPassword();
        if (pwd != null && !pwd.isEmpty() && !PasswordEncoder.isEncoded(pwd)) {
            // 仅当传入明文密码时才加密（已加密密文不重复处理）
            entity.setPassword(PasswordEncoder.encode(pwd));
        } else if (pwd == null || pwd.isEmpty()) {
            // 密码为空时不更新密码字段：移除该属性，避免覆盖为 null
            entity.setPassword(null);
            ((com.baomidou.mybatisplus.extension.service.IService<SysAccount>) service)
                    .updateById(entity);
            return R.ok();
        }
        service.saveOrUpdate(entity);
        return R.ok();
    }
}
