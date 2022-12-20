package io.agora.service.global;


import android.content.Context;
import android.util.Log;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.easeui.EaseIM;
import com.hyphenate.easeui.domain.EaseAvatarOptions;
import com.hyphenate.easeui.domain.EaseUser;
import com.hyphenate.easeui.provider.EaseSettingsProvider;
import com.hyphenate.easeui.provider.EaseUserProfileProvider;
import com.hyphenate.push.EMPushConfig;
import com.hyphenate.push.EMPushHelper;
import com.hyphenate.push.EMPushType;
import com.hyphenate.push.PushListener;
import com.hyphenate.util.EMLog;

import java.util.List;

import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.managers.OptionsManager;
import io.agora.service.managers.PreferenceManager;
import io.agora.service.model.AppModel;

/**
 * App 服务大管家 ，管理sdk初始化等事务
 */
public class GlobalServer {
    private final String TAG = getClass().getSimpleName();
    private static final GlobalServer ourInstance = new GlobalServer();
    private Context mContext;
    private AppModel appModel;

    public static GlobalServer getInstance() {
        return ourInstance;
    }

    private GlobalServer() {
    }

    public void initHX(Context context) {
        this.mContext = context;
        appModel = new AppModel(context);
        //Initialize circle Chat SDK
        if (initSDK(context)) {
            // debug mode, you'd better set it to false, if you want release your App officially.
            EMClient.getInstance().setDebugMode(true);
            // Initialize Push
//            initPush(context);
//            // Initialize UIKit
            initEaseUI(context);
//            //Initialize presence
            AppUserInfoManager.getInstance().init();
//            //Initialize callKit
//            InitCallKit(context);
        }
    }

    private boolean initSDK(Context context) {
        EMOptions options = initChatOptions(context);
        if (options == null) {
            return false;
        }
        // 测试环境
//        options.setRestServer("a1-test.easemob.com");
//        options.setIMServer("msync-im-aws-bj.easemob.com");
//        options.setImPort(6717);

//        options.setAppKey(BuildConfig.circle_appkey);

        EaseIM.getInstance().init(context, options);
        return isSDKInit();

    }

    /**
     * Custom settings
     *
     * @param context
     * @return
     */
    private EMOptions initChatOptions(Context context) {
        Log.d(TAG, "init Circle Chat Options");

        EMOptions options = new EMOptions();
        // Sets whether to automatically accept friend invitations. Default is true
        options.setAcceptInvitationAlways(false);
        // Set whether read confirmation is required by the recipient
        options.setRequireAck(true);
        // Set whether confirmation of delivery is required by the recipient. Default: false
        options.setRequireDeliveryAck(true);
        // Set whether to delete chat messages when exiting (actively and passively) a group
        options.setDeleteMessagesAsExitGroup(OptionsManager.getInstance().isDeleteMessagesAsExitGroup());
        // Set whether to automatically accept group invitations
        options.setAutoAcceptGroupInvitation(OptionsManager.getInstance().isAutoAcceptGroupInvitation());
        options.setUsingHttpsOnly(true);
        // Use fpa by default
        options.setFpaEnable(true);

        /**
         * NOTE:You need to set up your own account to use the three-way push function, see the integration documentation
         */
        EMPushConfig.Builder builder = new EMPushConfig.Builder(context);

        // The FCM sender id should equals with the project_number in google-services.json
        builder.enableFCM("142290967082");
        options.setPushConfig(builder.build());

        return options;
    }

    public boolean isSDKInit() {
        return EMClient.getInstance().isSdkInited();
    }

