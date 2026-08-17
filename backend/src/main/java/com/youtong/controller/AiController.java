package com.youtong.controller;

import com.youtong.common.R;
import com.youtong.entity.Activity;
import com.youtong.entity.Course;
import com.youtong.entity.Video;
import com.youtong.service.ActivityService;
import com.youtong.service.CourseService;
import com.youtong.service.VideoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * AI 智能助手：基于 OpenAI 兼容协议调用大模型，提供育儿问答与个性化推荐。
 */
@RestController
@RequestMapping("/api/ai")
public class AiController {

    @Value("${ai.base-url}")
    private String baseUrl;
    @Value("${ai.api-key}")
    private String apiKey;
    @Value("${ai.model}")
    private String model;
    @Value("${ai.timeout-ms:60000}")
    private int timeoutMs;
    @Value("${ai.system-prompt:你是优童成长社的 AI 育儿助手。}")
    private String systemPrompt;

    private final RestTemplate restTemplate = new RestTemplate();
    private final CourseService courseService;
    private final ActivityService activityService;
    private final VideoService videoService;

    @Autowired
    public AiController(CourseService courseService, ActivityService activityService, VideoService videoService) {
        this.courseService = courseService;
        this.activityService = activityService;
        this.videoService = videoService;
    }

    /** 育儿问答：接收对话上下文 messages，返回 AI 回复文本 */
    @PostMapping("/chat")
    public R chat(@RequestBody Map<String, Object> body) {
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(mapOf("system", systemPrompt));
        Object incoming = body.get("messages");
        if (incoming instanceof List) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> list = (List<Map<String, Object>>) incoming;
            for (Map<String, Object> m : list) {
                String role = String.valueOf(m.get("role"));
                String content = String.valueOf(m.getOrDefault("content", ""));
                messages.add(mapOf(role, content));
            }
        } else {
            String message = body.get("message") != null ? body.get("message").toString() : "";
            messages.add(mapOf("user", message));
        }
        String reply = callModel(messages);
        if (reply == null) {
            return R.fail("AI 服务暂时不可用，请稍后再试");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("content", reply);
        return R.ok(data);
    }

    /** 个性化推荐：根据宝宝年龄与兴趣，查询热门内容并由 AI 生成摘要 */
    @PostMapping("/recommend")
    public R recommend(@RequestBody Map<String, Object> body) {
        String age = body.get("age") != null ? body.get("age").toString() : "";
        List<String> interests = new ArrayList<>();
        Object raw = body.get("interests");
        if (raw instanceof List) {
            @SuppressWarnings("unchecked")
            List<Object> list = (List<Object>) raw;
            for (Object o : list) interests.add(o != null ? o.toString() : "");
        } else if (raw != null) {
            for (String s : raw.toString().split(",")) {
                if (!s.trim().isEmpty()) interests.add(s.trim());
            }
        }

        List<Course> courses = pick(courseService.list(), 4);
        List<Activity> activities = pick(activityService.list(), 3);
        List<Video> videos = pick(videoService.list(), 3);

        String interestText = interests.isEmpty() ? "综合素养" : String.join("、", interests);
        String prompt = "宝宝 " + (age.isEmpty() ? "未知" : age + " 岁") + "，兴趣方向：" + interestText
                + "。请基于以下推荐内容，用温暖、亲切的语气写一段 100 字以内的个性化推荐导语，不要使用 Markdown：\n"
                + "课程：" + titles(courses) + "\n"
                + "活动：" + titles(activities) + "\n"
                + "视频：" + titles(videos);

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(mapOf("system", systemPrompt));
        messages.add(mapOf("user", prompt));
        String summary = callModel(messages);
        if (summary == null) {
            summary = "结合宝宝当前成长阶段（" + age + "岁）及兴趣偏好（" + interestText
                    + "），我们为您精选了如下内容，助力宝贝全面发展。";
        }

        Map<String, Object> data = new HashMap<>();
        data.put("summary", summary);
        data.put("courses", courses);
        data.put("activities", activities);
        data.put("videos", videos);
        return R.ok(data);
    }

    /** 调用 OpenAI 兼容 /chat/completions 接口 */
    private String callModel(List<Map<String, String>> messages) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            Map<String, Object> req = new HashMap<>();
            req.put("model", model);
            req.put("messages", messages);
            req.put("temperature", 0.8);
            req.put("max_tokens", 400);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(req, headers);
            ResponseEntity<Map> resp = restTemplate.exchange(
                    baseUrl.replaceAll("/+$", "") + "/chat/completions",
                    HttpMethod.POST, entity, Map.class);
            Map<String, Object> bodyMap = resp.getBody();
            if (bodyMap == null) return null;
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> choices = (List<Map<String, Object>>) bodyMap.get("choices");
            if (choices == null || choices.isEmpty()) return null;
            @SuppressWarnings("unchecked")
            Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
            return message != null ? String.valueOf(message.get("content")) : null;
        } catch (Exception e) {
            // 大模型调用异常时返回 null，由调用方降级处理
            return null;
        }
    }

    private Map<String, String> mapOf(String role, String content) {
        Map<String, String> m = new HashMap<>();
        m.put("role", role);
        m.put("content", content);
        return m;
    }

    private <T> List<T> pick(List<T> all, int n) {
        if (all == null) return new ArrayList<>();
        return all.stream().limit(n).collect(Collectors.toList());
    }

    private String titles(List<?> list) {
        if (list == null || list.isEmpty()) return "（无）";
        List<String> ts = new ArrayList<>();
        for (Object o : list) {
            try {
                java.lang.reflect.Field f = o.getClass().getDeclaredField("title");
                f.setAccessible(true);
                Object v = f.get(o);
                if (v != null) ts.add(v.toString());
            } catch (Exception ignored) {
            }
        }
        return ts.isEmpty() ? "（无）" : String.join("、", ts);
    }
}
