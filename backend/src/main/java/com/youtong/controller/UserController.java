package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Favorite;
import com.youtong.entity.Order;
import com.youtong.entity.SysAccount;
import com.youtong.entity.User;
import com.youtong.service.FavoriteService;
import com.youtong.service.OrderService;
import com.youtong.service.SysAccountService;
import com.youtong.service.UserService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController extends CrudController<User, Long> {
    private final SysAccountService accountService;
    private final OrderService orderService;
    private final FavoriteService favoriteService;

    public UserController(UserService service, SysAccountService accountService,
                          OrderService orderService, FavoriteService favoriteService) {
        super(service, "status", new String[]{"name", "code", "phone"});
        this.accountService = accountService;
        this.orderService = orderService;
        this.favoriteService = favoriteService;
    }

    /** 当前登录账号信息（App 端用户资料） */
    @GetMapping("/me")
    public R me(@RequestAttribute("username") String username) {
        if (username == null) return R.fail("未登录");
        SysAccount account = accountService.getByUsername(username);
        if (account == null) return R.fail("用户不存在");
        Map<String, Object> data = new HashMap<>();
        data.put("id", account.getId());
        data.put("username", account.getUsername());
        data.put("nickname", account.getNickname());
        data.put("phone", account.getPhone());
        data.put("avatar", account.getAvatar());
        data.put("babyAge", account.getBabyAge());
        data.put("remark", account.getRemark());
        data.put("status", account.getStatus());
        data.put("role", account.getRole());
        return R.ok(data);
    }

    /** 生成用户个人二维码 PNG（分享/身份标识，公开接口） */
    @GetMapping("/qrcode/{id}")
    public ResponseEntity<byte[]> qrcode(@PathVariable Long id) {
        String content = "YT|USER|" + id;
        try {
            QRCodeWriter writer = new QRCodeWriter();
            BitMatrix matrix = writer.encode(content, BarcodeFormat.QR_CODE, 320, 320);
            BufferedImage image = MatrixToImageWriter.toBufferedImage(matrix);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", out);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_PNG);
            return new ResponseEntity<>(out.toByteArray(), headers, HttpStatus.OK);
        } catch (WriterException | java.io.IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /** 更新当前账号资料（昵称/手机号/头像/宝宝年龄/备注） */
    @PostMapping("/profile")
    public R profile(@RequestAttribute("username") String username, @RequestBody Map<String, String> body) {
        if (username == null) return R.fail("未登录");
        SysAccount account = accountService.getByUsername(username);
        if (account == null) return R.fail("用户不存在");
        if (body.containsKey("nickname") && !body.get("nickname").trim().isEmpty()) {
            account.setNickname(body.get("nickname").trim());
        }
        if (body.containsKey("phone") && !body.get("phone").trim().isEmpty()) {
            account.setPhone(body.get("phone").trim());
        }
        if (body.containsKey("avatar")) {
            account.setAvatar(body.get("avatar"));
        }
        if (body.containsKey("babyAge")) {
            account.setBabyAge(body.get("babyAge"));
        }
        if (body.containsKey("remark")) {
            account.setRemark(body.get("remark"));
        }
        accountService.updateById(account);
        return R.ok("保存成功");
    }

    /** 我的统计：订单数/收藏数（我的页面数字卡） */
    @GetMapping("/stats")
    public R stats(@RequestAttribute("username") String username) {
        if (username == null) return R.fail("未登录");
        SysAccount account = accountService.getByUsername(username);
        if (account == null) return R.fail("用户不存在");
        long orderCount = orderService.count(new QueryWrapper<Order>().eq("user_id", account.getId()));
        long favoriteCount = favoriteService.count(new QueryWrapper<Favorite>().eq("user_id", account.getId()));
        Map<String, Object> data = new HashMap<>();
        data.put("orderCount", orderCount);
        data.put("favoriteCount", favoriteCount);
        return R.ok(data);
    }
}
