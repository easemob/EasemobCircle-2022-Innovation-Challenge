package io.agora.home.repo;


import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import io.agora.service.managers.NotificationMsgManager;
import io.agora.service.repo.ServiceReposity;

public class ConversationReposity extends ServiceReposity {

    public List<EMConversation> getAllConversations() {
        Map<String, EMConversation> conversationsMap = EMClient.getInstance().chatManager().getAllConversations();
        Collection<EMConversation> values = conversationsMap.values();
        List<EMConversation> conversationList = new ArrayList<>();
        for (EMConversation value : values) {
            if (NotificationMsgManager.getInstance().isNotificationConversation(value)) {
                continue;
            }
            conversationList.add(value);
        }
        return conversationList;
    }

    public List<EMConversation> getConversationsWithType(EMConversation.EMConversationType type) {
        List<EMConversation> conversations = EMClient.getInstance().chatManager().getConversationsByType(type);
        for (int i = 0; i < conversations.size(); i++) {
            EMConversation conversation = conversations.get(i);
            if (NotificationMsgManager.getInstance().isNotificationConversation(conversation)) {
                conversations.remove(conversation);
                i--;
            }
        }
        return conversations;
    }
}
