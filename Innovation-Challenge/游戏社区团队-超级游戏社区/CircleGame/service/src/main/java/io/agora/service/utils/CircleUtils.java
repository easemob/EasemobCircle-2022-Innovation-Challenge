package io.agora.service.utils;


import static io.agora.service.utils.InviteMessageStatus.BEINVITEED;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMCircleServer;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.exceptions.HyphenateException;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.common.dialog.AlertDialog;
import io.agora.service.R;
import io.agora.service.bean.ChannelInviteData;
import io.agora.service.bean.CustomInfo;
import io.agora.service.databinding.DialogJoinServerBinding;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;

public class CircleUtils {

    public static EMMessage createExpressionMessage(String toChatUsername, String expressioName, String identityCode) {
        EMMessage message = EMMessage.createTxtSendMessage("[" + expressioName + "]", toChatUsername);
        if (identityCode != null) {
            message.setAttribute(EaseConstant.MESSAGE_ATTR_EXPRESSION_ID, identityCode);
        }
        message.setAttribute(EaseConstant.MESSAGE_ATTR_IS_BIG_EXPRESSION, true);
        return message;
    }

    public static List<EMMessage> filterInviteNotification(List<EMMessage> messages) {
        List<EMMessage> filterDatas = new ArrayList<>();
        if (!CollectionUtils.isEmpty(messages)) {
            for (EMMessage msg : messages) {
                String statusParams = null;
                try {
                    statusParams = msg.getStringAttribute(Constants.SYSTEM_MESSAGE_STATUS);
                } catch (HyphenateException e) {
                    e.printStackTrace();
                }
                InviteMessageStatus status = InviteMessageStatus.valueOf(statusParams);
                if (status == BEINVITEED) {
                    filterDatas.add(msg);
                }
            }
        }
        return filterDatas;
    }

    public static void sendInviteCustomMessage(String type, CustomInfo customInfo, String to) {

        //往默认频道中发送一条自定义消息
        EMMessage customMessage = EMMessage.createSendMessage(EMMessage.Type.CUSTOM);
        // event为需要传递的自定义消息事件，比如礼物消息，可以设置event = "gift"
        EMCustomMessageBody customBody = new EMCustomMessageBody(type);
        // params类型为Map<String, String>
        Map<String, String> params = new HashMap<>();

        params.put(Constants.CUSTOM_MESSAGE_SERVER_ID, customInfo.getServerId());
        params.put(Constants.CUSTOM_MESSAGE_SERVER_NAME, customInfo.getServerName());
        params.put(Constants.CUSTOM_MESSAGE_SERVER_DESC, customInfo.getServerDesc());
        params.put(Constants.CUSTOM_MESSAGE_SERVER_ICON, customInfo.getServerIcon());
        params.put(Constants.CUSTOM_MESSAGE_CHANNEL_ID, customInfo.getChannelId());
        params.put(Constants.CUSTOM_MESSAGE_CHANNEL_NAME, customInfo.getChannelName());
        params.put(Constants.CUSTOM_MESSAGE_CHANNEL_DESC, customInfo.getChannelDesc());

        customBody.setParams(params);
        customMessage.addBody(customBody);
        // to指另一方环信id（或者群组id，聊天室id）
        customMessage.setTo(to);
        // 如果是群聊，设置chattype，默认是单聊
        if (TextUtils.equals(Constants.INVITE_SERVER, type) || TextUtils.equals(Constants.INVITE_CHANNEL, type)) {
            customMessage.setChatType(EMMessage.ChatType.Chat);
        } else {
            customMessage.setChatType(EMMessage.ChatType.GroupChat);
            customMessage.setIsChannelMessage(true);
        }
        EMClient.getInstance().chatManager().sendMessage(customMessage);
    }

