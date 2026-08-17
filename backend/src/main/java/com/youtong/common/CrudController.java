package com.youtong.common;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.youtong.service.DataVersionService;
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
    /** 实时同步频道名（非空时，增删改后自增该频道版本号，供 C 端实时刷新）；为 null 则不同步 */
    protected final String versionChannel;
    protected final DataVersionService dataVersionService;
    /** 是否支持按 position_id 筛选（广告等带广告位概念的模块） */
    protected final boolean filterPositionId;

    protected CrudController(IService<T> service, String statusColumn, String[] keywordColumns) {
        this(service, statusColumn, keywordColumns, null, null, false);
    }

    protected CrudController(IService<T> service, String statusColumn, String[] keywordColumns,
                             String versionChannel, DataVersionService dataVersionService) {
        this(service, statusColumn, keywordColumns, versionChannel, dataVersionService, false);
    }

    protected CrudController(IService<T> service, String statusColumn, String[] keywordColumns,
                             String versionChannel, DataVersionService dataVersionService,
                             boolean filterPositionId) {
        this.service = service;
        this.statusColumn = statusColumn;

        this.keywordColumns = keywordColumns;
        this.versionChannel = versionChannel;
        this.dataVersionService = dataVersionService;
        this.filterPositionId = filterPositionId;
    }

    @GetMapping
    public R list(PageQuery q,
                  @org.springframework.web.bind.annotation.RequestParam(required = false) Long positionId) {
        IPage<T> page = q.toPage();
        QueryWrapper<T> qw = new QueryWrapper<>();
        if (statusColumn != null && q.getStatusInt() != null) {
            qw.eq(statusColumn, q.getStatusInt());
        }
        if (filterPositionId && positionId != null) {
            qw.eq("position_id", positionId);
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
        bumpVersion();
        return R.ok();
    }

    @GetMapping("/{id}")
    public R detail(@PathVariable ID id) {
        T entity = service.getById(id);
        return R.ok(entity);
    }

    @DeleteMapping("/{id}")
    public R remove(@PathVariable ID id) {
        service.removeById(id);
        bumpVersion();
        return R.ok();
    }

    /** 若配置了实时同步频道，则在数据变更后自增版本号 */
    private void bumpVersion() {
        if (versionChannel != null && dataVersionService != null) {
            dataVersionService.increment(versionChannel);
        }
    }
}
