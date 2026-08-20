package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Category;
import com.youtong.entity.Course;
import com.youtong.entity.Video;
import com.youtong.service.CategoryService;
import com.youtong.service.CourseService;
import com.youtong.service.DataVersionService;
import com.youtong.service.VideoService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/category")
public class CategoryController extends CrudController<Category, Long> {
    private final CategoryService categoryService;
    private final CourseService courseService;
    private final VideoService videoService;

    public CategoryController(CategoryService service,
                              CourseService courseService,
                              VideoService videoService,
                              DataVersionService dataVersionService) {
        super(service, "status", new String[]{"name"}, "category", dataVersionService);
        this.categoryService = service;
        this.courseService = courseService;
        this.videoService = videoService;
    }

    /** B 端分类列表：填充父分类名称 */
    @Override
    protected void fillExtra(List<Category> records) {
        if (records == null || records.isEmpty()) return;
        Set<Long> ids = records.stream()
                .map(Category::getParentId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (ids.isEmpty()) return;
        Map<Long, String> nameMap = categoryService.listByIds(ids).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName));
        records.forEach(c -> c.setParentName(nameMap.getOrDefault(c.getParentId(), "")));
    }

    /** C 端分类列表（公开，仅启用 status=1） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "20") Integer pageSize) {
        Page<Category> p = new Page<>(page, pageSize);
        QueryWrapper<Category> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByAsc("sort").orderByAsc("id");
        p = categoryService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }

    /** 删除分类：校验是否被课程/视频引用，以及是否存在子分类 */
    @Override
    @DeleteMapping("/{id}")
    public R remove(@PathVariable Long id) {
        long courseCount = courseService.count(new QueryWrapper<Course>().eq("category_id", id));
        if (courseCount > 0) {
            return R.fail("该分类下存在 " + courseCount + " 门课程，无法删除");
        }
        long videoCount = videoService.count(new QueryWrapper<Video>().eq("category_id", id));
        if (videoCount > 0) {
            return R.fail("该分类下存在 " + videoCount + " 个视频，无法删除");
        }
        long childCount = categoryService.count(new QueryWrapper<Category>().eq("parent_id", id));
        if (childCount > 0) {
            return R.fail("该分类下存在 " + childCount + " 个子分类，请先处理子分类");
        }
        return super.remove(id);
    }
}
