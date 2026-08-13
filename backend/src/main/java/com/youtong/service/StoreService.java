package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Store;
import com.youtong.mapper.StoreMapper;
import org.springframework.stereotype.Service;

@Service
public class StoreService extends ServiceImpl<StoreMapper, Store> {}
