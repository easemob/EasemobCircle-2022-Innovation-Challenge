package io.agora.service.model;

import android.app.Application;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMPresence;

import java.util.ArrayList;
import java.util.List;

import io.agora.common.base.BaseViewModel;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.net.Resource;
import io.agora.service.repo.ServiceReposity;
import io.agora.service.utils.SingleSourceLiveData;


/**
 * 存放一些与业务相关的公用功能
 */
public class ServiceViewModel extends BaseViewModel {
   private ServiceReposity serviceReposity;
   private SingleSourceLiveData<Resource<Boolean>> publishObservable;
   private SingleSourceLiveData<Resource<List<EMPresence>>> presencesObservable;

   public ServiceViewModel(@NonNull Application application) {
      super(application);
      serviceReposity = new ServiceReposity();
      publishObservable = new SingleSourceLiveData<>();
      presencesObservable = new SingleSourceLiveData<>();

   }

   public LiveData<Resource<Boolean>> getPublishObservable() {
      return publishObservable;
   }

   public void publishPresence(String ext) {
      publishObservable.setSource(serviceReposity.publishPresence(ext));
   }

   public LiveData<Resource<List<EMPresence>>> presencesObservable() {
      return presencesObservable;
   }


   public void subscribePresences(List<String> users, long expiry) {
      List<String> ids = new ArrayList<>();
      if (users != null && !users.isEmpty()) {
         for (String user : users) {
            //不能订阅自己，否则会error
            if(TextUtils.equals(user, EMClient.getInstance().getCurrentUser())) {
               continue;
            }
            ids.add(user);
         }
         presencesObservable.setSource(serviceReposity.subscribePresences(ids, expiry));
      }
   }
   public void subscribePresencesWithUsers(List<CircleUser> users, long expiry) {
      List<String> ids = new ArrayList<>();
      if (users != null && !users.isEmpty()) {
         for (CircleUser user : users) {
            //不能订阅自己，否则会error
            if(TextUtils.equals(user.getUsername(), EMClient.getInstance().getCurrentUser())) {
               continue;
            }
            ids.add(user.getUsername());
         }
         presencesObservable.setSource(serviceReposity.subscribePresences(ids, expiry));
      }
   }
   public void subscribePresences(String userName, long expiry) {
      List<String> ids = new ArrayList<>();
      ids.add(userName);
      presencesObservable.setSource(serviceReposity.subscribePresences(ids, expiry));

   }
}
