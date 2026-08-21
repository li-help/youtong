package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Favorite;
import com.youtong.mapper.FavoriteMapper;
import org.springframework.stereotype.Service;

@Service
public class FavoriteService extends ServiceImpl<FavoriteMapper, Favorite> {}
