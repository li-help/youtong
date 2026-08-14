package com.youtong.controller;

import com.youtong.common.R;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class UploadController {

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @PostMapping("/upload")
    public R upload(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return R.fail("文件为空");
        }
        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.lastIndexOf('.') >= 0) {
            ext = original.substring(original.lastIndexOf('.'));
        }
        if (!ext.matches("(?i)\\.(png|jpe?g|gif|webp|bmp)")) {
            return R.fail("仅支持图片文件");
        }
        try {
            String filename = UUID.randomUUID().toString().replace("-", "") + ext;
            File dir = new File(uploadDir).getAbsoluteFile();
            if (!dir.exists()) {
                dir.mkdirs();
            }
            file.transferTo(new File(dir, filename));
            Map<String, Object> data = new HashMap<>();
            data.put("url", "/uploads/" + filename);
            return R.ok(data);
        } catch (Exception e) {
            return R.fail("上传失败: " + e.getMessage());
        }
    }
}
