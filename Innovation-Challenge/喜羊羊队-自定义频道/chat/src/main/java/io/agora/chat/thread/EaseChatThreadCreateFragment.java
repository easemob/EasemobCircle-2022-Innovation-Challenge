package io.agora.chat.thread;

import static com.hyphenate.easeui.modules.chat.EaseInputMenuStyle.DISABLE_VOICE;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.hyphenate.EMError;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.domain.EaseEmojicon;
import com.hyphenate.easeui.interfaces.OnChatExtendMenuItemClickListener;
import com.hyphenate.easeui.interfaces.OnMessageItemClickListener;
import com.hyphenate.easeui.interfaces.OnMessageSendCallBack;
import com.hyphenate.easeui.manager.EaseDingMessageHelper;
import com.hyphenate.easeui.modules.chat.interfaces.ChatInputMenuListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnAddMsgAttrsBeforeSendEvent;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatRecordTouchListener;
import com.hyphenate.easeui.ui.base.EaseBaseFragment;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseCompat;
import com.hyphenate.easeui.utils.EaseFileUtils;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.hyphenate.util.EMFileHelper;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.PathUtil;
import com.hyphenate.util.VersionUtils;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.io.File;

import io.agora.chat.R;
import io.agora.chat.databinding.EaseFragmentCreateThreadBinding;
import io.agora.chat.thread.interfaces.EaseChatThreadParentMsgViewProvider;
import io.agora.chat.thread.interfaces.OnChatThreadCreatedResultListener;
import io.agora.chat.thread.presenter.EaseChatThreadCreatePresenter;
import io.agora.chat.thread.presenter.EaseChatThreadCreatePresenterImpl;
import io.agora.chat.thread.presenter.IChatThreadCreateView;
import io.agora.chat.thread.widget.EaseChatThreadParentMsgView;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;

public class EaseChatThreadCreateFragment extends EaseBaseFragment implements ChatInputMenuListener, IChatThreadCreateView, View.OnClickListener {
    protected static final int REQUEST_CODE_MAP = 1;
    protected static final int REQUEST_CODE_CAMERA = 2;
    protected static final int REQUEST_CODE_LOCAL = 3;
    protected static final int REQUEST_CODE_DING_MSG = 4;
    protected static final int REQUEST_CODE_SELECT_VIDEO = 11;
    protected static final int REQUEST_CODE_SELECT_FILE = 12;

    private static final String TAG = EaseChatThreadCreateFragment.class.getSimpleName();
    private EaseFragmentCreateThreadBinding binding;
    private EaseTitleBar.OnBackPressListener backPressListener;
    private EaseChatThreadParentMsgViewProvider parentMsgViewProvider;
    private String messageId;
    private String parentId;
    private EaseChatThreadCreatePresenter presenter;

