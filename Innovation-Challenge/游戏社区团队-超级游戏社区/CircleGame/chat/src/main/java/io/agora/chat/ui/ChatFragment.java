package io.agora.chat.ui;

import static com.hyphenate.easeui.constants.EaseConstant.CHATTYPE_SINGLE;
import static com.hyphenate.easeui.constants.EaseConstant.CONVERSATION_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_MSG_ID;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.CacheDiskUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.domain.EaseUser;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.easeui.modules.chat.EaseChatFragment;
import com.hyphenate.easeui.modules.chat.EaseChatInputMenu;
import com.hyphenate.easeui.modules.chat.EaseChatMessageListLayout;
import com.hyphenate.easeui.modules.chat.EaseInputMenuStyle;
import com.hyphenate.easeui.modules.chat.interfaces.IChatExtendMenu;
import com.hyphenate.easeui.modules.chat.interfaces.IChatPrimaryMenu;
import com.hyphenate.easeui.modules.chat.interfaces.OnRecallMessageResultListener;
import com.hyphenate.easeui.modules.menu.EasePopupWindowHelper;
import com.hyphenate.easeui.modules.menu.MenuItemBean;
import com.hyphenate.easeui.utils.ShowMode;
import com.hyphenate.util.EMFileHelper;
import com.hyphenate.util.EMLog;
import com.jeremyliao.liveeventbus.LiveEventBus;
import com.tbruyelle.rxpermissions2.RxPermissions;

import java.util.Map;

import io.agora.chat.R;
import io.agora.service.bean.CustomInfo;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.model.ChannelViewModel;
import io.agora.service.model.ServerViewModel;
import io.agora.service.net.Resource;
import io.agora.service.net.Status;
import io.agora.service.utils.CircleUtils;


public class ChatFragment extends EaseChatFragment implements OnRecallMessageResultListener {
    private static final String TAG = ChatFragment.class.getSimpleName();
    private static final int REQUEST_CODE_SELECT_USER_CARD = 20;
    protected ClipboardManager clipboard;

    private static final int REQUEST_CODE_SELECT_AT_USER = 15;
    private static final String[] calls = {"视频通话", "语音通话"};
    private OnFragmentInfoListener infoListener;
    private Dialog dialog;
    private CircleChannel channel;
    private RxPermissions rxPermissions;
    private ShowMode showMode = ShowMode.NORMAL;
    private ServerViewModel serverViewModel;
    private ChannelViewModel channelViewModel;


    @Override
    public void initView() {
        super.initView();
        clipboard = (ClipboardManager) getActivity().getSystemService(Context.CLIPBOARD_SERVICE);

        Bundle bundle = getArguments();
        if (bundle != null) {
            channel = (CircleChannel) bundle.getSerializable(EaseConstant.CHANNEL);
        }
        showMode = (ShowMode) bundle.getSerializable(Constants.SHOW_MODE);

        //获取到聊天列表控件
        EaseChatMessageListLayout messageListLayout = chatLayout.getChatMessageListLayout();
        //设置聊天列表背景
        messageListLayout.setBackgroundColor(ContextCompat.getColor(mContext, io.agora.service.R.color.black_141414));
        //设置默认头像
        messageListLayout.setAvatarDefaultSrc(ContextCompat.getDrawable(mContext, io.agora.service.R.drawable.circle_default_avatar));
        //设置头像形状
        messageListLayout.setAvatarShapeType(1);
        //设置文本字体大小
        //messageListLayout.setItemTextSize((int) EaseCommonUtils.sp2px(mContext, 18));
        //设置文本字体颜色
//        messageListLayout.setItemTextColor(ContextCompat.getColor(mContext, R.color.white));
        //设置时间线的背景
        //messageListLayout.setTimeBackground(ContextCompat.getDrawable(mContext, R.color.gray_normal));
        //设置时间线的文本大小
        //messageListLayout.setTimeTextSize((int) EaseCommonUtils.sp2px(mContext, 18));
        //设置时间线的文本颜色
        //messageListLayout.setTimeTextColor(ContextCompat.getColor(mContext, R.color.black));
        // 获取到菜单输入父控件
        EaseChatInputMenu chatInputMenu = chatLayout.getChatInputMenu();
        //获取到菜单输入控件
        IChatPrimaryMenu primaryMenu = chatInputMenu.getPrimaryMenu();
        //设置聊天列表样式：两侧及均位于左侧
        messageListLayout.setItemShowType(EaseChatMessageListLayout.ShowType.LEFT);
        if (primaryMenu != null) {
//            设置菜单样式为不可用语音模式
            primaryMenu.setMenuShowType(EaseInputMenuStyle.DISABLE_VOICE);
        }
        if (showMode == ShowMode.NORMAL) {
            chatInputMenu.setVisibility(View.VISIBLE);
        } else if (showMode == ShowMode.SERVER_PREVIEW) {
            chatInputMenu.setVisibility(View.GONE);
        }
    }

