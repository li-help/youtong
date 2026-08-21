package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.UserAddress;
import com.youtong.mapper.UserAddressMapper;
import org.springframework.stereotype.Service;

@Service
public class UserAddressService extends ServiceImpl<UserAddressMapper, UserAddress> {}
