package io.agora.chat.viewmodel;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;

import java.util.List;

import io.agora.service.model.ServiceViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.EMChatManagerRepository;
import io.agora.service.repo.EMChatRoomManagerRepository;
import io.agora.service.utils.SingleSourceLiveData;

public class ChatViewModel extends ServiceViewModel {
    private EMChatRoomManagerRepository chatRoomManagerRepository;
    private EMChatManagerRepository chatManagerRepository;
    private SingleSourceLiveData<Resource<EMChatRoom>> chatRoomObservable;
    private SingleSourceLiveData<Resource<Boolean>> makeConversationReadObservable;
    private SingleSourceLiveData<Resource<List<String>>> getNoPushUsersObservable;
    private SingleSourceLiveData<Resource<Boolean>> setNoPushUsersObservable;
    public SingleSourceLiveData<Resource<String>> deleteConversationLiveData = new SingleSourceLiveData<>();

    public ChatViewModel(@NonNull Application application) {
        super(application);
        chatRoomManagerRepository = new EMChatRoomManagerRepository();
        chatManagerRepository = new EMChatManagerRepository();
        chatRoomObservable = new SingleSourceLiveData<>();
        makeConversationReadObservable = new SingleSourceLiveData<>();
        getNoPushUsersObservable = new SingleSourceLiveData<>();
        setNoPushUsersObservable = new SingleSourceLiveData<>();
    }

    public LiveData<Resource<EMChatRoom>> getChatRoomObservable() {
        return chatRoomObservable;
    }

    public LiveData<Resource<List<String>>> getNoPushUsersObservable() {
        return getNoPushUsersObservable;
    }

    public LiveData<Resource<Boolean>> setNoPushUsersObservable() {
        return setNoPushUsersObservable;
    }

    public void getChatRoom(String roomId) {
        EMChatRoom room = EMClient.getInstance().chatroomManager().getChatRoom(roomId);
        if (room != null) {
            chatRoomObservable.setSource(new MutableLiveData<>(Resource.success(room)));
        } else {
            chatRoomObservable.setSource(chatRoomManagerRepository.getChatRoomById(roomId));
        }
    }

    public void makeConversationReadByAck(String conversationId) {
        makeConversationReadObservable.setSource(chatManagerRepository.makeConversationReadByAck(conversationId));
    }

    /**
     * 设置单聊用户聊天免打扰
     *
     * @param userId 用户名
     * @param noPush 是否免打扰
     */
    public void setUserNotDisturb(String userId, boolean noPush) {
        setNoPushUsersObservable.setSource(chatManagerRepository.setUserNotDisturb(userId, noPush));
    }

    /**
     * 获取聊天免打扰用户
     */
    public void getNoPushUsers() {
        getNoPushUsersObservable.setSource(chatManagerRepository.getNoPushUsers());
    }

    public LiveData<Resource<Boolean>> getMakeConversationReadObservable() {
        return makeConversationReadObservable;
    }

    public void deleteConversationById(String conversationId) {
        deleteConversationLiveData.setSource(chatManagerRepository.deleteConversationById(conversationId));
    }
}
