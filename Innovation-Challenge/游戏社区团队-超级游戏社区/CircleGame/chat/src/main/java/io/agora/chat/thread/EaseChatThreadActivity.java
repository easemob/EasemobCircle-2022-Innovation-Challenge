package io.agora.chat.thread;

import static com.hyphenate.easeui.constants.EaseConstant.CONVERSATION_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_MSG_ID;
import static com.hyphenate.easeui.constants.EaseConstant.SERVER_ID;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.easeui.modules.chat.EaseChatFragment;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatInputChangeListener;
import com.hyphenate.easeui.ui.base.EaseBaseActivity;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.hyphenate.util.EMLog;
import com.jeremyliao.liveeventbus.LiveEventBus;

import io.agora.chat.R;
import io.agora.chat.databinding.EaseActivityThreadChatBinding;
import io.agora.chat.thread.interfaces.OnChatThreadRoleResultCallback;
import io.agora.chat.thread.interfaces.OnJoinChatThreadResultListener;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.global.Constants;
import io.agora.service.net.Resource;
import io.agora.service.net.Status;


public class EaseChatThreadActivity extends EaseBaseActivity {
    protected String parentMsgId;
    protected String conversationId;
    protected String serverId;
    protected EaseBaseActivity mContext;
    protected EaseActivityThreadChatBinding binding;
    protected EaseChatThreadRole threadRole = EaseChatThreadRole.UNKNOWN;
    // Usually is group id
    private String parentId;
    private String channelName;
    private String threadName;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        binding = EaseActivityThreadChatBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        mContext = this;
        initIntent(getIntent());
        initView();
        initListener();
        initData();
    }

    public void initIntent(Intent intent) {
        parentMsgId = intent.getStringExtra(PARENT_MSG_ID);
        conversationId = intent.getStringExtra(CONVERSATION_ID);
        serverId = intent.getStringExtra(SERVER_ID);
        parentId = intent.getStringExtra(PARENT_ID);
        channelName = intent.getStringExtra(Constants.CHANNEL_NAME);
        threadName = intent.getStringExtra(Constants.THREAD_NAME);
    }

    public void initView() {
        Fragment fragment = getSupportFragmentManager().findFragmentByTag("thread_chat");
        if (fragment == null) {
            EaseChatFragment.Builder builder = new EaseChatThreadFragment.Builder(parentMsgId, conversationId, parentId)
                    .setOnJoinThreadResultListener(new OnJoinChatThreadResultListener() {
                        @Override
                        public void joinSuccess(String threadId) {
                            joinChatThreadSuccess(threadId);
                        }

                        @Override
                        public void joinFailed(int errorCode, String message) {
                            joinChatThreadFailed(errorCode, message);
                        }
                    })
                    .setOnThreadRoleResultCallback(new OnChatThreadRoleResultCallback() {
                        @Override
                        public void onThreadRole(EaseChatThreadRole role) {
                            threadRole = role;
                        }
                    })
                    .useHeader(true)
                    .enableHeaderPressBack(true)
                    .setHeaderBackPressListener(new EaseTitleBar.OnBackPressListener() {
                        @Override
                        public void onBackPress(View view) {
                            onBackPressed();
                        }
                    })
                    .setEmptyLayout(io.agora.service.R.layout.circle_no_data)
                    .setOnChatInputChangeListener(new OnChatInputChangeListener() {
                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                            EMLog.e("TAG", "onTextChanged: s: " + s.toString());
                        }
                    })
                    .setChatBackground(io.agora.service.R.color.black_141414)
                    .hideSenderAvatar(true);
            setChildFragmentBuilder(builder);
            fragment = builder.build();
        }
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_fragment, fragment, "thread_chat").commit();
    }

    protected void joinChatThreadSuccess(String threadId) {

    }

    protected void joinChatThreadFailed(int errorCode, String message) {
        finish();
    }

    public void initListener() {
        binding.ivBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        binding.ivMore.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //跳转去子区设置页面
                LiveEventBus.get(Constants.SHOW_THREAD_SETTING_FRAGMENT, ThreadData.class).post(new ThreadData(threadName, conversationId, parentId, null, parentMsgId,serverId));
            }
        });
    }

    public void initData() {
        binding.tvChannelName.setText(channelName);
        binding.tvThreadName.setText(threadName);
    }

    public void setChildFragmentBuilder(EaseChatFragment.Builder builder) {

    }

    /**
     * Parse Resource<T>
     *
     * @param response
     * @param callback
     * @param <T>
     */
    public <T> void parseResource(Resource<T> response, @NonNull OnResourceParseCallback<T> callback) {
        if (response == null) {
            return;
        }
        if (response.status == Status.SUCCESS) {
            callback.onHideLoading();
            callback.onSuccess(response.data);
        } else if (response.status == Status.ERROR) {
            callback.onHideLoading();
            if (!callback.hideErrorMsg) {
                ToastUtils.showShort(response.getMessage(this));
            }
            callback.onError(response.errorCode, response.getMessage(this));
        } else if (response.status == Status.LOADING) {
            callback.onLoading(response.data);
        }
    }
}