    private OnChatExtendMenuItemClickListener extendMenuItemClickListener;
    private OnMessageItemClickListener chatItemClickListener;
    private OnMessageSendCallBack messageSendCallBack;
    private OnAddMsgAttrsBeforeSendEvent sendMsgEvent;
    private OnChatRecordTouchListener recordTouchListener;
    private File cameraFile;
    private boolean sendOriginalImage;
    private EMChatThread chatThread;
    private OnChatThreadCreatedResultListener resultListener;
    //输入框初始值
    private int namePrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    private CircleChannel channel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        initArguments();
        binding = EaseFragmentCreateThreadBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
        initListener();
        initData();
    }

    public void initArguments() {
        Bundle bundle = getArguments();
        if (bundle != null) {
            messageId = bundle.getString(Constant.KEY_MESSAGE_ID);
            parentId = bundle.getString(Constant.KEY_PARENT_ID);
        }
    }

    public void initView() {
        if (presenter == null) {
            presenter = new EaseChatThreadCreatePresenterImpl();
        }
        if (mContext instanceof AppCompatActivity) {
            ((AppCompatActivity) mContext).getLifecycle().addObserver(presenter);
        }
        presenter.attachView(this);
        presenter.setupWithToUser(parentId, messageId, binding.etInputName);
        Bundle bundle = getArguments();
        if (bundle != null) {
            sendOriginalImage = bundle.getBoolean(Constant.KEY_SEND_ORIGINAL_IMAGE_MESSAGE, false);
            channel = (CircleChannel) bundle.getSerializable(Constant.KEY_CHANNEL);
            binding.ivBack.setOnClickListener(this);
            if (channel != null) {
                binding.tvChannelName.setText("#" + channel.name);
            }
            String threadMention = bundle.getString(Constant.KEY_THREAD_MENTION, "");
            if (!TextUtils.isEmpty(threadMention)) {
                binding.tvThreadMentions.setText(threadMention);
            }
            String inputHint = bundle.getString(Constant.KEY_THREAD_INPUT_HINT, "");
            if (!TextUtils.isEmpty(inputHint)) {
                binding.etInputName.setHint(inputHint);
            }
            if (this.parentMsgViewProvider != null) {
                View parentMsgView = this.parentMsgViewProvider.parentMsgView(EMClient.getInstance().chatManager().getMessage(messageId));
                if (parentMsgView != null) {
                    binding.threadParentMsg.removeAllViews();
                    binding.threadParentMsg.addView(parentMsgView);
                } else {
                    addDefaultParentMsgView();
                }
            } else {
                addDefaultParentMsgView();
            }
        }
        setCustomExtendMenu();
    }

    /**
     * Set custom extend menu
     */
    public void setCustomExtendMenu() {
//        EaseChatExtendMenuDialog chatMenuDialog = new EaseChatExtendMenuDialog(mContext);
//        chatMenuDialog.init();
//        EaseChatExtendMenuDialog dialog = new EaseAlertDialog.Builder<EaseChatExtendMenuDialog>(mContext)
//                .setCustomDialog(chatMenuDialog)
//                .setFullWidth()
//                .setGravity(Gravity.BOTTOM)
//                .setFromBottomAnimation()
//                .create();
//        binding.layoutMenu.setCustomExtendMenu(dialog);
        binding.layoutMenu.getPrimaryMenu().setMenuShowType(DISABLE_VOICE);

        binding.layoutMenu.getChatExtendMenu().clear();
        binding.layoutMenu.getChatExtendMenu().registerMenuItem(R.string.attach_picture, R.drawable.ease_chat_image_selector, R.id.extend_item_picture);
    }

    private void addDefaultParentMsgView() {
        EaseChatThreadParentMsgView view = new EaseChatThreadParentMsgView(mContext);
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        view.setLayoutParams(layoutParams);
        binding.threadParentMsg.removeAllViews();
        binding.threadParentMsg.addView(view);

        view.setOnMessageItemClickListener(chatItemClickListener);
        view.setBottomDividerVisible(true);

        view.setMessage(EMClient.getInstance().chatManager().getMessage(messageId));
    }

    public void initListener() {
        binding.layoutMenu.setChatInputMenuListener(this);
        binding.etInputName.addTextChangedListener(new TextWatcher() {
            //记录输入的字数
            private CharSequence wordNum;
            private int selectionStart;
            private int selectionEnd;

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                //实时记录输入的字数
                wordNum = s;
            }

            @Override
            public void afterTextChanged(Editable s) {
                int number = namePrimaryNum + s.length();
                //TextView显示剩余字数
                binding.tvThreadNameCount.setText("" + number + "/16");
                selectionStart = binding.etInputName.getSelectionStart();
                selectionEnd = binding.etInputName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    binding.etInputName.setText(s);
                    binding.etInputName.setSelection(tempSelection);//设置光标在最后
                }
                if (s.length() == 0) {
                    binding.ivDelete.setVisibility(View.GONE);
                } else {
                    binding.ivDelete.setVisibility(View.VISIBLE);
                }
            }
        });
        binding.ivDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                binding.etInputName.setText("");
            }
        });


    }

    public void initData() {

    }

    @Override
    public void onTyping(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void onSendMessage(String content) {
        presenter.sendTextMessage(content);
    }

    @Override
    public void onExpressionClicked(Object emojicon) {
        if (emojicon instanceof EaseEmojicon) {
            presenter.sendBigExpressionMessage(((EaseEmojicon) emojicon).getName(), ((EaseEmojicon) emojicon).getIdentityCode());
        }
    }

    @Override
    public boolean onPressToSpeakBtnTouch(View v, MotionEvent event) {
        if (recordTouchListener != null) {
            boolean onRecordTouch = recordTouchListener.onRecordTouch(v, event);
            if (onRecordTouch) {
                return true;
            }
        }
        return binding.voiceRecorder.onPressToSpeakBtnTouch(v, event, (this::sendVoiceMessage));
    }

    private void sendVoiceMessage(String filePath, int length) {
        presenter.sendVoiceMessage(Uri.parse(filePath), length);
    }

    @Override
    public void onChatExtendMenuItemClick(int itemId, View view) {
        if (extendMenuItemClickListener != null && extendMenuItemClickListener.onChatExtendMenuItemClick(view, itemId)) {
            return;
        }
        if (itemId == R.id.extend_item_take_picture) {
            selectPicFromCamera();
        } else if (itemId == R.id.extend_item_picture) {
            selectPicFromLocal();
        } else if (itemId == R.id.extend_item_video) {
            selectVideoFromLocal();
        } else if (itemId == R.id.extend_item_file) {
            selectFileFromLocal();
        }
    }

    private void setHeaderBackPressListener(EaseTitleBar.OnBackPressListener listener) {
        this.backPressListener = listener;
    }

    private void setParentMsgViewProvider(EaseChatThreadParentMsgViewProvider provider) {
        this.parentMsgViewProvider = provider;
    }

    private void setPresenter(EaseChatThreadCreatePresenter presenter) {
        this.presenter = presenter;
    }

    private void setOnChatExtendMenuItemClickListener(OnChatExtendMenuItemClickListener listener) {
        this.extendMenuItemClickListener = listener;
    }

    private void setOnMessageItemClickListener(OnMessageItemClickListener listener) {
        this.chatItemClickListener = listener;
    }

    private void setOnMessageSendCallBack(OnMessageSendCallBack callBack) {
        this.messageSendCallBack = callBack;
    }

    private void setOnAddMsgAttrsBeforeSendEvent(OnAddMsgAttrsBeforeSendEvent sendMsgEvent) {
        this.sendMsgEvent = sendMsgEvent;
    }

    private void setOnChatRecordTouchListener(OnChatRecordTouchListener recordTouchListener) {
        this.recordTouchListener = recordTouchListener;
    }

    private void setOnThreadCreatedResultListener(OnChatThreadCreatedResultListener resultListener) {
        this.resultListener = resultListener;
    }

    @Override
    public Context context() {
        return mContext;
    }

    @Override
    public void sendMessageFail(String message) {
        if (messageSendCallBack != null) {
            messageSendCallBack.onError(EMError.GENERAL_ERROR, message);
        }
    }

    @Override
    public void addMsgAttrBeforeSend(EMMessage message) {
        if (sendMsgEvent != null) {
            sendMsgEvent.addMsgAttrsBeforeSend(message);
        }
    }

    @Override
    public void onPresenterMessageSuccess(EMMessage message) {
        if (messageSendCallBack != null) {
            messageSendCallBack.onSuccess(message);
        }
        if (resultListener == null || !resultListener.onThreadCreatedSuccess(messageId, message.conversationId())) {
            //跳转去chatthread activity
//            EaseActivityProviderHelper.startToChatThreadActivity(mContext, message.conversationId(), messageId, parentId);
        }
        mContext.finish();
    }

    @Override
    public void onPresenterMessageError(EMMessage message, int code, String error) {
        if (messageSendCallBack != null) {
            messageSendCallBack.onError(code, error);
        }
        if (resultListener != null) {
            resultListener.onThreadCreatedFail(code, error);
        }
    }

    @Override
    public void onPresenterMessageInProgress(EMMessage message, int progress) {

    }

    @Override
    public void sendMessageFinish(EMMessage message) {

    }

    @Override
    public void onCreateThreadSuccess(EMChatThread thread, EMMessage message) {
        chatThread = thread;
        presenter.sendMessage(message);
        if (resultListener != null) {
            resultListener.onThreadCreatedSuccess(thread.getMessageId(), thread.getChatThreadId());
        }
        LiveEventBus.get(Constants.THREAD_CHANGE).post(thread);
    }

    @Override
    public void onCreateThreadFail(int errorCode, String message) {
        if (resultListener != null) {
            resultListener.onThreadCreatedFail(errorCode, message);
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
     * select local video
     */
    protected void selectVideoFromLocal() {
//        Intent intent = new Intent(getActivity(), EaseImageGridActivity.class);
//        startActivityForResult(intent, REQUEST_CODE_SELECT_VIDEO);
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

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            binding.layoutMenu.hideExtendContainer();
            if (requestCode == REQUEST_CODE_CAMERA) { // capture new image
                onActivityResultForCamera(data);
            } else if (requestCode == REQUEST_CODE_LOCAL) { // send local image
                onActivityResultForLocalPhotos(data);
            } else if (requestCode == REQUEST_CODE_DING_MSG) { // To send the ding-type msg.
                onActivityResultForDingMsg(data);
            } else if (requestCode == REQUEST_CODE_SELECT_FILE) {
                onActivityResultForLocalFiles(data);
            } else if (REQUEST_CODE_SELECT_VIDEO == requestCode) {
                onActivityResultForLocalVideos(data);
            }
        }
    }

    protected void onActivityResultForLocalVideos(@Nullable Intent data) {
        if (data != null) {
            int duration = data.getIntExtra("dur", 0);
            if (duration == -1) {
                duration = 0;
            }
            duration = (int) Math.round(duration * 1.0 / 1000);
            String videoPath = data.getStringExtra("path");
            String uriString = data.getStringExtra("uri");
            if (!TextUtils.isEmpty(videoPath)) {
                presenter.sendVideoMessage(Uri.parse(videoPath), duration);
            } else {
                Uri videoUri = EMFileHelper.getInstance().formatInUri(uriString);
                presenter.sendVideoMessage(videoUri, duration);
            }
        }
    }

    protected void onActivityResultForCamera(Intent data) {
        if (cameraFile != null && cameraFile.exists()) {
            presenter.sendImageMessage(Uri.parse(cameraFile.getAbsolutePath()), sendOriginalImage);
        }
    }

    protected void onActivityResultForLocalPhotos(@Nullable Intent data) {
        if (data != null) {
            Uri selectedImage = data.getData();
            if (selectedImage != null) {
                String filePath = EaseFileUtils.getFilePath(mContext, selectedImage);
                if (!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
                    presenter.sendImageMessage(Uri.parse(filePath), sendOriginalImage);
                } else {
                    EaseFileUtils.saveUriPermission(mContext, selectedImage, data);
                    presenter.sendImageMessage(selectedImage, sendOriginalImage);
                }
            }
        }
    }

    protected void onActivityResultForDingMsg(@Nullable Intent data) {
        if (data != null) {
            String msgContent = data.getStringExtra("msg");
            EMLog.i(TAG, "To send the ding-type msg, content: " + msgContent);
            // Send the ding-type msg.
            if (chatThread != null) {
                String conversationId = chatThread.getChatThreadId();
                EMMessage dingMsg = EaseDingMessageHelper.get().createDingMessage(conversationId, msgContent);
                presenter.sendGroupDingMessage(dingMsg);
            }
        }
    }

    protected void onActivityResultForLocalFiles(@Nullable Intent data) {
        if (data != null) {
            Uri uri = data.getData();
            if (uri != null) {
                String filePath = EaseFileUtils.getFilePath(mContext, uri);
                if (!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
                    presenter.sendFileMessage(Uri.parse(filePath));
                } else {
                    EaseFileUtils.saveUriPermission(mContext, uri, data);
                    presenter.sendFileMessage(uri);
                }
            }
        }
    }

    protected boolean checkSdCardExist() {
        return EaseCommonUtils.isSdcardExist();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_back) {
            mContext.onBackPressed();
        }
    }

    public static class Builder {
        private final Bundle bundle;
        private EaseTitleBar.OnBackPressListener backPressListener;
        private EaseChatThreadParentMsgViewProvider parentMsgViewProvider;
        private EaseChatThreadCreateFragment customFragment;
        private EaseChatThreadCreatePresenter presenter;
        private OnChatExtendMenuItemClickListener extendMenuItemClickListener;
        private OnMessageItemClickListener messageItemClickListener;
        private OnMessageSendCallBack messageSendCallBack;
        private OnAddMsgAttrsBeforeSendEvent sendMsgEvent;
        private OnChatRecordTouchListener recordTouchListener;
        private OnChatThreadCreatedResultListener resultListener;

        /**
         * Constructor
         *
         * @param parentId  Usually is group id.
         * @param messageId Usually is group message id.
         */
        public Builder(String parentId, String messageId, CircleChannel channel) {
            this.bundle = new Bundle();
            bundle.putString(Constant.KEY_PARENT_ID, parentId);
            bundle.putString(Constant.KEY_MESSAGE_ID, messageId);
            bundle.putSerializable(Constant.KEY_CHANNEL, channel);
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
         * Set thread mention
         *
         * @param threadMention
         * @return
         */
        public Builder setThreadMention(String threadMention) {
            this.bundle.putString(Constant.KEY_THREAD_MENTION, threadMention);
            return this;
        }

        /**
         * Set thread input hint
         *
         * @param threadInputHint
         * @return
         */
        public Builder setThreadInputHint(String threadInputHint) {
            this.bundle.putString(Constant.KEY_THREAD_INPUT_HINT, threadInputHint);
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

        public Builder setOnThreadCreatedResultListener(OnChatThreadCreatedResultListener listener) {
            this.resultListener = listener;
            return this;
        }

        /**
         * Set custom fragment which should extends EaseMessageFragment
         *
         * @param fragment
         * @param <T>
         * @return
         */
        public <T extends EaseChatThreadCreateFragment> Builder setCustomFragment(T fragment) {
            this.customFragment = fragment;
            return this;
        }

        /**
         * Set custom presenter if you want to add your logic
         *
         * @param presenter
         * @param <T>
         * @return
         */
        public <T extends EaseChatThreadCreatePresenter> Builder setCustomPresenter(EaseChatThreadCreatePresenter presenter) {
            this.presenter = presenter;
            return this;
        }

        public EaseChatThreadCreateFragment build() {
            EaseChatThreadCreateFragment fragment = this.customFragment != null ? this.customFragment : new EaseChatThreadCreateFragment();
            fragment.setArguments(this.bundle);
            fragment.setHeaderBackPressListener(this.backPressListener);
            fragment.setParentMsgViewProvider(this.parentMsgViewProvider);
            fragment.setPresenter(this.presenter);
            fragment.setOnChatExtendMenuItemClickListener(this.extendMenuItemClickListener);
            fragment.setOnMessageItemClickListener(this.messageItemClickListener);
            fragment.setOnMessageSendCallBack(this.messageSendCallBack);
            fragment.setOnAddMsgAttrsBeforeSendEvent(this.sendMsgEvent);
            fragment.setOnChatRecordTouchListener(this.recordTouchListener);
            fragment.setOnThreadCreatedResultListener(this.resultListener);
            return fragment;
        }
    }

    public static class Constant {
        public static final String KEY_PARENT_ID = "key_parent_id";
        public static final String KEY_MESSAGE_ID = "key_message_id";
        public static final String KEY_USE_TITLE = "key_use_title";
        public static final String KEY_SET_TITLE = "key_set_title";
        public static final String KEY_ENABLE_BACK = "key_enable_back";
        public static final String KEY_THREAD_MENTION = "key_thread_mention";
        public static final String KEY_THREAD_INPUT_HINT = "key_thread_input_hint";
        public static final String KEY_SEND_ORIGINAL_IMAGE_MESSAGE = "key_send_original_image_message";
        public static final String KEY_CHANNEL = "key_channel";
    }
}
