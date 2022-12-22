package io.agora.circle.ui;

import static io.agora.service.global.Constants.CHANNEL;
import static io.agora.service.global.Constants.CHATTYPE_GROUP;
import static io.agora.service.global.Constants.CHATTYPE_SINGLE;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.example.zhouwei.library.CustomPopWindow;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.easeui.EaseIM;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.domain.EaseUser;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.easeui.provider.EaseUserProfileProvider;
import com.hyphenate.easeui.utils.ShowMode;
import com.jeremyliao.liveeventbus.LiveEventBus;

import io.agora.chat.ui.ChatFragment;
import io.agora.chat.viewmodel.ChatViewModel;
import io.agora.circle.R;
import io.agora.circle.databinding.ActivityChatBinding;
import io.agora.common.dialog.AlertDialog;
import io.agora.contacts.ui.ChannelSettingBottomFragment;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;
import io.agora.service.utils.GroupHelper;

@Route(path = "/chat/ChatActivity")
public class ChatActivity extends BaseInitActivity<ActivityChatBinding> implements ChatFragment.OnFragmentInfoListener, View.OnClickListener {

    private CircleChannel channel;
    private String conversationId;
    private int chatType;
    private ChatFragment fragment;
    private String historyMsgId;
    private ChatViewModel viewModel;
    private boolean isChannel = false;
    private CustomPopWindow mCustomPopWindow;
    private AlertDialog dialog;
    private ShowMode showMode = ShowMode.NORMAL;

