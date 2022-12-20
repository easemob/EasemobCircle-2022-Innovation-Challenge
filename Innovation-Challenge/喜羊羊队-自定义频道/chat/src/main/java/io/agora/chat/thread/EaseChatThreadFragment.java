package io.agora.chat.thread;

import static com.hyphenate.easeui.modules.chat.EaseInputMenuStyle.DISABLE_VOICE;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.alibaba.android.arouter.launcher.ARouter;
import com.hyphenate.EMError;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.modules.chat.EaseChatFragment;
import com.hyphenate.easeui.modules.chat.interfaces.IChatExtendMenu;
import com.hyphenate.easeui.modules.chat.interfaces.OnRecallMessageResultListener;
import com.hyphenate.easeui.modules.menu.EaseChatType;
import com.hyphenate.easeui.modules.menu.EasePopupWindowHelper;

import java.util.ArrayList;
import java.util.List;

import io.agora.chat.R;
import io.agora.chat.thread.adapter.EaseChatThreadHeaderAdapter;
import io.agora.chat.thread.interfaces.EaseChatThreadParentMsgViewProvider;
import io.agora.chat.thread.interfaces.OnChatThreadRoleResultCallback;
import io.agora.chat.thread.interfaces.OnJoinChatThreadResultListener;
import io.agora.chat.thread.presenter.EaseChatThreadPresenter;
import io.agora.chat.thread.presenter.EaseChatThreadPresenterImpl;
import io.agora.chat.thread.presenter.IChatThreadView;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;


public class EaseChatThreadFragment extends EaseChatFragment implements IChatThreadView, OnRecallMessageResultListener {
    protected String parentMsgId;
    protected EMChatThread mThread;
    protected String parentId;
    protected EaseChatThreadRole threadRole = EaseChatThreadRole.UNKNOWN;

    protected EaseChatThreadPresenter mPresenter;
    private EaseChatThreadHeaderAdapter headerAdapter;
    private List<EMMessage> data = new ArrayList<>();
    private OnJoinChatThreadResultListener joinThreadResultListener;
    private OnChatThreadRoleResultCallback resultCallback;
    private boolean hideHeader;
    private EaseChatThreadParentMsgViewProvider parentMsgViewProvider;

    @Override
    public void initView() {
        super.initView();
        if (mPresenter == null) {
            mPresenter = new EaseChatThreadPresenterImpl();
        }
        mPresenter.attachView(this);
        if (mContext instanceof AppCompatActivity) {
            ((AppCompatActivity) mContext).getLifecycle().addObserver(mPresenter);
        }

        Bundle bundle = getArguments();
        if (bundle != null) {
            parentMsgId = bundle.getString(Constant.KEY_PARENT_MESSAGE_ID);
            parentId = bundle.getString(Constant.KEY_PARENT_ID);
            hideHeader = bundle.getBoolean(Constant.KEY_HIDE_HEADER, false);
        }
        if (mThread == null && parentMsgId != null) {
            EMMessage message = EMClient.getInstance().chatManager().getMessage(parentMsgId);
            if (message != null && (message.getChatType() == EMMessage.ChatType.GroupChat || message.getChatType() == EMMessage.ChatType.ChatRoom)) {
                parentId = message.getTo();
                data.clear();
                data.add(message);
            }
        }
        addHeaderViewToList();
        resetChatExtendMenu();
    }

