package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.User;
import com.youtong.mapper.UserMapper;
import org.springframework.stereotype.Service;

@Service
public class UserService extends ServiceImpl<UserMapper, User> {}
