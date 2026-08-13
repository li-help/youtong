package com.youtong.common;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.io.Serializable;

/**
 * 通用 CRUD 控制器基类
 * 子类通过构造器传入 service、状态字段名、关键词搜索字段
 */
public abstract class CrudController<T, ID extends Serializable> {

    protected final IService<T> service;
    /** 状态字段名（数据库列名），为 null 则不按状态过滤 */
    protected final String statusColumn;
    /** 关键词模糊搜索的字段（数据库列名） */
    protected final String[] keywordColumns;

    protected CrudController(IService<T> service, String statusColumn, String[] keywordColumns) {
        this.service = service;
        this.statusColumn = statusColumn;
        this.keywordColumns = keywordColumns;
    }

    @GetMapping
    public R list(PageQuery q) {
        IPage<T> page = q.toPage();
        QueryWrapper<T> qw = new QueryWrapper<>();
        if (statusColumn != null && q.getStatusInt() != null) {
            qw.eq(statusColumn, q.getStatusInt());
        }
        if (keywordColumns != null && keywordColumns.length > 0) {
            q.applyKeyword(qw, keywordColumns);
        }
        page = service.page(page, qw);
        return R.ok(R.page(page.getTotal(), page.getRecords(), page.getCurrent(), page.getSize()));
    }

    @PostMapping
    public R save(@RequestBody T entity) {
        service.saveOrUpdate(entity);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    public R remove(@PathVariable ID id) {
        service.removeById(id);
        return R.ok();
    }
}
