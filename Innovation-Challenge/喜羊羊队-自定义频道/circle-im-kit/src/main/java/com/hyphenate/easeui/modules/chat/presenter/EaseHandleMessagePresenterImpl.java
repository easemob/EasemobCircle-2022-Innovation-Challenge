package com.hyphenate.easeui.modules.chat.presenter;

import static io.agora.rtc2.video.VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15;
import static io.agora.rtc2.video.VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE;
import static io.agora.rtc2.video.VideoEncoderConfiguration.STANDARD_BITRATE;
import static io.agora.rtc2.video.VideoEncoderConfiguration.VD_640x360;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.util.DisplayMetrics;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMTranslationResult;
import com.hyphenate.easeui.R;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.manager.EaseAtMessageHelper;
import com.hyphenate.easeui.modules.chat.EaseChatFragment;
import com.hyphenate.easeui.modules.chat.EaseChatLayout;
import com.hyphenate.easeui.modules.chat.TokenUtils;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseFileUtils;
import com.hyphenate.easeui.utils.EaseImageUtils;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.ImageUtils;
import com.hyphenate.util.PathUtil;

import java.io.File;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.Map;

import io.agora.rtc2.ChannelMediaOptions;
import io.agora.rtc2.Constants;
import io.agora.rtc2.RtcEngine;
import io.agora.rtc2.RtcEngineConfig;
import io.agora.rtc2.RtcEngineEx;
import io.agora.rtc2.ScreenCaptureParameters;
import io.agora.rtc2.video.VideoEncoderConfiguration;

public class EaseHandleMessagePresenterImpl extends EaseHandleMessagePresenter {
    private static final String TAG = EaseChatLayout.class.getSimpleName();
    private RtcEngineEx mEngine;

    @Override
    public void sendTextMessage(String content) {
        sendTextMessage(content, false);
    }

    @Override
    public void sendTextMessage(String content, boolean isNeedGroupAck) {
        if(EaseAtMessageHelper.get().containsAtUsername(content)) {
            sendAtMessage(content);
            return;
        }
        EMMessage message = EMMessage.createTxtSendMessage(content, toChatUsername);
        message.setIsNeedGroupAck(isNeedGroupAck);
        sendMessage(message);
    }

    @Override
    public void sendAtMessage(String content) {
        if(!isGroupChat()){
            EMLog.e(TAG, "only support group chat message");
            if(isActive()) {
                runOnUI(()-> mView.sendMessageFail("only support group chat message"));
            }
            return;
        }
        EMMessage message = EMMessage.createTxtSendMessage(content, toChatUsername);
        EMGroup group = EMClient.getInstance().groupManager().getGroup(toChatUsername);
        if(EMClient.getInstance().getCurrentUser().equals(group.getOwner()) && EaseAtMessageHelper.get().containsAtAll(content)){
            message.setAttribute(EaseConstant.MESSAGE_ATTR_AT_MSG, EaseConstant.MESSAGE_ATTR_VALUE_AT_MSG_ALL);
        }else {
            message.setAttribute(EaseConstant.MESSAGE_ATTR_AT_MSG,
                    EaseAtMessageHelper.get().atListToJsonArray(EaseAtMessageHelper.get().getAtMessageUsernames(content)));
        }
        sendMessage(message);
    }

    @Override
    public void sendBigExpressionMessage(String name, String identityCode) {
        EMMessage message = EaseCommonUtils.createExpressionMessage(toChatUsername, name, identityCode);
        sendMessage(message);
    }

    @Override
    public void sendVoiceMessage(Uri filePath, int length) {
        EMMessage message = EMMessage.createVoiceSendMessage(filePath, length, toChatUsername);
        sendMessage(message);
    }

    @Override
    public void sendImageMessage(Uri imageUri) {
        sendImageMessage(imageUri, false);
    }

    @Override
    public void sendCustomMessage(String code) {
        EMMessage customMessage = EMMessage.createSendMessage(EMMessage.Type.CUSTOM);
        String event = "video_online";
        EMCustomMessageBody customBody = new EMCustomMessageBody(event);
        Map<String,String> params = new HashMap<>();
        params.put("code",code);
        customBody.setParams(params);
        customMessage.addBody(customBody);
        customMessage.setTo(toChatUsername);
        sendMessage(customMessage);
    }

    @Override
    public void sendImageMessage(Uri imageUri, boolean sendOriginalImage) {
        //Compatible with web and does not support heif image terminal
        //convert heif format to jpeg general image format
        imageUri = handleImageHeifToJpeg(imageUri);
        EMMessage message = EMMessage.createImageSendMessage(imageUri, sendOriginalImage, toChatUsername);
        sendMessage(message);
    }