    private void addItemMenuAction() {
        MenuItemBean itemMenu = new MenuItemBean(0, R.id.action_chat_forward, 11, getString(R.string.action_forward));
        itemMenu.setResourceId(R.drawable.ease_chat_item_menu_forward);
        chatLayout.addItemMenu(itemMenu);
    }

    private void resetChatExtendMenu() {
        IChatExtendMenu chatExtendMenu = chatLayout.getChatInputMenu().getChatExtendMenu();
        chatExtendMenu.clear();
        chatExtendMenu.registerMenuItem(R.string.attach_picture, R.drawable.ease_chat_image_selector, R.id.extend_item_picture);
        chatExtendMenu.registerMenuItem(R.string.attach_take_pic, R.drawable.ease_chat_takepic_selector, R.id.extend_item_take_picture);
//        chatExtendMenu.registerMenuItem(R.string.attach_video, R.drawable.em_chat_video_selector, R.id.extend_item_video);

        //添加扩展槽
        if (chatType == EaseConstant.CHATTYPE_SINGLE) {
            //inputMenu.registerExtendMenuItem(R.string.attach_voice_call, R.drawable.em_chat_voice_call_selector, EaseChatInputMenu.ITEM_VOICE_CALL, this);
//            chatExtendMenu.registerMenuItem(R.string.attach_media_call, R.drawable.em_chat_video_call_selector, R.id.extend_item_video_call);
        }
        if (chatType == EaseConstant.CHATTYPE_GROUP) { // 音视频会议
//            chatExtendMenu.registerMenuItem(R.string.voice_and_video_conference, R.drawable.em_chat_video_call_selector, R.id.extend_item_conference_call);
            //目前普通模式也支持设置主播和观众人数，都建议使用普通模式
            //inputMenu.registerExtendMenuItem(R.string.title_live, R.drawable.em_chat_video_call_selector, EaseChatInputMenu.ITEM_LIVE, this);
        }
//        chatExtendMenu.registerMenuItem(R.string.attach_location, R.drawable.ease_chat_location_selector, R.id.extend_item_location);
        chatExtendMenu.registerMenuItem(R.string.attach_file, R.drawable.em_chat_file_selector, R.id.extend_item_file);
        //名片扩展
//        chatExtendMenu.registerMenuItem(R.string.attach_user_card, R.drawable.em_chat_user_card_selector, R.id.extend_item_user_card);
        //群组类型，开启消息回执，且是owner
//        if(chatType == EaseConstant.CHATTYPE_GROUP && EMClient.getInstance().getOptions().getRequireAck()) {
//            EMGroup group = DemoHelper.getInstance().getGroupManager().getGroup(conversationId);
//            if(GroupHelper.isOwner(group)) {
//                chatExtendMenu.registerMenuItem(R.string.em_chat_group_delivery_ack, R.drawable.demo_chat_delivery_selector, R.id.extend_item_delivery);
//            }
//        }
        //添加扩展表情
//        chatLayout.getChatInputMenu().getEmojiconMenu().addEmojiconGroup(EmojiconExampleGroupData.getData());
    }

