package com.youtong.common;

import java.util.HashMap;
import java.util.Map;

/**
 * 统一返回体，对齐前端 mock 的 { code:0, data, msg }
 */
public class R {
    private int code;
    private String msg;
    private Object data;

    public R(int code, String msg, Object data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public static R ok(Object data) {
        return new R(0, "ok", data);
    }

    public static R ok() {
        return new R(0, "ok", null);
    }

    public static R fail(String msg) {
        return new R(1, msg, null);
    }

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMsg() { return msg; }
    public void setMsg(String msg) { this.msg = msg; }
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }

    /** 构造分页返回结构 { list, total, page, pageSize } */
    public static Map<String, Object> page(long total, Object list, long page, long pageSize) {
        Map<String, Object> m = new HashMap<>();
        m.put("list", list);
        m.put("total", total);
        m.put("page", page);
        m.put("pageSize", pageSize);
        return m;
    }
}
