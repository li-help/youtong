package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.common.JwtUtil;
import com.youtong.common.R;
import com.youtong.entity.*;
import com.youtong.service.*;
import jakarta.servlet.http.HttpServletRequest;
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
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * AI 智能助手与智能客服控制器
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
    @Value("${ai.system-prompt:你是优童成长社的 AI 育儿与客服助手，面向 0-6 岁儿童家庭。回答要亲切、专业、简明。若遇到无法确定的业务或家长强烈要求人工，请建议转接人工客服。}")
    private String systemPrompt;

    private final RestTemplate restTemplate = new RestTemplate();
    private final CourseService courseService;
    private final ActivityService activityService;
    private final VideoService videoService;
    private final FaqKnowledgeService faqKnowledgeService;
    private final ImSessionService imSessionService;
    private final ImMessageService imMessageService;
    private final SysAccountService accountService;

    @Autowired
    public AiController(CourseService courseService,
                        ActivityService activityService,
                        VideoService videoService,
                        FaqKnowledgeService faqKnowledgeService,
                        ImSessionService imSessionService,
                        ImMessageService imMessageService,
                        SysAccountService accountService) {
        this.courseService = courseService;
        this.activityService = activityService;
        this.videoService = videoService;
        this.faqKnowledgeService = faqKnowledgeService;
        this.imSessionService = imSessionService;
        this.imMessageService = imMessageService;
        this.accountService = accountService;
    }

    private SysAccount getCurrentUser(HttpServletRequest request) {
        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) return null;
        String token = auth.substring(7);
        String username = JwtUtil.getUsername(token);
        if (username == null) return null;
        return accountService.getOne(new QueryWrapper<SysAccount>().eq("username", username));
    }

    /**
     * 增强版 AI 客服对话：结合 FAQ 知识库、持久化存储与转人工检测
     */
    @PostMapping("/service-chat")
    public R serviceChat(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        String message = body.get("message") != null ? body.get("message").toString().trim() : "";
        if (message.isBlank()) return R.fail("请输入咨询内容");

        String clientMsgId = body.get("clientMsgId") != null ? body.get("clientMsgId").toString() : UUID.randomUUID().toString();
        Long storeId = body.get("storeId") != null ? Long.valueOf(body.get("storeId").toString()) : 0L;
        Long sessionId = body.get("sessionId") != null ? Long.valueOf(body.get("sessionId").toString()) : null;

        SysAccount user = getCurrentUser(request);
        Long userId = user != null ? user.getId() : 0L;

        // 1. 获取或创建会话
        ImSession session;
        if (sessionId != null) {
            session = imSessionService.getById(sessionId);
        } else if (userId > 0) {
            session = imSessionService.getOrCreateSession(userId, storeId);
        } else {
            session = null;
        }

        Long actualSessionId = session != null ? session.getId() : 0L;

        // 2. 保存用户消息
        if (actualSessionId > 0 && userId > 0) {
            imMessageService.saveMessage(actualSessionId, clientMsgId, 1, userId, 0L, "text", message);
        }

        // 3. 转人工意图识别
        if (isTransferIntent(message)) {
            String notice = "已为您识别到人工客服需求。请点击顶部【转人工客服】按钮或直接为您转接。";
            if (actualSessionId > 0 && userId > 0) {
                imMessageService.saveMessage(actualSessionId, UUID.randomUUID().toString(), 4, 0L, userId, "transfer_notice", notice);
            }
            Map<String, Object> data = new HashMap<>();
            data.put("content", notice);
            data.put("type", "transfer");
            data.put("needTransfer", true);
            data.put("sessionId", actualSessionId);
            return R.ok(data);
        }

        // 4. FAQ 知识库检索优先匹配
        FaqKnowledge faq = faqKnowledgeService.matchFaq(message);
        if (faq != null) {
            String reply = faq.getAnswer();
            if (actualSessionId > 0 && userId > 0) {
                imMessageService.saveMessage(actualSessionId, UUID.randomUUID().toString(), 3, 0L, userId, "faq", reply);
            }
            Map<String, Object> data = new HashMap<>();
            data.put("content", reply);
            data.put("type", "faq");
            data.put("faqId", faq.getId());
            data.put("faqQuestion", faq.getQuestion());
            data.put("sessionId", actualSessionId);
            return R.ok(data);
        }

        // 5. 大模型多轮对话组装
        List<Map<String, String>> promptMessages = new ArrayList<>();
        promptMessages.add(mapOf("system", systemPrompt));

        // 如果存在历史会话，获取最近 6 条上下文
        if (actualSessionId > 0) {
            List<ImMessage> history = imMessageService.getHistory(actualSessionId, 1, 6);
            for (ImMessage h : history) {
                if (h.getSenderType() == 1) {
                    promptMessages.add(mapOf("user", h.getContent()));
                } else if (h.getSenderType() == 3) {
                    promptMessages.add(mapOf("assistant", h.getContent()));
                }
            }
        } else {
            promptMessages.add(mapOf("user", message));
        }

        String reply = callModel(promptMessages);
        if (reply == null || reply.isBlank()) {
            reply = "抱歉，我刚刚走神了～您可以重试一次，或者点击顶部【转人工客服】咨询我们的人工老师。";
        }

        // 6. 持久化 AI 回复
        if (actualSessionId > 0 && userId > 0) {
            imMessageService.saveMessage(actualSessionId, UUID.randomUUID().toString(), 3, 0L, userId, "text", reply);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("content", reply);
        data.put("type", "ai");
        data.put("sessionId", actualSessionId);
        return R.ok(data);
    }

    private boolean isTransferIntent(String text) {
        return text != null && text.matches(".*(转人工|人工客服|找人工|人工服务|投诉|转接).*");
    }

    /** 基础问答兼容接口 */
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

    /** 个性化推荐 */
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
            headers.setBearerAuth(apiKey != null ? apiKey : "");

            Map<String, Object> req = new HashMap<>();
            req.put("model", model);
            req.put("messages", messages);
            req.put("temperature", 0.7);
            req.put("max_tokens", 500);

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
