package com.youtong.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Activity;
import com.youtong.mapper.ActivityMapper;
import org.springframework.stereotype.Service;

@Service
public class ActivityService extends ServiceImpl<ActivityMapper, Activity> {}
