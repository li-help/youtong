package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Order;
import com.youtong.mapper.OrderMapper;
import org.springframework.stereotype.Service;

@Service
public class OrderService extends ServiceImpl<OrderMapper, Order> {}
