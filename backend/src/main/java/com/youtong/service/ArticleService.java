package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Article;
import com.youtong.mapper.ArticleMapper;
import org.springframework.stereotype.Service;

@Service
public class ArticleService extends ServiceImpl<ArticleMapper, Article> {}