    public static boolean checkAgoraChatAppKey(Context context) {
        String appPackageName = context.getPackageName();
        ApplicationInfo ai = null;
        try {
            ai = context.getPackageManager().getApplicationInfo(appPackageName, PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return false;
        }
        if (ai != null) {
            Bundle metaData = ai.metaData;
            if (metaData == null) {
                return false;
            }
            // read appkey
            String appKeyFromConfig = metaData.getString("EASEMOB_APPKEY");

            if (TextUtils.isEmpty(appKeyFromConfig) || !appKeyFromConfig.contains("#")) {
                return false;
            }
            return true;
        }
        return false;
    }

    public static void showServerInviteDialog(Activity activity, CustomInfo customInfo) {
        DialogJoinServerBinding joinServerBinding = DialogJoinServerBinding.inflate(activity.getLayoutInflater());
        AlertDialog dialog = new AlertDialog.Builder(activity)
                .setContentView(joinServerBinding.getRoot())
                .setCancelable(false)
                .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                .show();
        Glide.with(activity).load(customInfo.getServerIcon()).placeholder(R.drawable.circle_default_avatar).into(joinServerBinding.ivServer);
        joinServerBinding.tvServerName.setText(customInfo.getServerName());
        joinServerBinding.tvDesc.setText(customInfo.getServerDesc());
        joinServerBinding.btnCancel.setText(activity.getString(R.string.circle_temporarily_not_join));
        joinServerBinding.btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                EMClient.getInstance().chatCircleManager().declineServerInvitation(customInfo.getServerId(), customInfo.getInviter(), new EMCallBack() {
//                    @Override
//                    public void onSuccess() {
//                        ToastUtils.showShort(activity.getString(R.string.circle_decline_invitation_success));
//                    }
//
//                    @Override
//                    public void onError(int code, String message) {
//                        if (!TextUtils.isEmpty(message)) {
//                            ToastUtils.showShort(message);
//                        }
//                    }
//                });
                dialog.dismiss();
            }
        });
        joinServerBinding.btnJoinImmediately.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EMClient.getInstance().chatCircleManager().acceptServerInvitation(customInfo.getServerId(), customInfo.getInviter(), new EMValueCallBack<EMCircleServer>() {
                    @Override
                    public void onSuccess(EMCircleServer value) {
                        ToastUtils.showShort(activity.getString(R.string.circle_join_in_server_success));
                        CircleServer circleServer = new CircleServer(value);
                        circleServer.isJoined = true;
                        LiveEventBus.get(Constants.SERVER_CHANGED).post(circleServer);

                        CustomInfo customInfo = new CustomInfo();
                        customInfo.setServerId(value.getServerId());
                        customInfo.setServerName(value.getName());
                        customInfo.setServerIcon(value.getIcon());
                        customInfo.setServerDesc(value.getDesc());
                        customInfo.setChannelId(value.getDefaultChannelID());

                        sendInviteCustomMessage(Constants.ACCEPT_INVITE_SERVER, customInfo, value.getDefaultChannelID());
                    }

                    @Override
                    public void onError(int error, String message) {
                        if (!TextUtils.isEmpty(message)) {
                            ToastUtils.showShort(message);
                        }
                    }
                });
                dialog.dismiss();
            }
        });
    }

    public static void showChannelInviteDialog(Activity activity, CustomInfo customInfo) {
        DialogJoinServerBinding joinChannelBinding = DialogJoinServerBinding.inflate(activity.getLayoutInflater());
        AlertDialog dialog = new AlertDialog.Builder(activity)
                .setContentView(joinChannelBinding.getRoot())
                .setCancelable(false)
                .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                .show();
        joinChannelBinding.tvChannelName.setVisibility(View.VISIBLE);
        Glide.with(activity).load(customInfo.getServerIcon()).placeholder(R.drawable.circle_default_avatar).into(joinChannelBinding.ivServer);
        joinChannelBinding.tvServerName.setText(customInfo.getServerName());
        joinChannelBinding.tvDesc.setText(customInfo.getChannelDesc());
        joinChannelBinding.tvChannelName.setText(customInfo.getChannelName());
        joinChannelBinding.btnCancel.setText(activity.getString(R.string.circle_temporarily_not_join));
        joinChannelBinding.btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                EMClient.getInstance().chatCircleManager().declineChannelInvitation(customInfo.getServerId(), customInfo.getChannelId(), customInfo.getInviter(), new EMCallBack() {
//                    @Override
//                    public void onSuccess() {
//                        dialog.dismiss();
//                        ToastUtils.showShort(activity.getString(R.string.circle_decline_invitation_success));
//                    }
//
//                    @Override
//                    public void onError(int code, String message) {
//                        if (!TextUtils.isEmpty(message)) {
//                            ToastUtils.showShort(message);
//                        }
//                    }
//                });
                dialog.dismiss();
            }
        });
        joinChannelBinding.btnJoinImmediately.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EMClient.getInstance().chatCircleManager().acceptChannelInvitation(customInfo.getServerId(), customInfo.getChannelId(), customInfo.getInviter(), new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        ToastUtils.showShort(activity.getString(R.string.circle_join_in_channel_success));
                        LiveEventBus.get(Constants.ACCEPT_INVITE_CHANNEL).post(new ChannelInviteData(customInfo.getServerId(), customInfo.getChannelId()));

                        CustomInfo customInfo = new CustomInfo();
                        customInfo.setServerId(customInfo.getServerId());
                        customInfo.setServerName(customInfo.getServerName());
                        customInfo.setServerIcon(customInfo.getServerIcon());
                        customInfo.setChannelDesc(customInfo.getChannelDesc());
                        customInfo.setChannelId(customInfo.getChannelId());
                        customInfo.setChannelName(customInfo.getChannelName());

                        sendInviteCustomMessage(Constants.ACCEPT_INVITE_CHANNEL, customInfo, customInfo.getChannelId());
                    }

                    @Override
                    public void onError(int code, String message) {
                        if (!TextUtils.isEmpty(message)) {
                            ToastUtils.showShort(message);
                        }
                    }
                });
                dialog.dismiss();
            }
        });
    }
}
