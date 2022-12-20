package io.agora.home.ui;

import android.app.Application;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMConversation;

import java.util.List;

import io.agora.home.repo.ConversationReposity;
import io.agora.service.model.ServiceViewModel;

public class ConversationListViewModel extends ServiceViewModel {

    public ConversationReposity reposity=new ConversationReposity();

    public ConversationListViewModel(@NonNull Application application) {
        super(application);
    }

    public List<EMConversation> getAllConversations() {
        return reposity.getAllConversations();
    }
    public List<EMConversation> getConversationsWithType(EMConversation.EMConversationType type) {
        return reposity.getConversationsWithType(type);
    }
}