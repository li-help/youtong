package com.youtong.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youtong.entity.ImMessage;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Repository;

@Repository
public interface ImMessageMapper extends BaseMapper<ImMessage> {

    @Update("UPDATE im_message SET is_read = 1 WHERE session_id = #{sessionId} AND receiver_id = #{receiverId} AND is_read = 0")
    int markReadBySessionAndReceiver(@Param("sessionId") Long sessionId, @Param("receiverId") Long receiverId);
}