    public void initPush(Context context) {

        if (EaseIM.getInstance().isMainProcess(context)) {
            EMPushHelper.getInstance().setPushListener(new PushListener() {
                @Override
                public void onError(EMPushType pushType, long errorCode) {
                    EMLog.e("PushClient", "Push client occur a error: " + pushType + " - " + errorCode);
                }

                @Override
                public boolean isSupportPush(EMPushType pushType, EMPushConfig pushConfig) {
//                    if (pushType == EMPushType.FCM) {
//                        EMLog.d("FCM", "GooglePlayServiceCode:" + GoogleApiAvailabilityLight.getInstance().isGooglePlayServicesAvailable(context));
//                        return GoogleApiAvailabilityLight.getInstance().isGooglePlayServicesAvailable(context) == ConnectionResult.SUCCESS;
//                    }
                    return super.isSupportPush(pushType, pushConfig);
                }
            });
        }
    }

    /**
     * ChatPresenter中添加了网络连接状态监听，多端登录监听，群组监听，联系人监听，聊天室监听
     *
     * @param context
     */
    private void initEaseUI(Context context) {
        //添加ChatPresenter,ChatPresenter中添加了网络连接状态监听，
        EaseIM.getInstance().addChatPresenter(GlobalEventMonitor.getInstance());
        EaseIM.getInstance()
                .setSettingsProvider(new EaseSettingsProvider() {
                    @Override
                    public boolean isMsgNotifyAllowed(EMMessage message) {
                        if (message == null) {
                            return appModel.getSettingMsgNotification();
                        }
                        if (!appModel.getSettingMsgNotification()) {
                            return false;
                        } else {
                            String chatUsename = null;
                            List<String> notNotifyIds = null;
                            // get user or group id which was blocked to show message notifications
                            if (message.getChatType() == EMMessage.ChatType.Chat) {
                                chatUsename = message.getFrom();
                                notNotifyIds = appModel.getDisabledIds();
                            } else {
                                chatUsename = message.getTo();
                                notNotifyIds = appModel.getDisabledGroups();
                            }

                            if (notNotifyIds == null || !notNotifyIds.contains(chatUsename)) {
                                return true;
                            } else {
                                return false;
                            }
                        }
                    }

                    @Override
                    public boolean isMsgSoundAllowed(EMMessage message) {
                        return appModel.getSettingMsgSound();
                    }

                    @Override
                    public boolean isMsgVibrateAllowed(EMMessage message) {
                        return appModel.getSettingMsgVibrate();
                    }

                    @Override
                    public boolean isSpeakerOpened() {
                        return appModel.getSettingMsgSpeaker();
                    }
                })
//                .setEmojiconInfoProvider(new EaseEmojiconInfoProvider() {
//                    @Override
//                    public EaseEmojicon getEmojiconInfo(String emojiconIdentityCode) {
//                        EaseEmojiconGroupEntity data = EmojiconExampleGroupData.getData();
//                        for(EaseEmojicon emojicon : data.getEmojiconList()){
//                            if(emojicon.getIdentityCode().equals(emojiconIdentityCode)){
//                                return emojicon;
//                            }
//                        }
//                        return null;
//                    }
//
//                    @Override
//                    public Map<String, Object> getTextEmojiconMapping() {
//                        return null;
//                    }
//                })
                .setAvatarOptions(getAvatarOptions())
                .setUserProvider(new EaseUserProfileProvider() {
                    @Override
                    public EaseUser getUser(String username) {
                        CircleUser circleUser = AppUserInfoManager.getInstance().getUserInfobyId(username);
                        return CircleUser.convertoEaseUser(circleUser);
                    }

                });
    }

    /**
     * 统一配置头像
     *
     * @return
     */
    private EaseAvatarOptions getAvatarOptions() {
        EaseAvatarOptions avatarOptions = new EaseAvatarOptions();
        avatarOptions.setAvatarShape(1);
        return avatarOptions;
    }

    /**
     * 设置本地标记，是否自动登录
     * @param autoLogin
     */
    public void setAutoLogin(boolean autoLogin) {
        PreferenceManager.getInstance().setAutoLogin(autoLogin);
    }

    /**
     * 获取本地标记，是否自动登录
     * @return
     */
    public boolean getAutoLogin() {
        return PreferenceManager.getInstance().getAutoLogin();
    }

}
