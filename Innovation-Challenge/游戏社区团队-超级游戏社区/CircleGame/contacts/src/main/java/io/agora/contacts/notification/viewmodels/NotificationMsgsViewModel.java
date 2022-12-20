package io.agora.contacts.notification.viewmodels;

import android.app.Application;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.easeui.manager.EaseThreadManager;
import com.hyphenate.exceptions.HyphenateException;

import java.util.ArrayList;
import java.util.List;

import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.managers.NotificationMsgManager;
import io.agora.service.model.ServerViewModel;
import io.agora.service.utils.GroupHelper;
import io.agora.service.utils.SingleSourceLiveData;


public class NotificationMsgsViewModel extends ServerViewModel {

    private SingleSourceLiveData<List<EMMessage>> chatMessageObservable;
    private SingleSourceLiveData<List<EMMessage>> searchResultObservable;

    private NotificationMsgManager msgManager;


    public NotificationMsgsViewModel(@NonNull Application application) {
        super(application);
        chatMessageObservable = new SingleSourceLiveData<>();
        searchResultObservable = new SingleSourceLiveData<>();
        msgManager = NotificationMsgManager.getInstance();
    }


    public SingleSourceLiveData<List<EMMessage>> getChatMessageObservable() {
        return chatMessageObservable;
    }

    public void getAllMessages() {
        chatMessageObservable.setValue(msgManager.getAllMessages());
    }

    public LiveData<List<EMMessage>> getSearchResultObservable() {
        return searchResultObservable;
    }

    public void searchMsgs(String keyword) {
        EaseThreadManager.getInstance().runOnIOThread(() -> {
            List<EMMessage> messages = msgManager.getAllMessages();
            List<EMMessage> result = new ArrayList<>();
            if (messages != null && !messages.isEmpty()) {
                for (EMMessage message : messages) {
                    if (!msgManager.isNotificationMessage(message)) {
                        continue;
                    }
                    String groupId = null;

                    try {
                        groupId = message.getStringAttribute(Constants.SYSTEM_MESSAGE_GROUP_ID);
                    } catch (HyphenateException e) {
                        e.printStackTrace();
                    }
                    // Check id and content
                    if (!TextUtils.isEmpty(groupId)) {
                        if (groupId.contains(keyword)) {
                            result.add(message);
                            continue;
                        }
                        String groupName = GroupHelper.getGroupName(groupId);
                        if (groupName.contains(keyword)) {
                            result.add(message);
                            continue;
                        }
                    }
                    String from = null;
                    try {
                        from = message.getStringAttribute(Constants.SYSTEM_MESSAGE_FROM);
                    } catch (HyphenateException e) {
                        e.printStackTrace();
                    }
                    if (!TextUtils.isEmpty(from)) {
                        if (from.contains(keyword)) {
                            result.add(message);
                            continue;
                        }
                        CircleUser user = AppUserInfoManager.getInstance().getUserInfobyId(from);
                        if (user != null && user.getNickname().contains(keyword)) {
                            result.add(message);
                            continue;
                        }
                    }
                    EMMessageBody body = message.getBody();
                    if (body instanceof EMTextMessageBody) {
                        String content = ((EMTextMessageBody) body).getMessage();
                        if (!TextUtils.isEmpty(content) && content.contains(keyword)) {
                            result.add(message);
                        }
                    }
                }
            }
            searchResultObservable.postValue(result);
        });
    }
}