    @Override
    public void sendLocationMessage(double latitude, double longitude, String locationAddress, String buildingName) {
        EMMessage message = EMMessage.createLocationSendMessage(latitude, longitude, locationAddress, buildingName, toChatUsername);
        EMLog.i(TAG, "current = "+EMClient.getInstance().getCurrentUser() + " to = "+toChatUsername);
        EMMessageBody body = message.getBody();
        String msgId = message.getMsgId();
        String from = message.getFrom();
        EMLog.i(TAG, "body = "+body);
        EMLog.i(TAG, "msgId = "+msgId + " from = "+from);
        sendMessage(message);
    }

    @Override
    public void sendVideoMessage(Uri videoUri, int videoLength) {
        String thumbPath = getThumbPath(videoUri);
        EMMessage message = EMMessage.createVideoSendMessage(videoUri, thumbPath, videoLength, toChatUsername);
        sendMessage(message);
    }

    @Override
    public void sendFileMessage(Uri fileUri) {
        EMMessage message = EMMessage.createFileSendMessage(fileUri, toChatUsername);
        sendMessage(message);
    }

    @Override
    public void addMessageAttributes(EMMessage message) {
        //可以添加一些自定义属性
        mView.addMsgAttrBeforeSend(message);
    }

    @Override
    public void sendMessage(EMMessage message) {
        if(message == null) {
            if(isActive()) {
                runOnUI(() -> mView.sendMessageFail("message is null!"));
            }
            return;
        }
        addMessageAttributes(message);
        if (chatType == EaseConstant.CHATTYPE_GROUP){
            message.setChatType(EMMessage.ChatType.GroupChat);
        }else if(chatType == EaseConstant.CHATTYPE_CHATROOM){
            message.setChatType(EMMessage.ChatType.ChatRoom);
        }
        message.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {
                if(isActive()) {
                    runOnUI(()-> mView.onPresenterMessageSuccess(message));
                }
            }

            @Override
            public void onError(int code, String error) {
                if(isActive()) {
                    runOnUI(()-> mView.onPresenterMessageError(message, code, error));
                }
            }

            @Override
            public void onProgress(int progress, String status) {
                if(isActive()) {
                    runOnUI(()-> mView.onPresenterMessageInProgress(message, progress));
                }
            }
        });
        message.setIsChannelMessage(isChannel);
        message.setIsChatThreadMessage(isThread);
        // send message
        EMClient.getInstance().chatManager().sendMessage(message);
        if(isActive()) {
            runOnUI(()-> mView.sendMessageFinish(message));
        }
    }

    @Override
    public void sendCmdMessage(String action) {
        EMMessage beginMsg = EMMessage.createSendMessage(EMMessage.Type.CMD);
        EMCmdMessageBody body = new EMCmdMessageBody(action);
        // Only deliver this cmd msg to online users
        body.deliverOnlineOnly(true);
        beginMsg.addBody(body);
        beginMsg.setTo(toChatUsername);
        EMClient.getInstance().chatManager().sendMessage(beginMsg);
    }

    @Override
    public void resendMessage(EMMessage message) {
        message.setStatus(EMMessage.Status.CREATE);
        long currentTimeMillis = System.currentTimeMillis();
        message.setLocalTime(currentTimeMillis);
        message.setMsgTime(currentTimeMillis);
        EMClient.getInstance().chatManager().updateMessage(message);
        sendMessage(message);
    }

    @Override
    public void deleteMessage(EMMessage message) {
        conversation.removeMessage(message.getMsgId());
        if(isActive()) {
            runOnUI(()->mView.deleteLocalMessageSuccess(message));
        }
    }

    @Override
    public void recallMessage(EMMessage message) {
        try {
            EMMessage msgNotification = EMMessage.createSendMessage(EMMessage.Type.TXT);
            EMTextMessageBody txtBody = new EMTextMessageBody(mView.context().getResources().getString(R.string.msg_recall_by_self));
            msgNotification.addBody(txtBody);
            msgNotification.setTo(message.getTo());
            msgNotification.setDirection(message.direct());
            msgNotification.setMsgTime(message.getMsgTime());
            msgNotification.setLocalTime(message.getMsgTime());
            msgNotification.setAttribute(EaseConstant.MESSAGE_TYPE_RECALL, true);
            msgNotification.setAttribute(EaseConstant.MESSAGE_TYPE_RECALLER, EMClient.getInstance().getCurrentUser());
            msgNotification.setStatus(EMMessage.Status.SUCCESS);
            msgNotification.setIsChannelMessage(message.isChannelMessage());
            msgNotification.setIsChatThreadMessage(message.isChatThreadMessage());
            EMClient.getInstance().chatManager().recallMessage(message);
            EMClient.getInstance().chatManager().saveMessage(msgNotification);
            if(isActive()) {
                runOnUI(()->mView.recallMessageFinish(message,msgNotification));
            }
        } catch (HyphenateException e) {
            e.printStackTrace();
            if(isActive()) {
                runOnUI(()->mView.recallMessageFail(e.getErrorCode(), e.getDescription()));
            }
        }
    }

    @Override
    public void translateMessage(EMMessage message, String languageCode, boolean isTranslation) {
        EMTextMessageBody body = (EMTextMessageBody) message.getBody();
        if(isTranslation) {
            EMTranslationResult result = EMClient.getInstance().translationManager().getTranslationResult(message.getMsgId());
            if (result != null) {
                result.setShowTranslation(true);
                EMClient.getInstance().translationManager().updateTranslationResult(result);
                if(isActive()) {
                    runOnUI(()->mView.translateMessageSuccess(message));
                }
                return;
            }
        }
        EMClient.getInstance().translationManager().translate(message.getMsgId(),
                message.conversationId(),
                body.getMessage(),
                languageCode,
                new EMValueCallBack<EMTranslationResult>() {
                    @Override
                    public void onSuccess(EMTranslationResult value) {
                        if(isActive()) {
                            runOnUI(()->mView.translateMessageSuccess(message));
                        }
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if(isActive()) {
                            runOnUI(()->mView.translateMessageFail(message, error, errorMsg));
                        }
                    }
                });
    }

    @Override
    public void hideTranslate(EMMessage message) {
        EMTranslationResult result = EMClient.getInstance().translationManager().getTranslationResult(message.getMsgId());
        result.setShowTranslation(false);
        EMClient.getInstance().translationManager().updateTranslationResult(result);
    }

    /**
     * 获取视频封面
     * @param videoUri
     * @return
     */
    private String getThumbPath(Uri videoUri) {
        if(!EaseFileUtils.isFileExistByUri(mView.context(), videoUri)) {
            return "";
        }
        String filePath = EaseFileUtils.getFilePath(mView.context(), videoUri);
        File file = new File(PathUtil.getInstance().getVideoPath(), "thvideo" + System.currentTimeMillis()+".jpeg");
        boolean createSuccess = true;
        if(!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
            try {
                FileOutputStream fos = new FileOutputStream(file);
                Bitmap ThumbBitmap = ThumbnailUtils.createVideoThumbnail(filePath, 3);
                ThumbBitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
                EMLog.e(TAG, e.getMessage());
                if(isActive()) {
                    runOnUI(() -> mView.createThumbFileFail(e.getMessage()));
                }
                createSuccess = false;
            }
        }else {
            try {
                FileOutputStream fos = new FileOutputStream(file);
                MediaMetadataRetriever media = new MediaMetadataRetriever();
                media.setDataSource(mView.context(), videoUri);
                Bitmap frameAtTime = media.getFrameAtTime();
                frameAtTime.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
                EMLog.e(TAG, e.getMessage());
                if(isActive()) {
                    runOnUI(() -> mView.createThumbFileFail(e.getMessage()));
                }
                createSuccess = false;
            }
        }
        return createSuccess ? file.getAbsolutePath() : "";
    }

    /**
     * 图片heif转jpeg
     *
     * @param imageUri 图片Uri
     * @return Uri
     */
    private Uri handleImageHeifToJpeg(Uri imageUri) {
        try {
            BitmapFactory.Options options;
            String filePath = EaseFileUtils.getFilePath(mView.context(), imageUri);
            if (!TextUtils.isEmpty(filePath) && new File(filePath).exists()) {
                options = ImageUtils.getBitmapOptions(filePath);
            } else {
                options = ImageUtils.getBitmapOptions(mView.context(), imageUri);
            }
            if ("image/heif".equalsIgnoreCase(options.outMimeType)) {
                imageUri = EaseImageUtils.imageToJpeg(mView.context(), imageUri, new File(PathUtil.getInstance().getImagePath(), "image_message_temp.jpeg"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return imageUri;
    }

    @Override
    public void addReaction(EMMessage message, String reaction) {
        EMClient.getInstance().chatManager().asyncAddReaction(message.getMsgId(), reaction, new EMCallBack() {
            @Override
            public void onSuccess() {
                if (isActive()) {
                    runOnUI(() -> mView.addReactionMessageSuccess(message));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                if (isActive()) {
                    runOnUI(() -> mView.addReactionMessageFail(message, error, errorMsg));
                }
            }

            @Override
            public void onProgress(int i, String s) {

            }
        });
    }

    @Override
    public void removeReaction(EMMessage message, String reaction) {
        EMClient.getInstance().chatManager().asyncRemoveReaction(message.getMsgId(), reaction, new EMCallBack() {
            @Override
            public void onSuccess() {
                if (isActive()) {
                    runOnUI(() -> mView.removeReactionMessageSuccess(message));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                if (isActive()) {
                    runOnUI(() -> mView.removeReactionMessageFail(message, error, errorMsg));
                }
            }

            @Override
            public void onProgress(int i, String s) {

            }
        });
    }

    @Override
    public void startVideo() {
        String channelId = String.valueOf(System.currentTimeMillis());
        //申请直播
        sendCustomMessage(channelId);

        //开启直播间
        startShare(channelId);
    }

    private void startShare(String channelId) {
        try {
            RtcEngineConfig config = new RtcEngineConfig();
            /**
             * The context of Android Activity
             */
            config.mContext = mView.context();
            /**
             * The App ID issued to you by Agora. See <a href="https://docs.agora.io/en/Agora%20Platform/token#get-an-app-id"> How to get the App ID</a>
             */
            config.mAppId = "cfa7cb6138d64ee59af5fbd381f70583";
            /** Sets the channel profile of the Agora RtcEngine.
             CHANNEL_PROFILE_COMMUNICATION(0): (Default) The Communication profile.
             Use this profile in one-on-one calls or group calls, where all users can talk freely.
             CHANNEL_PROFILE_LIVE_BROADCASTING(1): The Live-Broadcast profile. Users in a live-broadcast
             channel have a role as either broadcaster or audience. A broadcaster can both send and receive streams;
             an audience can only receive streams.*/
            config.mChannelProfile = Constants.CHANNEL_PROFILE_LIVE_BROADCASTING;
            /**
             * IRtcEngineEventHandler is an abstract class providing default implementation.
             * The SDK uses this class to report to the app on SDK runtime events.
             */
//            config.mEventHandler = iRtcEngineEventHandler;
            config.mAudioScenario = Constants.AudioScenario.getValue(Constants.AudioScenario.DEFAULT);
            config.mAreaCode = RtcEngineConfig.AreaCode.AREA_CODE_CN;
            mEngine = (RtcEngineEx) RtcEngine.create(config);
            /**
             * This parameter is for reporting the usages of APIExample to agora background.
             * Generally, it is not necessary for you to set this parameter.
             */
            mEngine.setParameters("{"
                    + "\"rtc.report_app_scenario\":"
                    + "{"
                    + "\"appScenario\":" + 100 + ","
                    + "\"serviceType\":" + 11 + ","
                    + "\"appVersion\":\"" + RtcEngine.getSdkVersion() + "\""
                    + "}"
                    + "}");
            joinChannel(channelId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private final ScreenCaptureParameters screenCaptureParameters = new ScreenCaptureParameters();

    private void joinChannel(String channelId) {
        mEngine.setParameters("{\"che.video.mobile_1080p\":true}");
        mEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);

        /**Enable video module*/
        mEngine.enableVideo();
        // Setup video encoding configs
        mEngine.setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                VD_640x360,
                FRAME_RATE_FPS_15,
                STANDARD_BITRATE,
                ORIENTATION_MODE_ADAPTIVE
        ));
        /**Set up to play remote sound with receiver*/
        mEngine.setDefaultAudioRoutetoSpeakerphone(true);

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Intent fgServiceIntent = new Intent(mView.context(), EaseChatFragment.MediaProjectFgService.class);
            EaseChatFragment.mContext.startForegroundService(fgServiceIntent);
        }

        DisplayMetrics metrics = new DisplayMetrics();
        EaseChatFragment.mContext.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
        screenCaptureParameters.captureVideo = true;
        screenCaptureParameters.videoCaptureParameters.width = 720;
        screenCaptureParameters.videoCaptureParameters.height = (int) (720 * 1.0f / metrics.widthPixels * metrics.heightPixels);
        screenCaptureParameters.videoCaptureParameters.framerate = 15;
        screenCaptureParameters.captureAudio = true;
        screenCaptureParameters.audioCaptureParameters.captureSignalVolume = 1;
        mEngine.startScreenCapture(screenCaptureParameters);


        /**Please configure accessToken in the string_config file.
         * A temporary token generated in Console. A temporary token is valid for 24 hours. For details, see
         *      https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#get-a-temporary-token
         * A token generated at the server. This applies to scenarios with high-security requirements. For details, see
         *      https://docs.agora.io/en/cloud-recording/token_server_java?platform=Java*/
        TokenUtils.gen(mView.context(), channelId, 0, accessToken -> {
            /** Allows a user to join a channel.
             if you do not specify the uid, we will generate the uid for you*/
            // set options
            ChannelMediaOptions options = new ChannelMediaOptions();
            options.clientRoleType = Constants.CLIENT_ROLE_BROADCASTER;
            options.autoSubscribeVideo = true;
            options.autoSubscribeAudio = true;
            options.publishCameraTrack = false;
            options.publishMicrophoneTrack = false;
            options.publishScreenCaptureVideo = true;
            options.publishScreenCaptureAudio = true;
            int res = mEngine.joinChannel(accessToken, channelId, 0, options);
        });
    }
}

