package io.agora.circle;

import com.hyphenate.easeui.delegate.EaseCustomAdapterDelegate;
import com.hyphenate.easeui.delegate.EaseExpressionAdapterDelegate;
import com.hyphenate.easeui.delegate.EaseLocationAdapterDelegate;
import com.hyphenate.easeui.delegate.EaseTextAdapterDelegate;
import com.hyphenate.easeui.delegate.EaseVideoAdapterDelegate;
import com.hyphenate.easeui.delegate.EaseVoiceAdapterDelegate;
import com.hyphenate.easeui.manager.EaseMessageTypeSetManager;

import java.util.concurrent.TimeUnit;

import io.agora.chat.delegate.CircleFileAdapterDelegate;
import io.agora.chat.delegate.CircleImageAdapterDelegate;
import io.agora.chat.delegate.CircleInviteAdapterDelegate;
import io.agora.chat.delegate.CircleTextAdapterDelegate;
import io.agora.chat.thread.adapter.ChatThreadCustomMessageAdapterDelegate;
import io.agora.game.app.GameInit;
import io.agora.game.net.ApiService;
import io.agora.service.BaseApplication;
import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

public class AppApplication extends BaseApplication {


    @Override
    public void onCreate() {
        super.onCreate();
        GameInit.getGameInit().initHttp();
        registerConversationType();
    }

    /**
     * 注册对话类型
     */
    private void registerConversationType() {
        EaseMessageTypeSetManager.getInstance()
                .addMessageType(EaseExpressionAdapterDelegate.class)       //自定义表情
                .addMessageType(CircleFileAdapterDelegate.class)
                .addMessageType(CircleImageAdapterDelegate.class)
                .addMessageType(CircleInviteAdapterDelegate.class)
                .addMessageType(EaseLocationAdapterDelegate.class)         //定位
                .addMessageType(EaseVideoAdapterDelegate.class)            //视频
                .addMessageType(EaseVoiceAdapterDelegate.class)            //声音
                .addMessageType(EaseCustomAdapterDelegate.class)           //自定义消息
                .addMessageType(CircleTextAdapterDelegate.class)
                .addMessageType(ChatThreadCustomMessageAdapterDelegate.class)
                .setDefaultMessageType(EaseTextAdapterDelegate.class);       //文本
    }


}


