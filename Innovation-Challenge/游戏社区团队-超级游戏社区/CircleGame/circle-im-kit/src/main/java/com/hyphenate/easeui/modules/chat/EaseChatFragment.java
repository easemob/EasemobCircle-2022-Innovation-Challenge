package com.hyphenate.easeui.modules.chat;

import android.app.Activity;
import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.ColorInt;
import androidx.annotation.DrawableRes;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.hyphenate.EMChatThreadChangeListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.R;
import com.hyphenate.easeui.adapter.EaseMessageAdapter;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.interfaces.OnChatExtendMenuItemClickListener;
import com.hyphenate.easeui.interfaces.OnMessageItemClickListener;
import com.hyphenate.easeui.interfaces.OnMessageSendCallBack;
import com.hyphenate.easeui.interfaces.OnReactionMessageListener;
import com.hyphenate.easeui.manager.EaseDingMessageHelper;
import com.hyphenate.easeui.modules.chat.interfaces.OnAddMsgAttrsBeforeSendEvent;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatInputChangeListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatLayoutFinishInflateListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatLayoutListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatRecordTouchListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnMenuChangeListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnPeerTypingListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnTranslateMessageListener;
import com.hyphenate.easeui.modules.menu.EaseChatType;
import com.hyphenate.easeui.modules.menu.EasePopupWindowHelper;
import com.hyphenate.easeui.modules.menu.MenuItemBean;
import com.hyphenate.easeui.ui.EaseBaiduMapActivity;
import com.hyphenate.easeui.ui.base.EaseBaseFragment;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseCompat;
import com.hyphenate.easeui.utils.EaseFileUtils;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.PathUtil;
import com.hyphenate.util.VersionUtils;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class EaseChatFragment extends EaseBaseFragment implements OnChatLayoutListener, OnMenuChangeListener,
        OnAddMsgAttrsBeforeSendEvent, OnChatRecordTouchListener, OnTranslateMessageListener, EMChatThreadChangeListener, EMMultiDeviceListener {
    protected static final int REQUEST_CODE_MAP = 1;
    protected static final int REQUEST_CODE_CAMERA = 2;
    protected static final int REQUEST_CODE_LOCAL = 3;
    protected static final int REQUEST_CODE_DING_MSG = 4;
    protected static final int REQUEST_CODE_SELECT_VIDEO = 11;
    protected static final int REQUEST_CODE_SELECT_FILE = 12;
    private static final String TAG = EaseChatFragment.class.getSimpleName();
    public EaseChatLayout chatLayout;
    public String conversationId;
    public int chatType;
    public String historyMsgId;
    public boolean isRoam;
    public boolean isMessageInit;
    private OnChatLayoutListener listener;

    protected File cameraFile;

    public boolean isThread;
    private boolean isChannel = false;
    private OnChatLayoutFinishInflateListener finishInflateListener;
    private OnReactionMessageListener reactionMessageListener;
    private EaseTitleBar.OnBackPressListener backPressListener;
    private OnChatExtendMenuItemClickListener extendMenuItemClickListener;
    private OnChatInputChangeListener chatInputChangeListener;
    private OnMessageItemClickListener chatItemClickListener;
    private OnMessageSendCallBack messageSendCallBack;
    private OnPeerTypingListener otherTypingListener;
    private OnAddMsgAttrsBeforeSendEvent sendMsgEvent;
    private OnChatRecordTouchListener recordTouchListener;
    private EaseMessageAdapter messageAdapter;
    private boolean sendOriginalImage;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        initArguments();
        return inflater.inflate(getLayoutId(), null);
    }

    private int getLayoutId() {
        return R.layout.ease_fragment_chat_list;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
        initListener();
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
    }

    public void initArguments() {
        Bundle bundle = getArguments();
        if (bundle != null) {
            conversationId = bundle.getString(EaseConstant.EXTRA_CONVERSATION_ID);
            chatType = bundle.getInt(EaseConstant.EXTRA_CHAT_TYPE, EaseConstant.CHATTYPE_SINGLE);
            historyMsgId = bundle.getString(EaseConstant.HISTORY_MSG_ID);
            isRoam = bundle.getBoolean(EaseConstant.EXTRA_IS_ROAM, false);
            isChannel = bundle.getBoolean(EaseConstant.IS_CHANNEL, false);
            isThread = bundle.getBoolean(Constant.KEY_THREAD_MESSAGE_FLAG, false);
        }
    }

    public void initView() {
        chatLayout = findViewById(R.id.layout_chat);
        chatLayout.getChatMessageListLayout().setItemShowType(EaseChatMessageListLayout.ShowType.NORMAL);

//        if(this.messageAdapter != null) {
//            chatLayout.getChatMessageListLayout().setMessageAdapter(this.messageAdapter);
//        }
        chatLayout.getChatMessageListLayout().setItemShowType(EaseChatMessageListLayout.ShowType.LEFT);
        Bundle bundle = getArguments();
        if (bundle != null) {

            int timeColor = bundle.getInt(Constant.KEY_MSG_TIME_COLOR, -1);
            if (timeColor != -1) {
                chatLayout.getChatMessageListLayout().setTimeTextColor(timeColor);
            }
            int timeTextSize = bundle.getInt(Constant.KEY_MSG_TIME_SIZE, -1);
            if (timeTextSize != -1) {
                chatLayout.getChatMessageListLayout().setTimeTextSize(timeTextSize);
            }
            int leftBubbleBg = bundle.getInt(Constant.KEY_MSG_LEFT_BUBBLE, -1);
            if (leftBubbleBg != -1) {
                chatLayout.getChatMessageListLayout().setItemSenderBackground(ContextCompat.getDrawable(mContext, leftBubbleBg));
            }
            int rightBubbleBg = bundle.getInt(Constant.KEY_MSG_RIGHT_BUBBLE, -1);
            if (rightBubbleBg != -1) {
                chatLayout.getChatMessageListLayout().setItemReceiverBackground(ContextCompat.getDrawable(mContext, leftBubbleBg));
            }
            boolean showNickname = bundle.getBoolean(Constant.KEY_SHOW_NICKNAME, false);
            chatLayout.getChatMessageListLayout().showNickname(showNickname);
            String messageListShowType = bundle.getString(Constant.KEY_MESSAGE_LIST_SHOW_STYLE, "");
            if (!TextUtils.isEmpty(messageListShowType)) {
                EaseChatMessageListLayout.ShowType showType = EaseChatMessageListLayout.ShowType.valueOf(messageListShowType);
                if (showType != null) {
                    chatLayout.getChatMessageListLayout().setItemShowType(showType);
                }
            }
//            boolean hideReceiveAvatar = bundle.getBoolean(Constant.KEY_HIDE_RECEIVE_AVATAR, false);
//            chatLayout.getChatMessageListLayout().hideChatReceiveAvatar(hideReceiveAvatar);
//            boolean hideSendAvatar = bundle.getBoolean(Constant.KEY_HIDE_SEND_AVATAR, false);
//            chatLayout.getChatMessageListLayout().hideChatSendAvatar(hideSendAvatar);
            boolean turnOnTypingMonitor = bundle.getBoolean(Constant.KEY_TURN_ON_TYPING_MONITOR, false);
            chatLayout.turnOnTypingMonitor(turnOnTypingMonitor);
            int chatBg = bundle.getInt(Constant.KEY_CHAT_BACKGROUND, -1);
            if (chatBg != -1) {
                chatLayout.getChatMessageListLayout().setBackgroundResource(chatBg);
            }
            String chatMenuStyle = bundle.getString(Constant.KEY_CHAT_MENU_STYLE, "");
            if (!TextUtils.isEmpty(chatMenuStyle)) {
                EaseInputMenuStyle menuStyle = EaseInputMenuStyle.valueOf(chatMenuStyle);
                if (menuStyle != null) {
                    chatLayout.getChatInputMenu().getPrimaryMenu().setMenuShowType(menuStyle);
                }
            }
            int inputBg = bundle.getInt(Constant.KEY_CHAT_MENU_INPUT_BG, -1);
            if (inputBg != -1) {
                chatLayout.getChatInputMenu().getPrimaryMenu().setMenuBackground(ContextCompat.getDrawable(mContext, inputBg));
            }
            String inputHint = bundle.getString(Constant.KEY_CHAT_MENU_INPUT_HINT, "");
            if (!TextUtils.isEmpty(inputHint)) {
                chatLayout.getChatInputMenu().getPrimaryMenu().getEditText().setHint(inputHint);
            }
            sendOriginalImage = bundle.getBoolean(Constant.KEY_SEND_ORIGINAL_IMAGE_MESSAGE, false);
            int emptyLayout = bundle.getInt(Constant.KEY_EMPTY_LAYOUT, -1);
            if (emptyLayout != -1) {
                chatLayout.getChatMessageListLayout().getMessageAdapter().setEmptyView(emptyLayout);
            }
        }
//        setCustomExtendMenu();
        // Provide views after finishing inflate
        if (finishInflateListener != null) {
//            finishInflateListener.onTitleBarFinishInflate(titleBar);
            finishInflateListener.onChatListFinishInflate(chatLayout);
        }


        // Provide views after finishing inflate
        if (finishInflateListener != null) {
//            finishInflateListener.onTitleBarFinishInflate(titleBar);
            finishInflateListener.onChatListFinishInflate(chatLayout);
        }
    }

    public void initListener() {
        chatLayout.setOnChatLayoutListener(this);
        chatLayout.setOnPopupWindowItemClickListener(this);
        chatLayout.setOnAddMsgAttrsBeforeSendEvent(this);
        chatLayout.setOnChatRecordTouchListener(this);
        chatLayout.setOnTranslateListener(this);
        EMClient.getInstance().addMultiDeviceListener(this);
        EMClient.getInstance().chatThreadManager().addChatThreadChangeListener(this);
    }

    public void initData() {
        initChatLayout();
        loadData();
        isMessageInit = true;
    }

    public void initChatLayout() {
        chatLayout.setIsChannel(isChannel);
        if (!TextUtils.isEmpty(historyMsgId)) {
            chatLayout.init(EaseChatMessageListLayout.LoadDataType.HISTORY, conversationId, chatType);
        } else {
            if (isThread) {
                chatLayout.init(EaseChatMessageListLayout.LoadDataType.THREAD, conversationId, chatType);
            } else {
                if (isRoam) {
                    chatLayout.init(EaseChatMessageListLayout.LoadDataType.ROAM, conversationId, chatType);
                } else {
                    chatLayout.init(conversationId, chatType);
                }
            }
        }
    }

    public void loadData() {
        if (!TextUtils.isEmpty(historyMsgId)) {
            chatLayout.loadData(historyMsgId);
        } else {
            chatLayout.loadDefaultData();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (isMessageInit) {
            chatLayout.getChatMessageListLayout().refreshMessages();
        }
    }

    public void setOnChatLayoutListener(OnChatLayoutListener listener) {
        this.listener = listener;
    }

    @Override
    public boolean onBubbleClick(EMMessage message) {
        if (listener != null) {
            return listener.onBubbleClick(message);
        }
        return false;
    }

    @Override
    public boolean onBubbleLongClick(View v, EMMessage message) {
        if (listener != null) {
            return listener.onBubbleLongClick(v, message);
        }
        return false;
    }

    @Override
    public void onUserAvatarClick(String username) {
        if (listener != null) {
            listener.onUserAvatarClick(username);
        }
    }

    @Override
    public void onUserAvatarLongClick(String username) {
        if (listener != null) {
            listener.onUserAvatarLongClick(username);
        }
    }

    @Override
    public void onChatExtendMenuItemClick(View view, int itemId) {
        if (extendMenuItemClickListener != null && extendMenuItemClickListener.onChatExtendMenuItemClick(view, itemId)) {
            return;
        }
        if (itemId == R.id.extend_item_take_picture) {
            selectPicFromCamera();
        } else if (itemId == R.id.extend_item_picture) {
            selectPicFromLocal();
        } else if (itemId == R.id.extend_item_location) {
            startMapLocation(REQUEST_CODE_MAP);
        } else if (itemId == R.id.extend_item_video) {
            selectVideoFromLocal();
        } else if (itemId == R.id.extend_item_file) {
            selectFileFromLocal();
        }
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void onChatSuccess(EMMessage message) {
        // you can do something after sending a successful message
    }

    @Override
    public void onChatError(int code, String errorMsg) {
        if (listener != null) {
            listener.onChatError(code, errorMsg);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            chatLayout.getChatInputMenu().hideExtendContainer();
            if (requestCode == REQUEST_CODE_CAMERA) { // capture new image
                onActivityResultForCamera(data);
            } else if (requestCode == REQUEST_CODE_LOCAL) { // send local image
                onActivityResultForLocalPhotos(data);
            } else if (requestCode == REQUEST_CODE_MAP) { // location
                onActivityResultForMapLocation(data);
            } else if (requestCode == REQUEST_CODE_DING_MSG) { // To send the ding-type msg.
                onActivityResultForDingMsg(data);
            } else if (requestCode == REQUEST_CODE_SELECT_FILE) {
                onActivityResultForLocalFiles(data);
            } else if (requestCode == REQUEST_CODE_SELECT_VIDEO) {
                onActivityResultForLocalVideos(data);
            }
        }
    }

    private void onActivityResultForLocalVideos(Intent data) {
        if (data != null) {
            Uri uri = data.getData();
            MediaPlayer mediaPlayer = new MediaPlayer();
            try {
                mediaPlayer.setDataSource(mContext, uri);
                mediaPlayer.prepare();
            } catch (IOException e) {
                e.printStackTrace();
            }
            int duration = mediaPlayer.getDuration();
            EMLog.d(TAG, "path = " + uri.getPath() + ",duration=" + duration);
            chatLayout.sendVideoMessage(uri, duration);
        }
    }

    /**
     * select picture from camera
     */
    protected void selectPicFromCamera() {
        if (!checkSdCardExist()) {
            return;
        }
        cameraFile = new File(PathUtil.getInstance().getImagePath(), EMClient.getInstance().getCurrentUser()
                + System.currentTimeMillis() + ".jpg");
        //noinspection ResultOfMethodCallIgnored
        cameraFile.getParentFile().mkdirs();
        startActivityForResult(
                new Intent(MediaStore.ACTION_IMAGE_CAPTURE).putExtra(MediaStore.EXTRA_OUTPUT, EaseCompat.getUriForFile(getContext(), cameraFile)),
                REQUEST_CODE_CAMERA);
    }

    /**
     * select local image
     */
    protected void selectPicFromLocal() {
        EaseCompat.openImage(this, REQUEST_CODE_LOCAL);
    }

    /**
     * 启动定位
     *
     * @param requestCode
     */
    protected void startMapLocation(int requestCode) {
        EaseBaiduMapActivity.actionStartForResult(this, requestCode);
    }

    /**
     * select local video
     */
    protected void selectVideoFromLocal() {
        Intent intent = new Intent();
        if (VersionUtils.isTargetQ(getActivity())) {
            intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
        } else {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                intent.setAction(Intent.ACTION_GET_CONTENT);
            } else {
                intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
            }
        }
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("video/*");

        startActivityForResult(intent, REQUEST_CODE_SELECT_VIDEO);

    }

    /**
     * select local file
     */
    protected void selectFileFromLocal() {
        Intent intent = new Intent();
        if (VersionUtils.isTargetQ(getActivity())) {
            intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
        } else {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                intent.setAction(Intent.ACTION_GET_CONTENT);
            } else {
                intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
            }
        }
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");

        startActivityForResult(intent, REQUEST_CODE_SELECT_FILE);
    }

    /**
     * 相机返回处理结果
     *
     * @param data
     */
    protected void onActivityResultForCamera(Intent data) {
        if (cameraFile != null && cameraFile.exists()) {
            chatLayout.sendImageMessage(Uri.parse(cameraFile.getAbsolutePath()));
        }
    }

    /**
     * 选择本地图片处理结果
     *
     * @param data
     */
    protected void onActivityResultForLocalPhotos(@Nullable Intent data) {
        if (data != null) {
            Uri selectedImage = data.getData();
            if (selectedImage != null) {
                String filePath = EaseFileUtils.getFilePath(mContext, selectedImage);
                if (!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
                    chatLayout.sendImageMessage(Uri.parse(filePath));
                } else {
                    EaseFileUtils.saveUriPermission(mContext, selectedImage, data);
                    chatLayout.sendImageMessage(selectedImage);
                }
            }
        }
    }

    /**
     * 地图定位结果处理
     *
     * @param data
     */
    protected void onActivityResultForMapLocation(@Nullable Intent data) {
        if (data != null) {
            double latitude = data.getDoubleExtra("latitude", 0);
            double longitude = data.getDoubleExtra("longitude", 0);
            String locationAddress = data.getStringExtra("address");
            String buildingName = data.getStringExtra("buildingName");
            if (locationAddress != null && !locationAddress.equals("")) {
                chatLayout.sendLocationMessage(latitude, longitude, locationAddress, buildingName);
            } else {
                if (listener != null) {
                    listener.onChatError(-1, getResources().getString(R.string.unable_to_get_loaction));
                }
            }
        }
    }

    protected void onActivityResultForDingMsg(@Nullable Intent data) {
        if (data != null) {
            String msgContent = data.getStringExtra("msg");
            EMLog.i(TAG, "To send the ding-type msg, content: " + msgContent);
            // Send the ding-type msg.
            EMMessage dingMsg = EaseDingMessageHelper.get().createDingMessage(conversationId, msgContent);
            chatLayout.sendMessage(dingMsg);
        }
    }

    /**
     * 本地文件选择结果处理
     *
     * @param data
     */
    protected void onActivityResultForLocalFiles(@Nullable Intent data) {
        if (data != null) {
            Uri uri = data.getData();
            if (uri != null) {
                String filePath = EaseFileUtils.getFilePath(mContext, uri);
                if (!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
                    chatLayout.sendFileMessage(Uri.parse(filePath));
                } else {
                    EaseFileUtils.saveUriPermission(mContext, uri, data);
                    chatLayout.sendFileMessage(uri);
                }
            }
        }
    }

    /**
     * 检查sd卡是否挂载
     *
     * @return
     */
    protected boolean checkSdCardExist() {
        return EaseCommonUtils.isSdcardExist();
    }

    @Override
    public void onPreMenu(EasePopupWindowHelper helper, EMMessage message, View v) {

    }

    @Override
    public boolean onMenuItemClick(MenuItemBean item, EMMessage message) {
        return false;
    }

    @Override
    public void addMsgAttrsBeforeSend(EMMessage message) {

    }

    /**
     * Set whether can touch voice button
     *
     * @param v
     * @param event
     * @return
     */
    @Override
    public boolean onRecordTouch(View v, MotionEvent event) {
        return true;
    }

    @Override
    public void translateMessageSuccess(EMMessage message) {

    }

    @Override
    public void translateMessageFail(EMMessage message, int code, String error) {

    }

    @Override
    public void onChatThreadCreated(EMChatThreadEvent event) {
        if (isMessageInit) {
            chatLayout.getChatMessageListLayout().refreshToLatest();
        }
    }

    @Override
    public void onChatThreadUpdated(EMChatThreadEvent event) {
        if (isMessageInit) {
            chatLayout.getChatMessageListLayout().refreshMessage(event.getChatThread().getMessageId());
        }
    }

    @Override
    public void onChatThreadDestroyed(EMChatThreadEvent event) {
        if (isMessageInit) {
            chatLayout.getChatMessageListLayout().refreshMessage(event.getChatThread().getMessageId());
        }
    }

    @Override
    public void onChatThreadUserRemoved(EMChatThreadEvent event) {

    }

    private void setHeaderBackPressListener(EaseTitleBar.OnBackPressListener listener) {
        this.backPressListener = listener;
    }

    private void setOnChatExtendMenuItemClickListener(OnChatExtendMenuItemClickListener listener) {
        this.extendMenuItemClickListener = listener;
    }

    private void setOnChatInputChangeListener(OnChatInputChangeListener listener) {
        this.chatInputChangeListener = listener;
    }

    private void setOnMessageItemClickListener(OnMessageItemClickListener listener) {
        this.chatItemClickListener = listener;
    }

    private void setOnMessageSendCallBack(OnMessageSendCallBack callBack) {
        this.messageSendCallBack = callBack;
    }

    private void setOnPeerTypingListener(OnPeerTypingListener listener) {
        this.otherTypingListener = listener;
    }

    private void setOnAddMsgAttrsBeforeSendEvent(OnAddMsgAttrsBeforeSendEvent sendMsgEvent) {
        this.sendMsgEvent = sendMsgEvent;
    }

    private void setOnChatRecordTouchListener(OnChatRecordTouchListener recordTouchListener) {
        this.recordTouchListener = recordTouchListener;
    }

    private void setOnReactionMessageListener(OnReactionMessageListener reactionMessageListener) {
        this.reactionMessageListener = reactionMessageListener;
    }

    private void setOnChatLayoutFinishInflateListener(OnChatLayoutFinishInflateListener inflateListener) {
        this.finishInflateListener = inflateListener;
    }

    private void setCustomAdapter(EaseMessageAdapter adapter) {
        this.messageAdapter = adapter;
    }

    @Override
    public void onContactEvent(int event, String target, String ext) {
        if (event == GROUP_DESTROY || event == GROUP_LEAVE) {
            if (TextUtils.equals(target, conversationId)) {
                mContext.finish();
            }
        }
    }

    @Override
    public void onGroupEvent(int event, String target, List<String> usernames) {

    }

    @Override
    public void onChatThreadEvent(int event, String target, List<String> usernames) {
    }

    @Override
    public void onCircleServerEvent(int event, String serverId, List<String> usernames) {
    }

    @Override
    public void onCircleChannelEvent(int event, String channelId, List<String> usernames) {
    }


    public static class Builder {
        protected final Bundle bundle;
        private EaseTitleBar.OnBackPressListener backPressListener;
        private EaseMessageAdapter adapter;
        private OnChatExtendMenuItemClickListener extendMenuItemClickListener;
        private OnChatInputChangeListener chatInputChangeListener;
        private OnMessageItemClickListener messageItemClickListener;
        private OnMessageSendCallBack messageSendCallBack;
        private OnPeerTypingListener peerTypingListener;
        private OnAddMsgAttrsBeforeSendEvent sendMsgEvent;
        private OnChatRecordTouchListener recordTouchListener;
        private OnReactionMessageListener reactionMessageListener;
        private OnChatLayoutFinishInflateListener finishInflateListener;
        protected EaseChatFragment customFragment;

        /**
         * Constructor
         *
         * @param conversationId Agora Chat ID
         * @param chatType       See {@link EaseChatType}
         */
        public Builder(String conversationId, EaseChatType chatType) {
            this.bundle = new Bundle();
            bundle.putString(EaseConstant.EXTRA_CONVERSATION_ID, conversationId);
            bundle.putInt(EaseConstant.EXTRA_CHAT_TYPE, chatType.getChatType());
        }

        /**
         * Constructor
         *
         * @param conversationId Agora Chat ID
         * @param chatType       See {@link EaseChatType}
         * @param historyMsgId   Message ID
         */
        public Builder(String conversationId, EaseChatType chatType, String historyMsgId) {
            this.bundle = new Bundle();
            bundle.putString(EaseConstant.EXTRA_CONVERSATION_ID, conversationId);
            bundle.putInt(EaseConstant.EXTRA_CHAT_TYPE, chatType.getChatType());
            bundle.putString(EaseConstant.HISTORY_MSG_ID, historyMsgId);
        }

        /**
         * Whether to use default titleBar which is {@link EaseTitleBar}
         *
         * @param useTitle
         * @return
         */
        public Builder useHeader(boolean useTitle) {
            this.bundle.putBoolean(Constant.KEY_USE_TITLE, useTitle);
            return this;
        }

        /**
         * Set titleBar's title
         *
         * @param title
         * @return
         */
        public Builder setHeaderTitle(String title) {
            this.bundle.putString(Constant.KEY_SET_TITLE, title);
            return this;
        }

        /**
         * Set titleBar's sub title
         *
         * @param subTitle
         * @return
         */
        public Builder setHeaderSubTitle(String subTitle) {
            this.bundle.putString(Constant.KEY_SET_SUB_TITLE, subTitle);
            return this;
        }

        /**
         * Whether show back icon in titleBar
         *
         * @param canBack
         * @return
         */
        public Builder enableHeaderPressBack(boolean canBack) {
            this.bundle.putBoolean(Constant.KEY_ENABLE_BACK, canBack);
            return this;
        }

        /**
         * If you have set {@link Builder#enableHeaderPressBack(boolean)}, you can set the listener
         *
         * @param listener
         * @return
         */
        public Builder setHeaderBackPressListener(EaseTitleBar.OnBackPressListener listener) {
            this.backPressListener = listener;
            return this;
        }

        /**
         * Set Whether to get history message from server or local database
         *
         * @param isFromServer
         * @return
         */
        public Builder getHistoryMessageFromServerOrLocal(boolean isFromServer) {
            this.bundle.putBoolean(EaseConstant.EXTRA_IS_FROM_SERVER, isFromServer);
            return this;
        }

        /**
         * Set chat extension menu item click listener
         *
         * @param listener
         * @return
         */
        public Builder setOnChatExtendMenuItemClickListener(OnChatExtendMenuItemClickListener listener) {
            this.extendMenuItemClickListener = listener;
            return this;
        }

        /**
         * Set chat menu's text change listener
         *
         * @param listener
         * @return
         */
        public Builder setOnChatInputChangeListener(OnChatInputChangeListener listener) {
            this.chatInputChangeListener = listener;
            return this;
        }

        /**
         * Set message item click listener, include bubble click, bubble long click, avatar click
         * and avatar long click
         *
         * @param listener
         * @return
         */
        public Builder setOnMessageItemClickListener(OnMessageItemClickListener listener) {
            this.messageItemClickListener = listener;
            return this;
        }

        /**
         * Set message's callback after which is sent
         *
         * @param callBack
         * @return
         */
        public Builder setOnMessageSendCallBack(OnMessageSendCallBack callBack) {
            this.messageSendCallBack = callBack;
            return this;
        }

        /**
         * Turn on other peer's typing monitor, only for single chat
         *
         * @param turnOn
         * @return
         */
        public Builder turnOnTypingMonitor(boolean turnOn) {
            this.bundle.putBoolean(Constant.KEY_TURN_ON_TYPING_MONITOR, turnOn);
            return this;
        }

        /**
         * Set peer's typing listener, only for single chat. You need call {@link Builder#turnOnTypingMonitor(boolean)} first.
         *
         * @param listener
         * @return
         */
        public Builder setOnPeerTypingListener(OnPeerTypingListener listener) {
            this.peerTypingListener = listener;
            return this;
        }

        /**
         * Set the event you can add message's attrs before send message
         *
         * @param sendMsgEvent
         * @return
         */
        public Builder setOnAddMsgAttrsBeforeSendEvent(OnAddMsgAttrsBeforeSendEvent sendMsgEvent) {
            this.sendMsgEvent = sendMsgEvent;
            return this;
        }

        /**
         * Set touch event listener during recording
         *
         * @param recordTouchListener
         * @return
         */
        public Builder setOnChatRecordTouchListener(OnChatRecordTouchListener recordTouchListener) {
            this.recordTouchListener = recordTouchListener;
            return this;
        }

        /**
         * Set reaction listener
         *
         * @param reactionMessageListener
         * @return
         */
        public Builder setOnReactionMessageListener(OnReactionMessageListener reactionMessageListener) {
            this.reactionMessageListener = reactionMessageListener;
            return this;
        }

        /**
         * Set the text color of message item time
         *
         * @param color
         * @return
         */
        public Builder setMsgTimeTextColor(@ColorInt int color) {
            this.bundle.putInt(Constant.KEY_MSG_TIME_COLOR, color);
            return this;
        }

        /**
         * Set the text size of message item time, unit is px
         *
         * @param size
         * @return
         */
        public Builder setMsgTimeTextSize(int size) {
            this.bundle.putInt(Constant.KEY_MSG_TIME_SIZE, size);
            return this;
        }

        /**
         * Set the bubble background of the received message
         *
         * @param bgDrawable
         * @return
         */
        public Builder setReceivedMsgBubbleBackground(@DrawableRes int bgDrawable) {
            this.bundle.putInt(Constant.KEY_MSG_LEFT_BUBBLE, bgDrawable);
            return this;
        }

        /**
         * Set the bubble background of the sent message
         *
         * @param bgDrawable
         * @return
         */
        public Builder setSentBubbleBackground(@DrawableRes int bgDrawable) {
            this.bundle.putInt(Constant.KEY_MSG_RIGHT_BUBBLE, bgDrawable);
            return this;
        }

        /**
         * Whether to show nickname in message item
         *
         * @param showNickname
         * @return
         */
        public Builder showNickname(boolean showNickname) {
            this.bundle.putBoolean(Constant.KEY_SHOW_NICKNAME, showNickname);
            return this;
        }

        /**
         * Set message list show style, including left_right and all_left style
         *
         * @param showType
         * @return
         */
        public Builder setMessageListShowStyle(EaseChatMessageListLayout.ShowType showType) {
            this.bundle.putString(Constant.KEY_MESSAGE_LIST_SHOW_STYLE, showType.name());
            return this;
        }

        /**
         * Set layout inflated listener
         *
         * @param finishInflateListener
         * @return
         */
        public Builder setOnChatLayoutFinishInflateListener(OnChatLayoutFinishInflateListener finishInflateListener) {
            this.finishInflateListener = finishInflateListener;
            return this;
        }

        /**
         * Whether to hide receiver's avatar
         *
         * @param hide
         * @return
         */
        public Builder hideReceiverAvatar(boolean hide) {
            this.bundle.putBoolean(Constant.KEY_HIDE_RECEIVE_AVATAR, hide);
            return this;
        }

        /**
         * Whether to hide sender's avatar
         *
         * @param hide
         * @return
         */
        public Builder hideSenderAvatar(boolean hide) {
            this.bundle.putBoolean(Constant.KEY_HIDE_SEND_AVATAR, hide);
            return this;
        }

        /**
         * Set the background of the chat list region
         *
         * @param bgDrawable
         * @return
         */
        public Builder setChatBackground(@DrawableRes int bgDrawable) {
            this.bundle.putInt(Constant.KEY_CHAT_BACKGROUND, bgDrawable);
            return this;
        }

        /**
         * Set chat input menu style, including voice input, text input,
         * emoji input and extended function input
         *
         * @param style
         * @return
         */
        public Builder setChatInputMenuStyle(EaseInputMenuStyle style) {
            this.bundle.putString(Constant.KEY_CHAT_MENU_STYLE, style.name());
            return this;
        }

        /**
         * Set chat input menu background
         *
         * @param bgDrawable
         * @return
         */
        public Builder setChatInputMenuBackground(@DrawableRes int bgDrawable) {
            this.bundle.putInt(Constant.KEY_CHAT_MENU_INPUT_BG, bgDrawable);
            return this;
        }

        /**
         * Set chat input menu's hint text
         *
         * @param inputHint
         * @return
         */
        public Builder setChatInputMenuHint(String inputHint) {
            this.bundle.putString(Constant.KEY_CHAT_MENU_INPUT_HINT, inputHint);
            return this;
        }

        /**
         * Set whether to use original file to send image message
         *
         * @param sendOriginalImage
         * @return
         */
        public Builder sendMessageByOriginalImage(boolean sendOriginalImage) {
            this.bundle.putBoolean(Constant.KEY_SEND_ORIGINAL_IMAGE_MESSAGE, sendOriginalImage);
            return this;
        }

        /**
         * Set whether to use original file to send image message
         *
         * @param isThread
         * @return
         */
        public Builder setThreadMessage(boolean isThread) {
            this.bundle.putBoolean(Constant.KEY_THREAD_MESSAGE_FLAG, isThread);
            return this;
        }

        /**
         * Set chat list's empty layout if you want replace the default
         *
         * @param emptyLayout
         * @return
         */
        public Builder setEmptyLayout(@LayoutRes int emptyLayout) {
            this.bundle.putInt(Constant.KEY_EMPTY_LAYOUT, emptyLayout);
            return this;
        }

        /**
         * Set custom fragment which should extends EaseMessageFragment
         *
         * @param fragment
         * @param <T>
         * @return
         */
        public <T extends EaseChatFragment> Builder setCustomFragment(T fragment) {
            this.customFragment = fragment;
            return this;
        }

        /**
         * Set custom adapter which should extends EaseMessageAdapter
         *
         * @param adapter
         * @return
         */
        public Builder setCustomAdapter(EaseMessageAdapter adapter) {
            this.adapter = adapter;
            return this;
        }

        public EaseChatFragment build() {
            EaseChatFragment fragment = this.customFragment != null ? this.customFragment : new EaseChatFragment();
            fragment.setArguments(this.bundle);
            fragment.setHeaderBackPressListener(this.backPressListener);
            fragment.setOnChatExtendMenuItemClickListener(this.extendMenuItemClickListener);
            fragment.setOnChatInputChangeListener(this.chatInputChangeListener);
            fragment.setOnMessageItemClickListener(this.messageItemClickListener);
            fragment.setOnMessageSendCallBack(this.messageSendCallBack);
            fragment.setOnPeerTypingListener(this.peerTypingListener);
            fragment.setOnAddMsgAttrsBeforeSendEvent(this.sendMsgEvent);
            fragment.setOnChatRecordTouchListener(this.recordTouchListener);
            fragment.setOnChatLayoutFinishInflateListener(this.finishInflateListener);
            fragment.setCustomAdapter(this.adapter);
            fragment.setOnReactionMessageListener(this.reactionMessageListener);
            return fragment;
        }
    }

    private static class Constant {
        public static final String KEY_USE_TITLE = "key_use_title";
        public static final String KEY_SET_TITLE = "key_set_title";
        public static final String KEY_SET_SUB_TITLE = "key_set_sub_title";
        public static final String KEY_EMPTY_LAYOUT = "key_empty_layout";
        public static final String KEY_ENABLE_BACK = "key_enable_back";
        public static final String KEY_MSG_TIME_COLOR = "key_msg_time_color";
        public static final String KEY_MSG_TIME_SIZE = "key_msg_time_size";
        public static final String KEY_MSG_LEFT_BUBBLE = "key_msg_left_bubble";
        public static final String KEY_MSG_RIGHT_BUBBLE = "key_msg_right_bubble";
        public static final String KEY_SHOW_NICKNAME = "key_show_nickname";
        public static final String KEY_MESSAGE_LIST_SHOW_STYLE = "key_message_list_show_type";
        public static final String KEY_HIDE_RECEIVE_AVATAR = "key_hide_left_avatar";
        public static final String KEY_HIDE_SEND_AVATAR = "key_hide_right_avatar";
        public static final String KEY_CHAT_BACKGROUND = "key_chat_background";
        public static final String KEY_CHAT_MENU_STYLE = "key_chat_menu_style";
        public static final String KEY_CHAT_MENU_INPUT_BG = "key_chat_menu_input_bg";
        public static final String KEY_CHAT_MENU_INPUT_HINT = "key_chat_menu_input_hint";
        public static final String KEY_TURN_ON_TYPING_MONITOR = "key_turn_on_typing_monitor";
        public static final String KEY_SEND_ORIGINAL_IMAGE_MESSAGE = "key_send_original_image_message";
        public static final String KEY_THREAD_MESSAGE_FLAG = "key_thread_message_flag";
    }
}

