package com.youtong.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.CustomerService;
import com.youtong.entity.ImSession;
import com.youtong.entity.Store;
import com.youtong.entity.SysAccount;
import com.youtong.mapper.ImSessionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ImSessionService extends ServiceImpl<ImSessionMapper, ImSession> {

    @Autowired
    private SysAccountService accountService;

    @Autowired
    private StoreService storeService;

    @Autowired
    private CustomerServiceService customerServiceService;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 获取或初始化用户的会话
     */
    public ImSession getOrCreateSession(Long userId, Long storeId) {
        if (storeId == null) storeId = 0L;
        String sessionNo = "sess_" + userId + "_" + storeId;
        ImSession session = getOne(new QueryWrapper<ImSession>().eq("session_no", sessionNo));
        if (session == null) {
            session = new ImSession();
            session.setSessionNo(sessionNo);
            session.setUserId(userId);
            session.setStoreId(storeId);
            session.setSessionType(1); // 默认 1: AI客服
            session.setLastMsgContent("您好！我是优童 AI 育儿助手，有什么可以帮您？");
            String now = LocalDateTime.now().format(FMT);
            session.setLastMsgTime(now);
            session.setUnreadCountUser(0);
            session.setUnreadCountCs(0);
            session.setStatus(1);
            session.setCreatedAt(now);
            session.setUpdatedAt(now);
            save(session);
        }
        return session;
    }

    /**
     * 填充会话额外信息（用户昵称、客服昵称、门店名称等）
     */
    public void fillSessionExtra(List<ImSession> list) {
        if (list == null || list.isEmpty()) return;
        for (ImSession s : list) {
            // 用户信息
            if (s.getUserId() != null) {
                SysAccount u = accountService.getById(s.getUserId());
                if (u != null) {
                    s.setUserName(u.getNickname() != null && !u.getNickname().isBlank() ? u.getNickname() : u.getUsername());
                    s.setUserAvatar(u.getAvatar());
                }
            }
            // 门店信息
            if (s.getStoreId() != null && s.getStoreId() > 0) {
                Store st = storeService.getById(s.getStoreId());
                if (st != null) {
                    s.setStoreName(st.getName());
                }
            } else {
                s.setStoreName("优童官方服务中心");
            }
            // 客服信息
            if (s.getCsId() != null && s.getCsId() > 0) {
                CustomerService cs = customerServiceService.getById(s.getCsId());
                if (cs != null) {
                    s.setCsName(cs.getName());
                    s.setCsAvatar(cs.getAvatar());
                }
            }
        }
    }

    /**
     * 更新会话的最后一条消息预览与未读数
     */
    public void updateLastMessage(Long sessionId, String content, String time, boolean isSenderUser) {
        ImSession session = getById(sessionId);
        if (session != null) {
            session.setLastMsgContent(content != null && content.length() > 200 ? content.substring(0, 200) + "..." : content);
            session.setLastMsgTime(time != null ? time : LocalDateTime.now().format(FMT));
            if (isSenderUser) {
                session.setUnreadCountCs((session.getUnreadCountCs() != null ? session.getUnreadCountCs() : 0) + 1);
            } else {
                session.setUnreadCountUser((session.getUnreadCountUser() != null ? session.getUnreadCountUser() : 0) + 1);
            }
            updateById(session);
        }
    }
}
