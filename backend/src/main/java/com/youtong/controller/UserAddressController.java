package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.youtong.common.R;
import com.youtong.entity.SysAccount;
import com.youtong.entity.UserAddress;
import com.youtong.service.SysAccountService;
import com.youtong.service.UserAddressService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/address")
public class UserAddressController {

    private final UserAddressService service;
    private final SysAccountService accountService;

    public UserAddressController(UserAddressService service, SysAccountService accountService) {
        this.service = service;
        this.accountService = accountService;
    }

    private SysAccount currentAccount(HttpServletRequest request) {
        Object username = request.getAttribute("username");
        if (username == null) return null;
        return accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", username.toString()).last("LIMIT 1"));
    }

    private String now() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    /** C 端：我的收货地址列表（默认地址排最前） */
    @GetMapping("/list")
    public R list(HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        List<UserAddress> list = service.list(
                new QueryWrapper<UserAddress>()
                        .eq("user_id", account.getId())
                        .orderByDesc("is_default").orderByDesc("id"));
        return R.ok(list);
    }

    /** 新增或更新地址 */
    @PostMapping("/save")
    public R save(@RequestBody UserAddress address, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        if (address.getName() == null || address.getName().trim().isEmpty()) return R.fail("请填写收货人姓名");
        if (address.getPhone() == null || address.getPhone().trim().isEmpty()) return R.fail("请填写联系电话");
        if (address.getDetail() == null || address.getDetail().trim().isEmpty()) return R.fail("请填写详细地址");
        address.setName(address.getName().trim());
        address.setPhone(address.getPhone().trim());
        address.setDetail(address.getDetail().trim());

        boolean isNew = address.getId() == null;
        if (isNew) {
            address.setId(null);
            address.setUserId(account.getId());
            // 首个地址自动设为默认
            if (address.getIsDefault() == null || address.getIsDefault() != 1) {
                long count = service.count(new QueryWrapper<UserAddress>().eq("user_id", account.getId()));
                address.setIsDefault(count == 0 ? 1 : 0);
            }
            address.setCreatedAt(now());
            address.setUpdatedAt(now());
        } else {
            UserAddress old = service.getById(address.getId());
            if (old == null || !old.getUserId().equals(account.getId())) return R.fail("地址不存在");
            address.setUserId(account.getId());
            address.setUpdatedAt(now());
        }
        // 若设为默认，先取消其它默认
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            service.update(new LambdaUpdateWrapper<UserAddress>()
                    .set(UserAddress::getIsDefault, 0)
                    .eq(UserAddress::getUserId, account.getId())
                    .ne(address.getId() != null, UserAddress::getId, address.getId() == null ? 0L : address.getId()));
        }
        service.saveOrUpdate(address);
        return R.ok(address);
    }

    /** 删除地址 */
    @DeleteMapping("/{id}")
    public R remove(@PathVariable Long id, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        UserAddress address = service.getById(id);
        if (address == null || !address.getUserId().equals(account.getId())) return R.fail("地址不存在");
        service.removeById(id);
        return R.ok();
    }

    /** 设为默认地址 */
    @PostMapping("/{id}/default")
    public R setDefault(@PathVariable Long id, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        UserAddress address = service.getById(id);
        if (address == null || !address.getUserId().equals(account.getId())) return R.fail("地址不存在");
        service.update(new LambdaUpdateWrapper<UserAddress>()
                .set(UserAddress::getIsDefault, 0)
                .eq(UserAddress::getUserId, account.getId()));
        address.setIsDefault(1);
        service.updateById(address);
        return R.ok();
    }
}
