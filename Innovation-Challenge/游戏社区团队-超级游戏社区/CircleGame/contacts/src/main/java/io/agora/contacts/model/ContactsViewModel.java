package io.agora.contacts.model;

import android.app.Application;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMConversation;

import java.util.List;

import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.NotificationMsgManager;
import io.agora.service.model.ServiceViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.EMContactManagerRepository;
import io.agora.service.utils.SingleSourceLiveData;

public class ContactsViewModel extends ServiceViewModel {
    private SingleSourceLiveData<EMConversation> conversationObservable;
    private NotificationMsgManager msgManager;
    private EMContactManagerRepository contactsReposity=new EMContactManagerRepository();
    public SingleSourceLiveData<Resource<Boolean>> deleteContactLiveData=new SingleSourceLiveData();
    public SingleSourceLiveData<Resource<Boolean>> addContactLiveData=new SingleSourceLiveData();
    public SingleSourceLiveData<Resource<List<CircleUser>>> getContactsLiveData=new SingleSourceLiveData();
    public SingleSourceLiveData<Resource<CircleUser>> getUserInfoLiveData=new SingleSourceLiveData();

    public ContactsViewModel(@NonNull Application application) {
        super(application);
        conversationObservable = new SingleSourceLiveData<>();
        msgManager=NotificationMsgManager.getInstance();
    }

    public SingleSourceLiveData<EMConversation> getConversationObservable() {
        return conversationObservable;
    }

    public void getMsgConversation() {
        conversationObservable.setValue(msgManager.getConversation());
    }

    public void deleteFriend(String username) {
        deleteContactLiveData.setSource( contactsReposity.deleteContact(username));
    }
    public void addFriend(String username) {
        addContactLiveData.setSource( contactsReposity.addContact(username,null));
    }

    public void getContactsFromServer() {
        getContactsLiveData.setSource(contactsReposity.getContactList(true));
    }

    public void getUserInfoById(String username) {
        getUserInfoLiveData.setSource(contactsReposity.getUserInfoById(username));
    }
}