    private void addHeaderViewToList() {
        if (hideHeader) {
            return;
        }
        headerAdapter = new EaseChatThreadHeaderAdapter(parentMsgViewProvider);
        chatLayout.getChatMessageListLayout().addHeaderAdapter(headerAdapter);
        chatLayout.getChatMessageListLayout().setBackgroundColor(getResources().getColor(io.agora.service.R.color.black_141414));
        chatLayout.getChatMessageListLayout().setAvatarShapeType(1);
        chatLayout.getChatInputMenu().getPrimaryMenu().setMenuShowType(DISABLE_VOICE);
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

    private void setThreadInfo(EMChatThread thread) {
        if (thread == null) {
            return;
        }
        if (headerAdapter != null) {
            headerAdapter.setThreadInfo(thread);
        }
    }

    @Override
    public void onPreMenu(EasePopupWindowHelper helper, EMMessage message, View v) {
        super.onPreMenu(helper, message, v);
        // Chat Thread is load from server, not need to delete from local
        helper.findItemVisible(R.id.action_chat_delete, false);
        // Chat Thread can not reply again
        helper.findItemVisible(R.id.action_chat_reply, false);
        if (!message.isChatThreadMessage() || message.direct() == EMMessage.Direct.RECEIVE) {
            helper.findItemVisible(R.id.action_chat_recall, false);
        }
    }

    @Override
    public void initListener() {
        super.initListener();
        chatLayout.setOnRecallMessageResultListener(this);
    }

    @Override
    public void onChatThreadEvent(int event, String target, List<String> usernames) {
        super.onChatThreadEvent(event, target, usernames);
        if ((event == THREAD_DESTROY || event == THREAD_LEAVE) && TextUtils.equals(target, conversationId)) {
            mContext.finish();
        }
    }

    @Override
    public void recallSuccess(EMMessage originalMessage, EMMessage notification) {
        if (chatLayout != null) {
            chatLayout.getChatMessageListLayout().removeMessage(originalMessage);
        }
    }

    @Override
    public void recallFail(int code, String errorMsg) {

    }

    @Override
    public void onChatThreadUpdated(EMChatThreadEvent event) {
        if (TextUtils.equals(event.getChatThread().getChatThreadId(), conversationId)) {
            runOnUiThread(() -> {
                chatLayout.getChatMessageListLayout().refreshMessages();
                if (headerAdapter != null) {
                    headerAdapter.updateThreadName(event.getChatThread().getChatThreadName());
                }
            });
        }
    }

    @Override
    public void onChatThreadDestroyed(EMChatThreadEvent event) {
        exitThreadChat(event.getChatThread().getChatThreadId());
    }

    @Override
    public void onChatThreadUserRemoved(EMChatThreadEvent event) {
        exitThreadChat(event.getChatThread().getChatThreadId());
    }

    private void exitThreadChat(String threadId) {
        if (TextUtils.equals(threadId, conversationId)) {
            mContext.finish();
        }
    }

    @Override
    public void initData() {
        initChatLayout();
        setThreadInfo(mThread);
        if (headerAdapter != null) {
            headerAdapter.setData(data);
        }
        joinThread();
        setGroupInfo();
    }


    private void setGroupInfo() {
        if (TextUtils.isEmpty(parentId)) {
            return;
        }
        mPresenter.getGroupInfo(parentId);
    }

    private void joinThread() {
        mPresenter.joinThread(conversationId);
    }

    @Override
    public Context context() {
        return mContext;
    }

    @Override
    public void onGetThreadInfoSuccess(EMChatThread thread) {
        mThread = thread;
        setThreadInfo(thread);
        getThreadRole(mThread);
    }

    @Override
    public void onGetThreadInfoFail(int error, String errorMsg) {

    }

    @Override
    public void OnJoinThreadSuccess(EMChatThread thread) {
        if (joinThreadResultListener != null) {
            joinThreadResultListener.joinSuccess(conversationId);
        }
        mThread = thread;
        setThreadInfo(thread);
        getThreadRole(mThread);
        if (threadRole != EaseChatThreadRole.GROUP_ADMIN && threadRole != EaseChatThreadRole.CREATOR) {
            threadRole = EaseChatThreadRole.MEMBER;
            if (resultCallback != null) {
                resultCallback.onThreadRole(threadRole);
            }
        }
        runOnUiThread(() -> {
            loadData();
            isMessageInit = true;
        });
    }

    @Override
    public void OnJoinThreadFail(int error, String errorMsg) {
        if (error == EMError.USER_ALREADY_EXIST) {
            // If has joined the chat thread, make the role to member
            if (threadRole == EaseChatThreadRole.UNKNOWN) {
                threadRole = EaseChatThreadRole.MEMBER;
            }
            mPresenter.getThreadInfo(conversationId);
            runOnUiThread(() -> {
                loadData();
                isMessageInit = true;
            });
        } else {
            if (joinThreadResultListener != null) {
                joinThreadResultListener.joinFailed(error, errorMsg);
            }
        }
    }

    @Override
    public void onGetGroupInfoSuccess(EMGroup group) {
        if (isGroupAdmin(group)) {
            threadRole = EaseChatThreadRole.GROUP_ADMIN;
            if (resultCallback != null) {
                resultCallback.onThreadRole(threadRole);
            }
        }
    }

    @Override
    public void onGetGroupInfoFail(int error, String errorMsg) {

    }

    @Override
    public void onUserAvatarClick(String username) {
        super.onUserAvatarClick(username);
        if (!TextUtils.equals(username, AppUserInfoManager.getInstance().getCurrentUserName())) {
            //跳转到详情页面
            ARouter.getInstance()
                    .build("/contacts/UserDetailActivity")
                    .withString(Constants.USERNAME, username)
                    .navigation();
        }
    }

    private void setParentMsgViewProvider(EaseChatThreadParentMsgViewProvider parentMsgViewProvider) {
        this.parentMsgViewProvider = parentMsgViewProvider;
    }

    private void setThreadPresenter(EaseChatThreadPresenter presenter) {
        this.mPresenter = presenter;
    }

    private void setOnJoinThreadResultListener(OnJoinChatThreadResultListener listener) {
        this.joinThreadResultListener = listener;
    }

    private void setOnThreadRoleResultCallback(OnChatThreadRoleResultCallback callback) {
        this.resultCallback = callback;
    }

    private EaseChatThreadRole getThreadRole(EMChatThread thread) {
        if (threadRole == EaseChatThreadRole.GROUP_ADMIN) {
            return threadRole;
        }
        if (thread != null) {
            if (TextUtils.equals(thread.getOwner(), EMClient.getInstance().getCurrentUser())) {
                threadRole = EaseChatThreadRole.CREATOR;
            }
        }
        if (resultCallback != null) {
            resultCallback.onThreadRole(threadRole);
        }
        return threadRole;
    }

    /**
     * Judge whether current user is group admin
     *
     * @param group
     * @return
     */
    public boolean isGroupAdmin(EMGroup group) {
        if (group == null) {
            return false;
        }
        return TextUtils.equals(group.getOwner(), EMClient.getInstance().getCurrentUser()) ||
                (group.getAdminList() != null &&
                        group.getAdminList().contains(EMClient.getInstance().getCurrentUser()));
    }

    public static class Builder extends EaseChatFragment.Builder {
        private EaseChatThreadPresenter presenter;
        private OnJoinChatThreadResultListener listener;
        private OnChatThreadRoleResultCallback resultCallback;
        private EaseChatThreadParentMsgViewProvider parentMsgViewProvider;

        /**
         * Constructor
         *
         * @param parentMsgId    Usually is the group message ID
         * @param conversationId Agora Chat ID
         */
        public Builder(String parentMsgId, String conversationId, String parentId) {
            super(conversationId, EaseChatType.GROUP_CHAT);
            this.bundle.putString(Constant.KEY_PARENT_MESSAGE_ID, parentMsgId);
            this.bundle.putString(Constant.KEY_PARENT_ID, parentId);
            this.bundle.putBoolean(Constant.KEY_THREAD_MESSAGE_FLAG, true);
        }

        /**
         * Constructor
         *
         * @param parentMsgId    Usually is the group ID
         * @param conversationId Agora Chat ID
         * @param historyMsgId
         */
        public Builder(String parentMsgId, String conversationId, String parentId, String historyMsgId) {
            super(conversationId, EaseChatType.GROUP_CHAT, historyMsgId);
            this.bundle.putString(Constant.KEY_PARENT_MESSAGE_ID, parentMsgId);
            this.bundle.putString(Constant.KEY_PARENT_ID, parentId);
            this.bundle.putBoolean(Constant.KEY_THREAD_MESSAGE_FLAG, true);
        }

        /**
         * Set header adapter hidden.
         *
         * @param hideHeader
         * @return
         */
        public Builder hideHeader(boolean hideHeader) {
            this.bundle.putBoolean(Constant.KEY_HIDE_HEADER, hideHeader);
            return this;
        }

        /**
         * Set thread parent message view provider
         *
         * @param provider
         * @return
         */
        public Builder setThreadParentMsgViewProvider(EaseChatThreadParentMsgViewProvider provider) {
            this.parentMsgViewProvider = provider;
            return this;
        }

        /**
         * Set custom thread presenter if you want to add your logic
         *
         * @param presenter
         * @return
         */
        public Builder setThreadPresenter(EaseChatThreadPresenter presenter) {
            this.presenter = presenter;
            return this;
        }

        /**
         * Set join thread listener
         *
         * @param listener
         * @return
         */
        public Builder setOnJoinThreadResultListener(OnJoinChatThreadResultListener listener) {
            this.listener = listener;
            return this;
        }

        /**
         * Set thread role callback
         *
         * @param callback
         * @return
         */
        public Builder setOnThreadRoleResultCallback(OnChatThreadRoleResultCallback callback) {
            this.resultCallback = callback;
            return this;
        }

        @Override
        public EaseChatFragment build() {
            if (this.customFragment == null) {
                this.customFragment = new EaseChatThreadFragment();
            }
            setThreadMessage(true);
            if (this.customFragment instanceof EaseChatThreadFragment) {
                ((EaseChatThreadFragment) this.customFragment).setParentMsgViewProvider(this.parentMsgViewProvider);
                ((EaseChatThreadFragment) this.customFragment).setThreadPresenter(this.presenter);
                ((EaseChatThreadFragment) this.customFragment).setOnJoinThreadResultListener(this.listener);
                ((EaseChatThreadFragment) this.customFragment).setOnThreadRoleResultCallback(this.resultCallback);
            }

            return super.build();
        }
    }

    private static final class Constant {
        public static final String KEY_PARENT_MESSAGE_ID = "key_parent_message_id";
        public static final String KEY_PARENT_ID = "key_parent_id";
        public static final String KEY_THREAD_MESSAGE_FLAG = "key_thread_message_flag";
        public static final String KEY_HIDE_HEADER = "key_hide_header";
    }

}
