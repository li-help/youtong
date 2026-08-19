package com.youtong.config;

import com.youtong.common.JwtInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import java.nio.file.Paths;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private JwtInterceptor jwtInterceptor;

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @Value("${app.download-dir:downloads}")
    private String downloadDir;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor)
                .addPathPatterns("/api/**")
                .excludePathPatterns("/api/auth/login", "/api/auth/logout");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absUploadDir = Paths.get(uploadDir).toAbsolutePath().normalize().toString();
        String absDownloadDir = Paths.get(downloadDir).toAbsolutePath().normalize().toString();

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + absUploadDir + "/");

        registry.addResourceHandler("/download/**")
                .addResourceLocations("file:" + absDownloadDir + "/");
    }
}
