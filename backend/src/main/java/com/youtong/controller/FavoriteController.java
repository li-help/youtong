package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.youtong.common.R;
import com.youtong.entity.Favorite;
import com.youtong.entity.SysAccount;
import com.youtong.service.FavoriteService;
import com.youtong.service.SysAccountService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    private final FavoriteService service;
    private final SysAccountService accountService;

    public FavoriteController(FavoriteService service, SysAccountService accountService) {
        this.service = service;
        this.accountService = accountService;
    }

    private SysAccount currentAccount(HttpServletRequest request) {
        Object username = request.getAttribute("username");
        if (username == null) return null;
        return accountService.getOne(
                new QueryWrapper<SysAccount>().eq("username", username.toString()).last("LIMIT 1"));
    }

    private String now() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    /** 我的收藏列表（可按类型筛选） */
    @GetMapping("/list")
    public R list(@RequestParam(required = false) String targetType, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        List<Favorite> list = service.list(
                new QueryWrapper<Favorite>()
                        .eq("user_id", account.getId())
                        .eq(targetType != null && !targetType.isEmpty(), "target_type", targetType)
                        .orderByDesc("id"));
        return R.ok(list);
    }

    /** 收藏 */
    @PostMapping("/add")
    public R add(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        String targetType = String.valueOf(body.getOrDefault("targetType", ""));
        String title = String.valueOf(body.getOrDefault("title", ""));
        String cover = body.get("cover") == null ? "" : String.valueOf(body.get("cover"));
        Long targetId;
        try {
            targetId = Long.valueOf(String.valueOf(body.get("targetId")));
        } catch (Exception e) {
            return R.fail("参数错误");
        }
        if (targetType.isEmpty()) return R.fail("参数错误");
        Favorite exist = service.getOne(
                new QueryWrapper<Favorite>().eq("user_id", account.getId())
                        .eq("target_type", targetType).eq("target_id", targetId).last("LIMIT 1"));
        if (exist == null) {
            Favorite fav = new Favorite();
            fav.setUserId(account.getId());
            fav.setTargetType(targetType);
            fav.setTargetId(targetId);
            fav.setTitle(title);
            fav.setCover(cover);
            fav.setCreatedAt(now());
            service.save(fav);
        }
        return R.ok();
    }

    /** 取消收藏 */
    @PostMapping("/remove")
    public R remove(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        String targetType = String.valueOf(body.getOrDefault("targetType", ""));
        Long targetId;
        try {
            targetId = Long.valueOf(String.valueOf(body.get("targetId")));
        } catch (Exception e) {
            return R.fail("参数错误");
        }
        service.remove(new LambdaUpdateWrapper<Favorite>()
                .eq(Favorite::getUserId, account.getId())
                .eq(Favorite::getTargetType, targetType)
                .eq(Favorite::getTargetId, targetId));
        return R.ok();
    }

    /** 查询是否已收藏 */
    @GetMapping("/status")
    public R status(@RequestParam String targetType, @RequestParam Long targetId, HttpServletRequest request) {
        SysAccount account = currentAccount(request);
        if (account == null) return R.fail("未登录");
        Favorite exist = service.getOne(
                new QueryWrapper<Favorite>().eq("user_id", account.getId())
                        .eq("target_type", targetType).eq("target_id", targetId).last("LIMIT 1"));
        return R.ok(exist != null);
    }
}
