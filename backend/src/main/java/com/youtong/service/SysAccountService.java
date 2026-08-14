package com.youtong.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.SysAccount;
import com.youtong.mapper.SysAccountMapper;
import org.springframework.stereotype.Service;

@Service
public class SysAccountService extends ServiceImpl<SysAccountMapper, SysAccount> {

    public SysAccount getByUsername(String username) {
        if (username == null) return null;
        return getOne(new QueryWrapper<SysAccount>().eq("username", username));
    }
}
