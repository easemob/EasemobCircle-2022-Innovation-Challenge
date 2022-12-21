package io.agora.contacts.notification.viewmodels;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.manager.EaseThreadManager;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.exceptions.HyphenateException;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import io.agora.contacts.R;
import io.agora.service.global.Constants;
import io.agora.service.managers.NotificationMsgManager;
import io.agora.service.net.Resource;
import io.agora.service.utils.InviteMessageStatus;
import io.agora.service.utils.SingleSourceLiveData;


public class NewFriendsViewModel extends AndroidViewModel {
    private SingleSourceLiveData<List<EMMessage>> inviteMsgObservable;
    private SingleSourceLiveData<List<EMMessage>> moreInviteMsgObservable;
    private MutableLiveData<Resource<Boolean>> resultObservable;
    private MutableLiveData<Resource<String>> agreeObservable;
    private MutableLiveData<Resource<String>> refuseObservable;

    public NewFriendsViewModel(@NonNull Application application) {
        super(application);
        inviteMsgObservable = new SingleSourceLiveData<>();
        moreInviteMsgObservable = new SingleSourceLiveData<>();
        resultObservable = new MutableLiveData<>();
        agreeObservable = new MutableLiveData<>();
        refuseObservable = new MutableLiveData<>();
    }


    public LiveData<List<EMMessage>> inviteMsgObservable() {
        return inviteMsgObservable;
    }

    public LiveData<List<EMMessage>> moreInviteMsgObservable() {
        return moreInviteMsgObservable;
    }

    public void loadMessages(int limit) {
        List<EMMessage> emMessages = EMClient.getInstance().chatManager().searchMsgFromDB(EMMessage.Type.TXT
                , System.currentTimeMillis(), limit, EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID, EMConversation.EMSearchDirection.UP);
        sortData(emMessages);
        inviteMsgObservable.setSource(new MutableLiveData<>(emMessages));
    }

