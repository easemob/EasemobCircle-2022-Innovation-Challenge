package io.agora.service.model;

import android.app.Application;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.databinding.ObservableField;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;
import androidx.lifecycle.Transformations;

import com.alibaba.android.arouter.utils.TextUtils;
import com.hyphenate.EMError;
import com.hyphenate.chat.EMCircleUserRole;

import java.util.List;

import io.agora.service.bean.CustomInfo;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.net.Resource;
import io.agora.service.repo.CircleServerReposity;
import io.agora.service.utils.SingleSourceLiveData;


/**
 * 对server的所有操作都放在这里
 */
public class ServerViewModel extends ServiceViewModel {

    public ObservableField<String> serverName = new ObservableField<>();

    private CircleServerReposity serverReposity = new CircleServerReposity();

    public SingleSourceLiveData<Resource<CircleServer>> createServerLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleServer>> updateServerLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<CircleServer>>> JoinedServerlistLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<CircleServer.Tag>>> getServerTagsLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<CircleServer.Tag>>> addServerTagsLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleServer>> removeServerTagLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<EMCircleUserRole>> selfRoleLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> addModeratorLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> removeModeratorLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleServer>> joinServerLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<String>> inviteToServerLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<String>> removeUserFromServerLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CustomInfo>> checkSelfIsInServerLiveData = new SingleSourceLiveData<>();

    public ServerViewModel(@NonNull Application application) {
        super(application);
    }

    public void createServer(String iconPath, String name, String desc) {
        if (TextUtils.isEmpty(iconPath)) {
            createServerLiveData.setSource(serverReposity.createServer("", name, desc));
        } else {
            serverReposity.uploadFile(mContext, iconPath).observeForever(new Observer<Resource<String>>() {
                @Override
                public void onChanged(Resource<String> urlRescouce) {
                    if (!TextUtils.isEmpty(urlRescouce.data)) {
                        //上传图片成功
                        createServerLiveData.setSource(serverReposity.createServer(urlRescouce.data, name, desc));
                    } else {
                        //由于livedata粘性的存在，这种方式会导致一进来就回调到这里，所以需要过滤下
                        if (urlRescouce.errorCode == EMError.GENERAL_ERROR) {
                            //上传图片失败
                            Resource<CircleServer> value = Resource.error(urlRescouce.errorCode, urlRescouce.data, null);
                            createServerLiveData.setValue(value);
                        }
                    }
                }
            });
        }
    }

    public void updateServer(CircleServer circleServer, String iconPath, String name, String desc) {
        if (TextUtils.isEmpty(iconPath) || android.text.TextUtils.equals(circleServer.icon, iconPath)) {
            updateServerLiveData.setSource(serverReposity.updateServer(circleServer.serverId, iconPath, name, desc));
        } else {
            serverReposity.uploadFile(mContext, iconPath).observeForever(new Observer<Resource<String>>() {
                @Override
                public void onChanged(Resource<String> urlRescouce) {
                    if (!TextUtils.isEmpty(urlRescouce.data)) {
                        //上传图片成功
                        updateServerLiveData.setSource(serverReposity.updateServer(circleServer.serverId, urlRescouce.data, name, desc));
                    } else {
                        //由于livedata粘性的存在，这种方式会导致一进来就回调到这里，所以需要过滤下
                        if (urlRescouce.errorCode == EMError.GENERAL_ERROR) {
                            //上传图片失败
                            Resource<CircleServer> value = Resource.error(urlRescouce.errorCode, urlRescouce.getMessage(mContext), null);
                            updateServerLiveData.setValue(value);
                        }
                    }
                }
            });
        }
    }

    public void getJoinedServerList() {
        JoinedServerlistLiveData.setSource(serverReposity.getServerJoinedList());
    }

    private MutableLiveData<String> serverIdLiveData = new MutableLiveData();
    public LiveData<Resource<List<CircleUser>>> serverMembersLiveData = Transformations.switchMap(serverIdLiveData, serverId -> {
        return serverReposity.getServerMembers(serverId);
    });

    public void getServerMembers(String serverId) {
        serverIdLiveData.setValue(serverId);
    }


    private MutableLiveData<String> deleteServerLiveData = new MutableLiveData();
    public LiveData<Resource<Boolean>> deleteServerResultLiveData = Transformations.switchMap(deleteServerLiveData, serverId -> {
        return serverReposity.deleteServer(serverId);
    });

    public void deleteServer(String serverID) {
        deleteServerLiveData.setValue(serverID);
    }

    private MutableLiveData<String> leaveServerLiveData = new MutableLiveData();
    public LiveData<Resource<Boolean>> leaveServerResultLiveData = Transformations.switchMap(leaveServerLiveData, serverId -> {
        return serverReposity.leaveServer(serverId);
    });

    public void leaveServer(String serverID) {
        leaveServerLiveData.setValue(serverID);
    }


    public void delete(View view) {
        serverName.set("");
    }

    public void fetchServerTags(String serverId) {
        getServerTagsLiveData.setSource(serverReposity.fetchServerTags(serverId));
    }

    public void addTagToServer(CircleServer circleServer, String tag) {
        addServerTagsLiveData.setSource(serverReposity.addTagToServer(circleServer, tag));
    }

    public void removeTagFromServer(CircleServer circleServer, CircleServer.Tag tag) {
        removeServerTagLiveData.setSource(serverReposity.removeTagFromServer(circleServer, tag));
    }

    public void fetchSelfServerRole(String serverID) {
        selfRoleLiveData.setSource(serverReposity.fetchSelfServerRole(serverID));
    }

    public void addModeratorToServer(String serverId, String username) {
        addModeratorLiveData.setSource(serverReposity.addModeratorToServer(serverId, username));
    }

    public void removeModeratorFromServer(String serverId, String username) {
        removeModeratorLiveData.setSource(serverReposity.removeModeratorFromServer(serverId, username));
    }

    public void joinServer(String serverId) {
        joinServerLiveData.setSource(serverReposity.joinServer(serverId));
    }

    public void inviteToServer(String serverId, String invitee, String welcome) {
        inviteToServerLiveData.setSource(serverReposity.inviteToServer(serverId, invitee, welcome));
    }

    public void removeUserFromServer(String serverId, String userId) {
        removeUserFromServerLiveData.setSource(serverReposity.removeUserFromServer(serverId, userId));
    }

    public void checkSelfIsInServer(CustomInfo info) {
        checkSelfIsInServerLiveData.setSource(serverReposity.checkSelfIsInServer(info));
    }
}
