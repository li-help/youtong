package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.SysAccount;
import com.youtong.mapper.SysAccountMapper;
import org.springframework.stereotype.Service;

@Service
public class SysAccountService extends ServiceImpl<SysAccountMapper, SysAccount> {}