    public void loadMoreMessages(String targetId, int limit) {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID, EMConversation.EMConversationType.Chat, true);
        List<EMMessage> messages = conversation.loadMoreMsgFromDB(targetId, limit);
        sortData(messages);
        moreInviteMsgObservable.setSource(new MutableLiveData<>(messages));
    }
    
    private void sortData(List<EMMessage> messages) {
        Collections.sort(messages, new Comparator<EMMessage>() {
            @Override
            public int compare(EMMessage o1, EMMessage o2) {
                long o1MsgTime = o1.getMsgTime();
                long o2MsgTime = o2.getMsgTime();
                return (int) (o2MsgTime - o1MsgTime);
            }
        });
    }

    public LiveData<Resource<Boolean>> resultObservable() {
        return resultObservable;
    }

    public LiveData<Resource<String>> agreeObservable() {
        return agreeObservable;
    }
    public LiveData<Resource<String>> refuseObservable() {
        return refuseObservable;
    }

    public void agreeInvite(EMMessage msg) {
        EaseThreadManager.getInstance().runOnIOThread(() -> {
            try {
                String statusParams = msg.getStringAttribute(Constants.SYSTEM_MESSAGE_STATUS);
                InviteMessageStatus status = InviteMessageStatus.valueOf(statusParams);
                String message = "";
                if (status == InviteMessageStatus.BEINVITEED) {//accept be friends
                    message = getApplication().getString(io.agora.service.R.string.system_agree_invite, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
                    EMClient.getInstance().contactManager().acceptInvitation(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
//                    EMClient.getInstance().contactManager().asyncAcceptInvitation(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM), new EMCallBack() {
//                        @Override
//                        public void onSuccess() {
//                            try {
//                                saveNotificationMessage(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM),Constants.SYSTEM_ADD_CONTACT,getApplication().getString(io.agora.service.R.string.contact_agreed_request));
//                            } catch (HyphenateException e) {
//                                e.printStackTrace();
//                            }
//                        }
//
//                        @Override
//                        public void onError(int code, String error) {
//                            EMLog.e("asyncAcceptInvitation",  "error:" + error + " errorMsg:" +error);
//                        }
//                    });
                } else if (status == InviteMessageStatus.BEAPPLYED) { //accept application to join group
                    message = getApplication().getString(io.agora.service.R.string.system_agree_remote_user_apply_to_join_group, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
                    EMClient.getInstance().groupManager().acceptApplication(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM), msg.getStringAttribute(Constants.SYSTEM_MESSAGE_GROUP_ID));
                } else if (status == InviteMessageStatus.GROUPINVITATION) {
                    message = getApplication().getString(io.agora.service.R.string.system_agree_received_remote_user_invitation, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_INVITER));
                    EMClient.getInstance().groupManager().acceptInvitation(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_GROUP_ID)
                            , msg.getStringAttribute(Constants.SYSTEM_MESSAGE_INVITER));
                }
                msg.setAttribute(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.AGREED.name());
                msg.setAttribute(Constants.SYSTEM_MESSAGE_REASON, message);
                EMTextMessageBody body = new EMTextMessageBody(message);
                msg.setBody(body);
                NotificationMsgManager.getInstance().updateMessage(msg);
                agreeObservable.postValue(Resource.success(message));
            } catch (HyphenateException e) {
                e.printStackTrace();
                msg.setAttribute(Constants.SYSTEM_MESSAGE_EXPIRED, R.string.system_msg_expired);
                agreeObservable.postValue(Resource.error(e.getErrorCode(), e.getMessage(), ""));
            }
            LiveEventBus.get(Constants.NOTIFY_CHANGE).post(null);
        });
    }

    public void refuseInvite(EMMessage msg) {
        EaseThreadManager.getInstance().runOnIOThread(() -> {
            try {
                String statusParams = msg.getStringAttribute(Constants.SYSTEM_MESSAGE_STATUS);
                InviteMessageStatus status = InviteMessageStatus.valueOf(statusParams);
                String message = "";
                if (status == InviteMessageStatus.BEINVITEED) {//decline the invitation
                    message = getApplication().getString(io.agora.service.R.string.system_decline_invite, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
                    EMClient.getInstance().contactManager().declineInvitation(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
                } else if (status == InviteMessageStatus.BEAPPLYED) { //decline application to join group
                    message = getApplication().getString(io.agora.service.R.string.system_decline_remote_user_apply_to_join_group, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM));
                    EMClient.getInstance().groupManager().declineApplication(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM)
                            , msg.getStringAttribute(Constants.SYSTEM_MESSAGE_GROUP_ID), "");
                } else if (status == InviteMessageStatus.GROUPINVITATION) {
                    message = getApplication().getString(io.agora.service.R.string.system_decline_received_remote_user_invitation, msg.getStringAttribute(Constants.SYSTEM_MESSAGE_INVITER));
                    EMClient.getInstance().groupManager().declineInvitation(msg.getStringAttribute(Constants.SYSTEM_MESSAGE_GROUP_ID)
                            , msg.getStringAttribute(Constants.SYSTEM_MESSAGE_INVITER), "");
                }
                msg.setAttribute(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.REFUSED.name());
                msg.setAttribute(Constants.SYSTEM_MESSAGE_REASON, message);
                EMTextMessageBody body = new EMTextMessageBody(message);
                msg.setBody(body);
                NotificationMsgManager.getInstance().updateMessage(msg);
                refuseObservable.postValue(Resource.success(message));
               } catch (HyphenateException e) {
                e.printStackTrace();
                msg.setAttribute(Constants.SYSTEM_MESSAGE_EXPIRED, R.string.system_msg_expired);
                refuseObservable.postValue(Resource.error(e.getErrorCode(), e.getMessage(), ""));
            }
            LiveEventBus.get(Constants.NOTIFY_CHANGE).post(null);
        });
    }

    public void deleteMsg(EMMessage message) {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(Constants.DEFAULT_SYSTEM_MESSAGE_ID, EMConversation.EMConversationType.Chat, true);
        conversation.removeMessage(message.getMsgId());
        resultObservable.postValue(Resource.success(true));
    }

    public void makeAllMsgRead() {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(Constants.DEFAULT_SYSTEM_MESSAGE_ID, EMConversation.EMConversationType.Chat, true);
        conversation.markAllMessagesAsRead();
        LiveEventBus.get(Constants.NOTIFY_CHANGE).post(null);
    }

    public void saveNotificationMessage(String to,String constant,String content){
        EMMessage msg = EMMessage.createSendMessage(EMMessage.Type.TXT);
        msg.setChatType(EMMessage.ChatType.Chat);
        msg.setTo(to);
        msg.setMsgId(UUID.randomUUID().toString());
        msg.setAttribute(Constants.EASE_SYSTEM_NOTIFICATION_TYPE, true);
        msg.setAttribute(Constants.SYSTEM_NOTIFICATION_TYPE, constant);
        msg.addBody(new EMTextMessageBody(content));
        msg.setStatus(EMMessage.Status.SUCCESS);
        // save invitation as messages
        EMClient.getInstance().chatManager().saveMessage(msg);
        EaseEvent event = EaseEvent.create(Constants.MESSAGE_CHANGE_RECEIVE, EaseEvent.TYPE.MESSAGE);
//        Intent intent = new Intent(getApplication(), ChatActivity.class);
//        intent.putExtra(EaseConstant.EXTRA_CONVERSATION_ID, to);
//        intent.putExtra(EaseConstant.EXTRA_CHAT_TYPE, EaseChatType.SINGLE_CHAT);
//        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        getApplication().startActivity(intent);
    }
}
