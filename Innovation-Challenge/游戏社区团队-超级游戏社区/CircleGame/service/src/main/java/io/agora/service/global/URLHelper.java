package io.agora.service.global;


import com.hyphenate.cloud.EMHttpClient;

/**
 * 备注：用户在这里应该使用自己公司的对应的url
 */
public class URLHelper {

    public final static String GET_RECOMMEND_SERVER_URL = getBaseUrl()+"/circle/server/recommend/list";
    public final static String UPLOAD_IMAGE_URL = getBaseUrl()+"/chatfiles";

    public static String getBaseUrl() {
        return EMHttpClient.getInstance().chatConfig().a(true, false);
    }
}
