package com.youtong.common;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * 通用分页/查询参数
 * 注意：前端可能传入空字符串 ""，故状态字段用 String 接收，避免 Integer 类型转换 500
 */
public class PageQuery {
    private Integer page = 1;
    private Integer pageSize = 10;
    private String status;
    private String keyword;

    public Integer getPage() { return page; }
    public void setPage(Integer page) { if (page != null) this.page = page; }
    public Integer getPageSize() { return pageSize; }
    public void setPageSize(Integer pageSize) { if (pageSize != null) this.pageSize = pageSize; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    /** 解析状态为整数，空/非法返回 null */
    public Integer getStatusInt() {
        if (status == null || status.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(status.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public <T> IPage<T> toPage() {
        return new Page<>(page, pageSize);
    }

    /**
     * 关键词模糊匹配给定字段（空关键词忽略）
     */
    public <T> QueryWrapper<T> applyKeyword(QueryWrapper<T> qw, String... columns) {
        if (keyword != null && !keyword.trim().isEmpty() && columns.length > 0) {
            qw.and(w -> {
                for (String c : columns) w.or().like(c, keyword.trim());
            });
        }
        return qw;
    }
}
