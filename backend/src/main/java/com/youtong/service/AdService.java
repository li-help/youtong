package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Ad;
import com.youtong.mapper.AdMapper;
import org.springframework.stereotype.Service;

@Service
public class AdService extends ServiceImpl<AdMapper, Ad> {}
