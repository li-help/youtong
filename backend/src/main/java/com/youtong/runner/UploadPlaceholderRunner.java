package com.youtong.runner;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

/**
 * 应用启动时检查上传目录，缺少占位图则自动生成一张。
 * 避免 seed.sql 使用外部图片（picsum.photos 国内不可达）时页面灰屏。
 */
@Component
public class UploadPlaceholderRunner implements CommandLineRunner {

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @Override
    public void run(String... args) throws Exception {
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File placeholder = new File(dir, "placeholder.jpg");
        if (!placeholder.exists()) {
            generatePlaceholder(placeholder, 800, 600);
        }
    }

    private void generatePlaceholder(File file, int width, int height) throws IOException {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 暖色背景 #FFF3DE
        g.setColor(new Color(255, 243, 222));
        g.fillRect(0, 0, width, height);

        // 中心圆 #F6B51E
        g.setColor(new Color(246, 181, 30));
        int diameter = Math.min(width, height) / 3;
        int x = (width - diameter) / 2;
        int y = (height - diameter) / 2;
        g.fillOval(x, y, diameter, diameter);

        // 英文标识（服务器通常都有 SansSerif，避免中文字体缺失）
        g.setColor(Color.WHITE);
        int fontSize = diameter / 5;
        g.setFont(new Font("SansSerif", Font.BOLD, fontSize));
        FontMetrics fm = g.getFontMetrics();
        String text = "YOUTONG";
        int textWidth = fm.stringWidth(text);
        int textHeight = fm.getAscent();
        g.drawString(text, (width - textWidth) / 2, y + (diameter + textHeight) / 2 - fontSize / 4);

        g.dispose();
        ImageIO.write(image, "jpg", file);
    }
}
