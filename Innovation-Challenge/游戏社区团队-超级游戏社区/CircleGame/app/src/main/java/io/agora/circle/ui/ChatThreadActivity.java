package io.agora.circle.ui;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageReactionChange;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.interfaces.OnChatExtendMenuItemClickListener;
import com.hyphenate.easeui.interfaces.OnMessageSendCallBack;
import com.hyphenate.easeui.modules.chat.EaseChatFragment;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatRecordTouchListener;
import com.hyphenate.util.EMLog;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.List;

import io.agora.chat.thread.ChatThreadFragment;
import io.agora.chat.thread.EaseChatThreadActivity;
import io.agora.chat.thread.viewmodel.ChatThreadViewModel;
import io.agora.contacts.ui.ThreadSettingBottomFragment;
import io.agora.service.bean.ThreadData;
import io.agora.service.global.Constants;
import io.agora.service.permission.PermissionsManager;


@Route(path = "/app/ChatThreadActivity")
public class ChatThreadActivity extends EaseChatThreadActivity implements EMMessageListener {
    private ChatThreadViewModel viewModel;
    private boolean isReachLatestThreadMessage;

    public static void actionStart(Context context, String conversationId, String parentMsgId) {
        Intent intent = new Intent(context, ChatThreadActivity.class);
        intent.putExtra("parentMsgId", parentMsgId);
        intent.putExtra("conversationId", conversationId);
        context.startActivity(intent);
    }

    public static void actionStart(Context context, String conversationId, String parentMsgId, String parentId) {
        Intent intent = new Intent(context, ChatThreadActivity.class);
        intent.putExtra("parentMsgId", parentMsgId);
        intent.putExtra("conversationId", conversationId);
        intent.putExtra("parentId", parentId);
        context.startActivity(intent);
    }

    @Override
    public void setChildFragmentBuilder(EaseChatFragment.Builder builder) {
        super.setChildFragmentBuilder(builder);
        builder.setOnChatExtendMenuItemClickListener(new OnChatExtendMenuItemClickListener() {
                    @Override
                    public boolean onChatExtendMenuItemClick(View view, int itemId) {
                        EMLog.e("TAG", "onChatExtendMenuItemClick");
                        if (itemId == com.hyphenate.easeui.R.id.extend_item_take_picture) {
                            // check if has permissions
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.CAMERA)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                        , new String[]{Manifest.permission.CAMERA}, null);
                                return true;
                            }
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                        , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                return true;
                            }
                            return false;
                        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_picture || itemId == com.hyphenate.easeui.R.id.extend_item_file) {
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                        , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                return true;
                            }
                            return false;
                        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_video) {
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.CAMERA)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                        , new String[]{Manifest.permission.CAMERA}, null);
                                return true;
                            }
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                        , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                return true;
                            }
                            return false;
                        }
                        return false;
                    }
                })
                .setOnChatRecordTouchListener(new OnChatRecordTouchListener() {
                    @Override
                    public boolean onRecordTouch(View v, MotionEvent event) {
                        // Check if has record audio permission
                        if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.RECORD_AUDIO)) {
                            PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(mContext
                                    , new String[]{Manifest.permission.RECORD_AUDIO}, null);
                            return true;
                        }
                        return false;
                    }
                })
//        .setCustomAdapter(new ChatThreadCustomMessageAdapter())
                .setCustomFragment(new ChatThreadFragment())
                .setChatBackground(io.agora.service.R.color.black_141414)
                .setOnMessageSendCallBack(new OnMessageSendCallBack() {
                    @Override
                    public void onSuccess(EMMessage message) {
                        if (!isReachLatestThreadMessage) {
                            isReachLatestThreadMessage = message.getBooleanAttribute(EaseConstant.FLAG_REACH_LATEST_THREAD_MESSAGE, false);
                        }
                        if (!isReachLatestThreadMessage) {
                            ToastUtils.showShort(io.agora.chat.R.string.chat_thread_message_send_success);
                        }
                    }

                    @Override
                    public void onError(int code, String errorMsg) {
                        ToastUtils.showShort(errorMsg);
                    }
                });
    }

    @Override
    public void initListener() {
        super.initListener();
        EMClient.getInstance().chatManager().addMessageListener(this);
        LiveEventBus.get(Constants.SHOW_THREAD_SETTING_FRAGMENT, ThreadData.class).observe(this, new Observer<ThreadData>() {
            @Override
            public void onChanged(ThreadData threadData) {
                ThreadSettingBottomFragment fragment = new ThreadSettingBottomFragment();
                Bundle bundle = new Bundle();
                bundle.putSerializable(Constants.THREAD_DATA, threadData);
                fragment.setArguments(bundle);
                fragment.show(getSupportFragmentManager());
            }
        });
    }

    @Override
    public void initData() {
        super.initData();
        viewModel = new ViewModelProvider(this).get(ChatThreadViewModel.class);
        LiveEventBus.get(Constants.THREAD_LEAVE, ThreadData.class).observe(this, threadData -> {
            if (threadData != null && TextUtils.equals(threadData.getThreadId(), conversationId)) {
                finish();
            }
        });

        LiveEventBus.get(Constants.THREAD_DESTROY, ThreadData.class).observe(this, threadData -> {
            if (threadData != null && TextUtils.equals(threadData.getThreadId(), conversationId)) {
                finish();
            }
        });
        LiveEventBus.get(Constants.THREAD_UPDATE, ThreadData.class).observe(this, threadData -> {
            if (threadData != null && TextUtils.equals(threadData.getThreadId(), conversationId)) {
                binding.tvThreadName.setText(threadData.getThreadName());
            }
        });
    }

    @Override
    protected void joinChatThreadFailed(int errorCode, String message) {
        super.joinChatThreadFailed(errorCode, message);
        ToastUtils.showShort(message);
    }

    private void removeLocalMessage() {
        EMMessage message = EMClient.getInstance().chatManager().getMessage(parentMsgId);
        if (message != null) {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(message.conversationId());
            conversation.removeMessage(conversationId);
        }
    }

    @Override
    public void onMessageReceived(List<EMMessage> messages) {

    }

    @Override
    public void onReactionChanged(List<EMMessageReactionChange> messageReactionChangeList) {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EMClient.getInstance().chatManager().removeMessageListener(this);
    }
}
