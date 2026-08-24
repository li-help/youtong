package com.youtong.service;

import com.aliyun.dysmsapi20170525.Client;
import com.aliyun.dysmsapi20170525.models.SendSmsRequest;
import com.aliyun.dysmsapi20170525.models.SendSmsResponse;
import com.aliyun.teaopenapi.models.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * 阿里云短信发送服务。
 *
 * 配置（建议通过服务器环境变量注入，不要提交真实密钥到代码库）：
 *   ALIYUN_SMS_ACCESS_KEY_ID
 *   ALIYUN_SMS_ACCESS_KEY_SECRET
 *   ALIYUN_SMS_SIGN_NAME     短信签名
 *   ALIYUN_SMS_TEMPLATE_CODE 短信模板 CODE（模板需含 ${code} 变量）
 *   ALIYUN_SMS_ENDPOINT      默认 cn-hangzhou
 */
@Service
public class AliyunSmsService {

    @Value("${aliyun.sms.access-key-id:}")
    private String accessKeyId;

    @Value("${aliyun.sms.access-key-secret:}")
    private String accessKeySecret;

    @Value("${aliyun.sms.sign-name:}")
    private String signName;

    @Value("${aliyun.sms.template-code:}")
    private String templateCode;

    @Value("${aliyun.sms.endpoint:cn-hangzhou}")
    private String endpoint;

    private Client client;

    private synchronized Client getClient() throws Exception {
        if (client == null) {
            Config config = new Config()
                    .setAccessKeyId(accessKeyId)
                    .setAccessKeySecret(accessKeySecret)
                    .setEndpoint("dysmsapi." + endpoint + ".aliyuncs.com");
            client = new Client(config);
        }
        return client;
    }

    /**
     * 发送短信验证码。
     *
     * @param phone 手机号
     * @param code  验证码
     * @return 发送结果消息；失败抛异常
     */
    public String sendCode(String phone, String code) throws Exception {
        if (accessKeyId.isBlank() || accessKeySecret.isBlank()
                || signName.isBlank() || templateCode.isBlank()) {
            throw new IllegalStateException("阿里云短信未配置（缺少 accessKey/signName/templateCode）");
        }
        SendSmsRequest request = new SendSmsRequest()
                .setPhoneNumbers(phone)
                .setSignName(signName)
                .setTemplateCode(templateCode)
                .setTemplateParam("{\"code\":\"" + code + "\"}");
        SendSmsResponse response = getClient().sendSms(request);
        String bizCode = response.getBody().getCode();
        if (!"OK".equals(bizCode)) {
            throw new IllegalStateException("短信发送失败: " + bizCode
                    + " " + response.getBody().getMessage());
        }
        return bizCode;
    }
}