    public void initListener() {
        super.initListener();
        chatLayout.setOnRecallMessageResultListener(this);
        serverViewModel = new ViewModelProvider(this).get(ServerViewModel.class);
        channelViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        serverViewModel.checkSelfIsInServerLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<CustomInfo>() {
                @Override
                public void onSuccess(@Nullable CustomInfo data) {
                    if (data.isIn()) {
                        //弹框提示
                        ToastUtils.showShort(R.string.circle_have_joined_server);
                    } else {
                        //弹加入社区的框
                        CircleUtils.showServerInviteDialog(mContext, data);
                    }
                }
            });
        });
        channelViewModel.checkSelfIsInChannelLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<CustomInfo>() {
                @Override
                public void onSuccess(@Nullable CustomInfo data) {
                    if (data.isIn()) {
                        //弹框提示
                        ToastUtils.showShort(R.string.circle_have_joined_channel);
                    } else {
                        //弹加入频道的框
                        CircleUtils.showChannelInviteDialog(mContext, data);
                    }
                }
            });
        });
    }

    @Override
    public void initData() {
        super.initData();
        // where this is an Activity or Fragment instance
        rxPermissions = new RxPermissions(this);
        resetChatExtendMenu();
        addItemMenuAction();

        chatLayout.getChatInputMenu().getPrimaryMenu().getEditText().setText(getUnSendMsg());
        chatLayout.turnOnTypingMonitor(true);

        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).post(new EaseEvent(Constants.MESSAGE_CHANGE_CHANGE, EaseEvent.TYPE.MESSAGE));

        LiveEventBus.get(Constants.MESSAGE_CALL_SAVE, Boolean.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event) {
                chatLayout.getChatMessageListLayout().refreshToLatest();
            }
        });

        LiveEventBus.get(Constants.CONVERSATION_DELETE, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event.isMessageChange()) {
                chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event.isMessageChange()) {
                chatLayout.getChatMessageListLayout().refreshToLatest();
            }
        });
        LiveEventBus.get(Constants.CONVERSATION_READ, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event.isMessageChange()) {
                chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        //更新用户属性刷新列表
        LiveEventBus.get(Constants.CONTACT_ADD, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event != null) {
                chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });

        LiveEventBus.get(Constants.CONTACT_UPDATE, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            if (event == null) {
                return;
            }
            if (event != null) {
                chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });
        LiveEventBus.get(Constants.CHANNEL_CHANGED, CircleChannel.class).observe(this, circleChannel -> {
            if (circleChannel != null) {
                if (TextUtils.equals(conversationId, circleChannel.channelId)) {
                    channel = circleChannel;
                }
            }
        });
    }

    @Override
    public void onUserAvatarClick(String username) {
        if (showMode == ShowMode.NORMAL) {
            if (!TextUtils.equals(username, AppUserInfoManager.getInstance().getCurrentUserName())) {
                //跳转到详情页面
                ARouter.getInstance()
                        .build("/contacts/UserDetailActivity")
                        .withString(Constants.USERNAME, username)
                        .navigation();
            }
        }
    }

    @Override
    public void onUserAvatarLongClick(String username) {

    }

    @Override
    public boolean onBubbleLongClick(View v, EMMessage message) {
        if (showMode == ShowMode.NORMAL) {
            return false;
        } else if (showMode == ShowMode.SERVER_PREVIEW) {
            return true;
        }
        return false;
    }

    private void processLongClickEvent(EMMessage message) {
        if (message.getType() == EMMessage.Type.CUSTOM) {
            EMCustomMessageBody customBody = (EMCustomMessageBody) message.getBody();
            String event = customBody.event();
            if (customBody != null) {
                Map<String, String> params = customBody.getParams();
                String serverId = params.get(Constants.CUSTOM_MESSAGE_SERVER_ID);
                String serverName = params.get(Constants.CUSTOM_MESSAGE_SERVER_NAME);
                String serverDesc = params.get(Constants.CUSTOM_MESSAGE_SERVER_DESC);
                String serverIcon = params.get(Constants.CUSTOM_MESSAGE_SERVER_ICON);
                String channelId = params.get(Constants.CUSTOM_MESSAGE_CHANNEL_ID);
                String channelName = params.get(Constants.CUSTOM_MESSAGE_CHANNEL_NAME);
                String channelDesc = params.get(Constants.CUSTOM_MESSAGE_CHANNEL_DESC);

                CustomInfo customInfo = new CustomInfo();
                customInfo.setServerId(serverId);
                customInfo.setServerName(serverName);
                customInfo.setServerIcon(serverIcon);
                customInfo.setServerDesc(serverDesc);
                customInfo.setChannelId(channelId);
                customInfo.setChannelName(channelName);
                customInfo.setChannelDesc(channelDesc);
                customInfo.setInviter(message.getFrom());

                if (TextUtils.equals(event, Constants.INVITE_SERVER)) {
                    serverViewModel.checkSelfIsInServer(customInfo);
                } else if (TextUtils.equals(event, Constants.INVITE_CHANNEL)) {
                    channelViewModel.checkSelfIsInChannel(customInfo);
                }
            }
        }
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (!chatLayout.getChatMessageListLayout().isGroupChat()) {
            return;
        }
    }

    @Override
    protected void selectVideoFromLocal() {
        super.selectVideoFromLocal();
    }

    @Override
    public boolean onBubbleClick(EMMessage message) {
        if (showMode == ShowMode.NORMAL) {
            processLongClickEvent(message);
            return false;
        } else if (showMode == ShowMode.SERVER_PREVIEW) {
            return true;
        }
        return false;
    }

    @Override
    public void onChatExtendMenuItemClick(View view, int itemId) {
        if (itemId == com.hyphenate.easeui.R.id.extend_item_take_picture) {
            rxPermissions
                    .request(Manifest.permission.CAMERA,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            // All requested permissions are granted
                            selectPicFromCamera();
                        }
                    });
        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_picture) {
            rxPermissions
                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            // All requested permissions are granted
                            selectPicFromLocal();
                        }
                    });
        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_location) {
            startMapLocation(REQUEST_CODE_MAP);
        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_video) {
            rxPermissions
                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            selectVideoFromLocal();
                        }
                    });
        } else if (itemId == com.hyphenate.easeui.R.id.extend_item_file) {
            rxPermissions.request(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            selectFileFromLocal();
                        }
                    });
        }
    }

    @Override
    public void onChatError(int code, String errorMsg) {
        if (infoListener != null) {
            infoListener.onChatError(code, errorMsg);
        }
    }

    @Override
    public void onOtherTyping(String action) {
        if (infoListener != null) {
            infoListener.onOtherTyping(action);
        }
    }

    @Override
    public boolean onThreadClick(String messageId, String threadId, String parentId) {
        if (showMode == ShowMode.NORMAL) {
            skipToChatThreadActivity(messageId, threadId, parentId);
        }
        return super.onThreadClick(messageId, threadId, parentId);
    }

    @Override
    public boolean onThreadLongClick(View v, String messageId, String threadId, String parentId) {
        return super.onThreadLongClick(v, messageId, threadId, parentId);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            switch (requestCode) {
                case REQUEST_CODE_SELECT_AT_USER:
                    if (data != null) {
                        String username = data.getStringExtra("username");
                        chatLayout.inputAtUsername(username, false);
                    }
                    break;
                case REQUEST_CODE_SELECT_VIDEO: //send the video
                    if (data != null) {
                        int duration = data.getIntExtra("dur", 0);
                        String videoPath = data.getStringExtra("path");
                        String uriString = data.getStringExtra("uri");
                        EMLog.d(TAG, "path = " + videoPath + " uriString = " + uriString);
                        if (!TextUtils.isEmpty(videoPath)) {
                            chatLayout.sendVideoMessage(Uri.parse(videoPath), duration);
                        } else {
                            Uri videoUri = EMFileHelper.getInstance().formatInUri(uriString);
                            chatLayout.sendVideoMessage(videoUri, duration);
                        }
                    }
                    break;
                case REQUEST_CODE_SELECT_USER_CARD:
                    if (data != null) {
                        EaseUser user = (EaseUser) data.getSerializableExtra("user");
                        if (user != null) {
                            sendUserCardMessage(user);
                        }
                    }
                    break;
            }
        }
    }

    /**
     * Send user card message
     *
     * @param user
     */
    private void sendUserCardMessage(EaseUser user) {
    }

    @Override
    public void onStop() {
        super.onStop();
        //保存未发送的文本消息内容
        if (mContext != null && mContext.isFinishing()) {
            if (chatLayout.getChatInputMenu() != null) {
                saveUnSendMsg(chatLayout.getInputContent());
                LiveEventBus.get(Constants.MESSAGE_NOT_SEND).post(true);
            }
        }
    }

    //================================== for video and voice start ====================================

    /**
     * 保存未发送的文本消息内容
     *
     * @param content
     */
    private void saveUnSendMsg(String content) {
        CacheDiskUtils.getInstance().put(conversationId, content);
    }

    private String getUnSendMsg() {
        return CacheDiskUtils.getInstance().getString(conversationId);
    }

    @Override
    public void onPreMenu(EasePopupWindowHelper helper, EMMessage message, View view) {
        //默认两分钟后，即不可撤回
        if (System.currentTimeMillis() - message.getMsgTime() > 2 * 60 * 1000) {
            helper.findItemVisible(R.id.action_chat_recall, false);
        }
        EMMessage.Type type = message.getType();
        helper.findItemVisible(R.id.action_chat_forward, false);
        if (chatType == CHATTYPE_SINGLE) {
            helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_thread, false);
        }
    }

    @Override
    public boolean onMenuItemClick(MenuItemBean item, EMMessage message) {
        if (item.getItemId() == R.id.action_chat_delete) {
            showDeleteDialog(message);
            return true;
        } else if (item.getItemId() == R.id.action_chat_recall) {
            showProgressBar();
            chatLayout.recallMessage(message);
            return true;
        } else if (item.getItemId() == com.hyphenate.easeui.R.id.action_chat_thread) {
            //创建子区
            skipToCreateThread(message);
            return true;
        }
        return false;
    }

    private void skipToCreateThread(EMMessage message) {
        ARouter.getInstance().build("/app/ChatThreadCreateActivity")
                .withString(Constants.CHANNEL_ID, conversationId)
                .withString(Constants.MESSAGE_ID, message.getMsgId())
                .withSerializable(Constants.CHANNEL, channel)
                .navigation();
    }

    private void skipToChatThreadActivity(String messageId, String threadId, String parentId) {
        ARouter.getInstance().build("/app/ChatThreadActivity")
                .withString(CONVERSATION_ID, threadId)
                .withString(PARENT_MSG_ID, messageId)
                .withSerializable(PARENT_ID, parentId)
                .withString(Constants.CHANNEL_NAME, channel.name)
                .navigation();
    }

    private void showProgressBar() {
        View view = View.inflate(mContext, R.layout.demo_layout_progress_recall, null);
        dialog = new Dialog(mContext, R.style.dialog_recall);
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        dialog.setContentView(view, layoutParams);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();
    }

    private void showDeleteDialog(EMMessage message) {
    }

    public void setOnFragmentInfoListener(OnFragmentInfoListener listener) {
        this.infoListener = listener;
    }

    @Override
    public void recallSuccess(EMMessage message, EMMessage notification) {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    @Override
    public void recallFail(int code, String errorMsg) {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

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
//                ToastUtils.showShort(response.getMessage(getApplicationContext()));
            }
            callback.onError(response.errorCode, response.getMessage(mContext));
        } else if (response.status == Status.LOADING) {
            callback.onLoading(response.data);
        }
    }


    public interface OnFragmentInfoListener {
        void onChatError(int code, String errorMsg);

        void onOtherTyping(String action);
    }
}