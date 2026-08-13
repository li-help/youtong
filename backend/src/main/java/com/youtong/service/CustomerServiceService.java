package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.CustomerService;
import com.youtong.mapper.CustomerServiceMapper;
import org.springframework.stereotype.Service;

@Service
public class CustomerServiceService extends ServiceImpl<CustomerServiceMapper, CustomerService> {}
