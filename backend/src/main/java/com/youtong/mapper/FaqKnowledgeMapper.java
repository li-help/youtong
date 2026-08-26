package com.youtong.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youtong.entity.FaqKnowledge;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Repository;

@Repository
public interface FaqKnowledgeMapper extends BaseMapper<FaqKnowledge> {
    
    @Update("UPDATE faq_knowledge SET hit_count = hit_count + 1 WHERE id = #{id}")
    void incrementHitCount(@Param("id") Long id);
}
