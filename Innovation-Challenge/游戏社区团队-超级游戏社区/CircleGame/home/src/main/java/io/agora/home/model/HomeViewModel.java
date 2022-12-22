package io.agora.home.model;

import android.app.Application;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMConversation;

import java.util.List;

import io.agora.home.repo.ConversationReposity;
import io.agora.service.model.ServerViewModel;


public class HomeViewModel extends ServerViewModel {
    public ConversationReposity reposity=new ConversationReposity();
    public HomeViewModel(@NonNull Application application) {
        super(application);
    }
    public List<EMConversation> getConversationsWithType(EMConversation.EMConversationType type) {
        return reposity.getConversationsWithType(type);
    }
}