    public static void actionStart(Context context, String conversationId, int chatType) {
        Intent intent = new Intent(context, ChatActivity.class);
        intent.putExtra(EaseConstant.EXTRA_CONVERSATION_ID, conversationId);
        intent.putExtra(EaseConstant.EXTRA_CHAT_TYPE, chatType);
        context.startActivity(intent);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        initListener();
    }

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_chat;
    }


    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);

        channel = (CircleChannel) getIntent().getSerializableExtra(CHANNEL);
        conversationId = getIntent().getStringExtra(EaseConstant.EXTRA_CONVERSATION_ID);
        chatType = getIntent().getIntExtra(EaseConstant.EXTRA_CHAT_TYPE, EaseConstant.CHATTYPE_SINGLE);
        historyMsgId = getIntent().getStringExtra(Constants.HISTORY_MSG_ID);
        showMode = (ShowMode) getIntent().getSerializableExtra(Constants.SHOW_MODE);
        if (showMode == null) {
            showMode = ShowMode.NORMAL;
        }
        isChannel = (channel == null) ? false : true;

        initChatFragment();
    }

    private void initChatFragment() {
        fragment = new ChatFragment();
        Bundle bundle = new Bundle();
        bundle.putString(EaseConstant.EXTRA_CONVERSATION_ID, conversationId);
        bundle.putInt(EaseConstant.EXTRA_CHAT_TYPE, chatType);
        bundle.putString(Constants.HISTORY_MSG_ID, historyMsgId);
        bundle.putBoolean(EaseConstant.EXTRA_IS_ROAM, chatType == CHATTYPE_SINGLE ? false : true);
        bundle.putBoolean(EaseConstant.IS_CHANNEL, isChannel);
        bundle.putSerializable(EaseConstant.CHANNEL, channel);
        bundle.putSerializable(EaseConstant.SHOW_MODE, showMode);
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_fragment, fragment, "chat").commit();
    }

    protected void initListener() {
        fragment.setOnFragmentInfoListener(this);
        mBinding.ivBack.setOnClickListener(this);
        mBinding.ivMore.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_back) {
            onBackPressed();
        } else if (v.getId() == R.id.iv_more) {
            if (showMode == ShowMode.NORMAL) {
                if ((chatType == CHATTYPE_GROUP) && isChannel) {
                    LiveEventBus.get(Constants.SHOW_CHANNEL_SETTING_FRAGMENT, CircleChannel.class).post(channel);
                } else if (chatType == CHATTYPE_SINGLE) {
                    //弹框删除会话
                    showDeleteConversationPopWindow(v);
                }
            } else {
                ToastUtils.showShort(getString(io.agora.service.R.string.circle_preview_mode));
            }
        }
    }

    private void showDeleteConversationPopWindow(View locationView) {

        View contentView = LayoutInflater.from(this).inflate(R.layout.delete_conversation_menu, (ViewGroup) getWindow().getDecorView(), false);
        //处理popWindow 显示内容
        handleLogic(contentView);

        //显示PopupWindow
        mCustomPopWindow = new CustomPopWindow.PopupWindowBuilder(this)
                .setView(contentView)
                .size(ConvertUtils.dp2px(104), ConvertUtils.dp2px(36))
                .setFocusable(true)
                .setOutsideTouchable(true)
                .create()
                .showAsDropDown(locationView, ConvertUtils.dp2px(-70), 40);

    }

    /**
     * 处理弹出显示内容、点击事件等逻辑
     *
     * @param contentView
     */
    private void handleLogic(View contentView) {
        View.OnClickListener listener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCustomPopWindow != null) {
                    mCustomPopWindow.dissmiss();
                }
                int id = v.getId();
                if (id == R.id.tv_delete_conversation) {
                    showDeleteDialog();
                }
            }
        };
        contentView.findViewById(R.id.tv_delete_conversation).setOnClickListener(listener);
    }

    private void showDeleteDialog() {

        dialog = new AlertDialog.Builder(this)
                .setContentView(R.layout.dialog_delete_conversation)
                .setOnClickListener(io.agora.contacts.R.id.tv_confirm, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        viewModel.deleteConversationById(conversationId);
                        dialog.dismiss();
                    }
                })
                .setOnClickListener(io.agora.contacts.R.id.tv_cancel, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dialog.dismiss();
                    }
                })
                .show();

    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (intent != null) {
            initView(null);
            initConfig();
            initData();
        }
    }

    @Override
    protected void initData() {
        super.initData();
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conversationId);
        viewModel = new ViewModelProvider(this).get(ChatViewModel.class);
        viewModel.getChatRoomObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<EMChatRoom>() {
                @Override
                public void onSuccess(@Nullable EMChatRoom data) {
                    setDefaultTitle();
                }
            });
        });

        viewModel.deleteConversationLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(@Nullable String conversationId) {
                    //发送通知
                    LiveEventBus.get(Constants.CONVERSATION_DELETE).post(new EaseEvent(Constants.CONVERSATION_DELETE, EaseEvent.TYPE.MESSAGE));
                    finish();
                }
            });
        });

        LiveEventBus.get(Constants.SHOW_CHANNEL_SETTING_FRAGMENT, CircleChannel.class).observe(this, new Observer<CircleChannel>() {
            @Override
            public void onChanged(CircleChannel channel) {
                ChannelSettingBottomFragment fragment = new ChannelSettingBottomFragment();
                Bundle bundle = new Bundle();
                bundle.putSerializable(CHANNEL, channel);
                fragment.setArguments(bundle);
                fragment.show(getSupportFragmentManager());
            }
        });
        LiveEventBus.get(Constants.GROUP_CHANGE, EaseEvent.class).observe(this, event -> {
            if (event == null) {
                return;
            }
            if (event.isGroupLeave() && TextUtils.equals(conversationId, event.message)) {
                finish();
            }
        });
        LiveEventBus.get(Constants.CHAT_ROOM_CHANGE, EaseEvent.class).observe(this, event -> {
            if (event == null) {
                return;
            }
            if (event.isChatRoomLeave() && TextUtils.equals(conversationId, event.message)) {
                finish();
            }
        });
        LiveEventBus.get(Constants.MESSAGE_FORWARD, EaseEvent.class).observe(this, event -> {
            if (event == null) {
                return;
            }
            if (event.isMessageChange()) {
                showSnackBar(event.event);
            }
        });
        LiveEventBus.get(Constants.CONTACT_CHANGE, EaseEvent.class).observe(this, event -> {
            if (event == null) {
                return;
            }
            if (conversation == null) {
                finish();
            }
        });
        LiveEventBus.get(Constants.THREAD_LEAVE, ThreadData.class).observe(this, threadData -> {
            if (threadData != null) {
                fragment.chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        LiveEventBus.get(Constants.THREAD_DESTROY, ThreadData.class).observe(this, threadData -> {
            if (threadData != null) {
                fragment.chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        LiveEventBus.get(Constants.CHANNEL_DELETE, CircleChannel.class).observe(this, circleChannel -> {
            if (circleChannel != null) {
                if (TextUtils.equals(conversationId, circleChannel.channelId)) {
                    finish();
                }
            }
        });
        LiveEventBus.get(Constants.CHANNEL_LEAVE, CircleChannel.class).observe(this, circleChannel -> {
            if (circleChannel != null) {
                if (TextUtils.equals(conversationId, circleChannel.channelId)) {
                    finish();
                }
            }
        });
        LiveEventBus.get(Constants.CHANNEL_CHANGED, CircleChannel.class).observe(this, circleChannel -> {
            if (circleChannel != null) {
                if (TextUtils.equals(conversationId, circleChannel.channelId)) {
                    channel = circleChannel;
                    setDefaultTitle();
                }
            }
        });
        //刷新用户图像等个人信息
        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(this, obj -> {
            if (obj != null) {
                fragment.chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        setDefaultTitle();
        if (showMode == ShowMode.SERVER_PREVIEW) {
            ToastUtils.showShort(getString(io.agora.service.R.string.circle_preview_mode));
        }
    }

    private void showSnackBar(String event) {
//        Snackbar.make(titleBarMessage, event, Snackbar.LENGTH_SHORT).show();
    }

    private void setDefaultTitle() {
        String title;
        if (chatType == Constants.CHATTYPE_GROUP) {
            if (channel != null) {
                title = "#" + channel.name;
            } else {
                title = GroupHelper.getGroupName(conversationId);
            }
        } else if (chatType == Constants.CHATTYPE_CHATROOM) {
            EMChatRoom room = EMClient.getInstance().chatroomManager().getChatRoom(conversationId);
            if (room == null) {
                viewModel.getChatRoom(conversationId);
                return;
            }
            title = TextUtils.isEmpty(room.getName()) ? conversationId : room.getName();
        } else {
            EaseUserProfileProvider userProvider = EaseIM.getInstance().getUserProvider();
            if (userProvider != null) {
                EaseUser user = userProvider.getUser(conversationId);
                if (user != null) {
                    title = user.getNickname();
                } else {
                    title = conversationId;
                }
            } else {
                title = conversationId;
            }
        }
        mBinding.tvName.setText(title);
    }

    @Override
    public void onChatError(int code, String errorMsg) {
//        ToastUtils.showShort(errorMsg);
    }

    @Override
    public void onOtherTyping(String action) {
        if (TextUtils.equals(action, "TypingBegin")) {
            mBinding.tvName.setText(getString(com.hyphenate.easeui.R.string.alert_during_typing));
        } else if (TextUtils.equals(action, "TypingEnd")) {
            setDefaultTitle();
        }
    }

}
