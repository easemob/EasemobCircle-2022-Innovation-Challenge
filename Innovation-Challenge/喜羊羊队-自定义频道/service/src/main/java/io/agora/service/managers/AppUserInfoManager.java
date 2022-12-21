package io.agora.service.managers;


import android.text.TextUtils;
import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;

import com.blankj.utilcode.util.CacheDiskStaticUtils;
import com.blankj.utilcode.util.ThreadUtils;
import com.hyphenate.EMPresenceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.chat.EMUserInfo;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleUserDao;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.net.Resource;
import io.agora.service.repo.EMContactManagerRepository;

/**
 * 管理app用户信息类
 */
public class AppUserInfoManager {

    private ConcurrentHashMap<String, EMPresence> mPresences = new ConcurrentHashMap<>();

    private static final AppUserInfoManager ourInstance = new AppUserInfoManager();
    private Map<String, CircleServer> joinedServers = new ConcurrentHashMap<>();
    private Map<String, CircleUser> circleUsers = new HashMap<>();
    private MutableLiveData<Map<String, Integer>> selfServerRoleMapLiveData = new MutableLiveData<>();//key:serverId, value:roleId 存储自己在各社区的角色

    public static AppUserInfoManager getInstance() {
        return ourInstance;
    }

    private AppUserInfoManager() {
    }

    public void init() {
        addListener();
    }

    public void loadUsers() {

        List<CircleUser> users = getUserDao().loadAllCircleUsers();
        if (users != null) {
            for (CircleUser user : users) {
                circleUsers.put(user.getUsername(), user);
            }
        }
    }


    private void addListener() {
        EMClient.getInstance().presenceManager().addListener(new EMPresenceListener() {
            @Override
            public void onPresenceUpdated(List<EMPresence> presences) {
                for (EMPresence presence : presences) {
                    Log.d("TAG", presence.toString());
                    mPresences.put(presence.getPublisher(), presence);
                }
                LiveEventBus.get(Constants.PRESENCES_CHANGED).post(mPresences);
            }
        });
        LiveEventBus.get(Constants.USERINFO_CHANGE).observeForever(new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                loadUsers();
            }
        });
    }

    public ConcurrentHashMap<String, EMPresence> getPresences() {
        return mPresences;
    }


    public CircleUser getUserInfobyId(String userId) {
        CircleUser user = circleUsers.get(userId);
        if (user != null) {
            return user;
        } else {
            loadUsers();
            CircleUser circleUser = circleUsers.get(userId);
            if (circleUser != null) {
                return circleUser;
            }
            new EMContactManagerRepository().fetchUserInfoFromServer(userId, null);
            return null;
        }
    }

    public void getUserInfosbyIds(String[] userId) {
        LiveData<Resource<Map<String, EMUserInfo>>> liveData = new EMContactManagerRepository().fetchUsersInfoByUserIds(userId);
        ThreadUtils.runOnUiThread(() -> {
            liveData.observeForever(new Observer<Resource<Map<String, EMUserInfo>>>() {
                @Override
                public void onChanged(Resource<Map<String, EMUserInfo>> mapResource) {

                }
            });
        });

    }

    public boolean isCurrentUserFromOtherDevice(String username) {
        if (TextUtils.isEmpty(username)) {
            return false;
        }
        if (username.contains("/") && username.contains(EMClient.getInstance().getCurrentUser())) {
            return true;
        }
        return false;
    }

    public CircleUser getCurrentUser() {
        return getUserDao().loadUserByUserId(getCurrentUserName());
    }

    public LiveData<CircleUser> getCurrentUserLiveData() {
        LiveData<CircleUser> circleUserLiveData = getUserDao().loadUserLiveDataByUserId(getCurrentUserName());
        return circleUserLiveData;
    }

    public void saveCurrentUserName(String userName) {
        CacheDiskStaticUtils.put(Constants.USERNAME, userName);
    }

    public String getCurrentUserName() {
        String username = CacheDiskStaticUtils.getString(Constants.USERNAME);
        return username;
    }

    public void updateUserInfo(String userName) {
        getUserDao().deleteUser(userName);
        circleUsers.remove(userName);
        getUserInfobyId(userName);
    }

    public Map<String, CircleServer> getUserJoinedSevers() {
        return joinedServers;
    }

    public void clear() {
        joinedServers.clear();
        selfServerRoleMapLiveData.postValue(null);
    }

    public Map<String, CircleUser> getCircleUsers() {
        return circleUsers;
    }

    public LiveData<Map<String, Integer>> getSelfServerRoleMapLiveData() {
        return selfServerRoleMapLiveData;
    }

    public void saveSelfServerRole(String serverId, int roleId) {
        Map<String, Integer> serverRoleMap = selfServerRoleMapLiveData.getValue();
        if (serverRoleMap == null) {
            serverRoleMap = new HashMap<>();
        }
        serverRoleMap.put(serverId, roleId);
        selfServerRoleMapLiveData.postValue(serverRoleMap);
    }

    private CircleUserDao getUserDao() {
        CircleUserDao userDao = DatabaseManager.getInstance().getUserDao();
        if (userDao == null) {
            DatabaseManager.getInstance().initDB(getCurrentUserName());
            return DatabaseManager.getInstance().getUserDao();
        }
        return userDao;
    }
}
