package io.agora.service.repo;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;

import com.blankj.utilcode.util.ThreadUtils;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMContactManager;
import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.easeui.manager.EaseThreadManager;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.exceptions.HyphenateException;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import io.agora.service.callbacks.ResultCallBack;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleUserDao;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.net.ErrorCode;
import io.agora.service.net.NetworkBoundResource;
import io.agora.service.net.NetworkOnlyResource;
import io.agora.service.net.Resource;


public class EMContactManagerRepository extends ServiceReposity {
    private static final String TAG = EMContactManagerRepository.class.getSimpleName();

    public LiveData<Resource<Boolean>> addContact(String username, String reason) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                if (getCurrentUser().equalsIgnoreCase(username)) {
                    callBack.onError(ErrorCode.ADD_SELF_ERROR);
                    return;
                }
                List<String> users = null;
                if (getUserDao() != null) {
                    users = getUserDao().loadContactUsers();
                }
                if (users != null && users.contains(username)) {
                    if (getContactManager().getBlackListUsernames().contains(username)) {
                        callBack.onError(ErrorCode.FRIEND_BLACK_ERROR);
                        return;
                    }
                    callBack.onError(ErrorCode.FRIEND_ERROR);
                    return;
                }
                getContactManager().aysncAddContact(username, reason, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(new MutableLiveData<>(true));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
            }

        }.asLiveData();
    }


    public LiveData<Resource<Boolean>> deleteContact(String username) {
        return new NetworkOnlyResource<Boolean>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getContactManager().aysncDeleteContact(username, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        getUserDao().deleteUser(username);
                        getChatManager().deleteConversation(username, false);
                        callBack.onSuccess(createLiveData(true));
                        EaseEvent event = EaseEvent.create(Constants.CONTACT_DELETE, EaseEvent.TYPE.CONTACT);
                        LiveEventBus.get(Constants.CHANNEL_DELETE).post(event);
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
            }
        }.asLiveData();
    }


    public LiveData<Resource<List<CircleUser>>> getSearchContacts(String keyword) {
        return new NetworkOnlyResource<List<CircleUser>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleUser>>> callBack) {
                EaseThreadManager.getInstance().runOnIOThread(() -> {
                    List<CircleUser> circleUsers = null;
                    if (getUserDao() != null) {
                        circleUsers = getUserDao().loadContacts();
                    }
                    List<CircleUser> list = new ArrayList<>();
                    if (circleUsers != null && !circleUsers.isEmpty()) {
                        for (CircleUser user : circleUsers) {
                            if (user.getUsername().contains(keyword) || (!TextUtils.isEmpty(user.getNickname()) && user.getNickname().contains(keyword))) {
                                list.add(user);
                            }
                        }
                    }
                    if (list != null && list.size() > 1) {
                        sortData(list);
                    }
                    callBack.onSuccess(createLiveData(list));
                });

            }
        }.asLiveData();
    }

    public void fetchContactListFromServer(ResultCallBack<LiveData<List<CircleUser>>> callBack) {
        if (!isLoggedIn()) {
            if (callBack != null) {
                callBack.onError(ErrorCode.NOT_LOGIN);
            }
            return;
        }
        ThreadUtils.getCachedPool().execute(() -> {
            try {
                EMContactManager contactManager = EMClient.getInstance().contactManager();
                List<String> usernames = contactManager.getAllContactsFromServer();
//                List<String> ids = contactManager.getSelfIdsOnOtherPlatform();
                if (usernames == null) {
                    usernames = new ArrayList<>();
                }
//                if (ids != null && !ids.isEmpty()) {
//                    usernames.addAll(ids);
//                }
                EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(usernames.toArray(new String[usernames.size()]), new EMValueCallBack<Map<String, EMUserInfo>>() {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> value) {
                        List<CircleUser> users = CircleUser.parseEMUserInfos(value);

                        List<String> blackListFromServer = null;
                        try {
                            blackListFromServer = contactManager.getBlackListFromServer();
                        } catch (HyphenateException e) {
                            e.printStackTrace();
                            if (callBack != null) {
                                callBack.onError(e.getErrorCode(), e.getDescription());
                            }
                        }
                        for (CircleUser user : users) {
                            if (getUserDao() != null) {
                                CircleUser dbUser = getUserDao().loadUserByUserId(user.getUsername());
                                if (dbUser != null) {
                                    user.roleID = dbUser.roleID;
                                    user.inviteState = dbUser.inviteState;
                                }
                            }
                            if (blackListFromServer != null && !blackListFromServer.isEmpty()) {
                                if (blackListFromServer.contains(user.getUsername())) {
                                    user.setContact(1);
                                }
                            }
                        }
                        sortData(users);
                        if (callBack != null) {
                            callBack.onSuccess(createLiveData(users));
                        }
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if (callBack != null) {
                            callBack.onError(error, errorMsg);
                        }
                    }
                });
            } catch (HyphenateException e) {
                e.printStackTrace();
                if (callBack != null) {
                    callBack.onError(e.getErrorCode(), e.getDescription());
                }
            }
        });
    }


    public LiveData<Resource<List<CircleUser>>> getContactList(boolean fetchServer) {
        return new NetworkBoundResource<List<CircleUser>, List<CircleUser>>() {

            @Override
            protected boolean shouldFetch(List<CircleUser> data) {
                return fetchServer;
            }

            @Override
            protected LiveData<List<CircleUser>> loadFromDb() {
                return Transformations.map(getUserDao().loadUsers(), result -> {
                    if (result != null) {
                        sortData(result);
                    }
                    return result;
                });
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleUser>>> callBack) {
                fetchContactListFromServer(callBack);
            }

            @Override
            protected void saveCallResult(List<CircleUser> users) {
                getUserDao().insert(users);
                LiveEventBus.get(Constants.USERINFO_CHANGE).post(users);
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleUser>> getUserInfoById(final String username) {
        return new NetworkBoundResource<CircleUser, CircleUser>() {

            @Override
            protected boolean shouldFetch(CircleUser data) {
                return true;
            }

            @Override
            protected LiveData<CircleUser> loadFromDb() {
                CircleUser user = getUserDao().loadUserByUserId(username);
                return createLiveData(user);
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<CircleUser>> callBack) {
                String userId = username;
                if (getAppUserInfoManager().isCurrentUserFromOtherDevice(username)) {
                    userId = EMClient.getInstance().getCurrentUser();
                }
                String[] userIds = new String[]{userId};
                String finalUserId = userId;
                EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userIds, new EMValueCallBack<Map<String, EMUserInfo>>() {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> value) {

                        Log.e("TAG", "getUserInfoById success");
                        if (callBack != null) {
                            CircleUser circleUser = CircleUser.parseEMUserInfo(value.get(finalUserId));
                            CircleUser dbUser = getUserDao().loadUserByUserId(username);
                            if (dbUser != null) {
                                circleUser.setContact(dbUser.getContact());
                                circleUser.roleID = dbUser.roleID;
                                circleUser.inviteState = dbUser.inviteState;
                            } else {
                                circleUser.setContact(3);//设置成非好友
                            }
                            callBack.onSuccess(createLiveData(circleUser));
                        }
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if (callBack != null) {
                            callBack.onError(error, errorMsg);
                        }
                    }
                });
            }

            @Override
            protected void saveCallResult(CircleUser item) {
                getUserDao().insert(item);
                LiveEventBus.get(Constants.USERINFO_CHANGE).post(item);
            }
        }.asLiveData();

    }

    public LiveData<Resource<Map<String, EMUserInfo>>> fetchUsersInfoByUserIds(String[] userIds) {
        return new NetworkOnlyResource<Map<String, EMUserInfo>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Map<String, EMUserInfo>>> callBack) {
                EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userIds, new EMValueCallBack<Map<String, EMUserInfo>>() {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> value) {
                        callBack.onSuccess(createLiveData(value));
                        List<CircleUser> users = CircleUser.parseEMUserInfos(value);
                        if (users != null) {
                            for (CircleUser circleUser : users) {
                                CircleUser dbUser = getUserDao().loadUserByUserId(circleUser.getUsername());
                                if (dbUser != null) {
                                    circleUser.setContact(dbUser.getContact());
                                    circleUser.roleID = dbUser.roleID;
                                    circleUser.inviteState = dbUser.inviteState;
                                } else {
                                    circleUser.setContact(3);//设置成非好友
                                }
                            }
                        }
                        DatabaseManager.getInstance().getUserDao().insert(users);
                        LiveEventBus.get(Constants.USERINFO_CHANGE).post(users);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();
    }

    public void fetchUserInfoFromServer(final String username, ResultCallBack<CircleUser> callBack) {
        String userId = username;
        if (getAppUserInfoManager().isCurrentUserFromOtherDevice(username)) {
            userId = EMClient.getInstance().getCurrentUser();
        }
        String[] userIds = new String[]{userId};
        String finalUserId = userId;
        EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userIds, new EMValueCallBack<Map<String, EMUserInfo>>() {
            @Override
            public void onSuccess(Map<String, EMUserInfo> value) {
                CircleUser circleUser = CircleUser.parseEMUserInfo(value.get(finalUserId));
                CircleUserDao userDao = getUserDao();
                CircleUser dbUser = null;
                if (userDao != null) {
                    dbUser = userDao.loadUserByUserId(circleUser.getUsername());
                }
                if (dbUser != null) {
                    circleUser.setContact(dbUser.getContact());
                    circleUser.roleID = dbUser.roleID;
                    circleUser.inviteState = dbUser.inviteState;
                } else {
                    circleUser.setContact(3);//设置成非好友
                }
                if (userDao != null) {
                    userDao.insert(circleUser);
                }
                if (callBack != null) {
                    callBack.onSuccess(circleUser);
                }
                LiveEventBus.get(Constants.USERINFO_CHANGE).post(circleUser);
            }

            @Override
            public void onError(int error, String errorMsg) {
                if (callBack != null) {
                    callBack.onError(error, errorMsg);
                }
            }
        });
    }

    /**
     * update current user's attribute
     *
     * @param attribute
     * @param value
     * @return
     */
    public LiveData<Resource<CircleUser>> updateCurrentUserInfo(EMUserInfo.EMUserInfoType attribute, String value) {
        return new NetworkOnlyResource<CircleUser>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleUser>> callBack) {
                EMClient.getInstance().userInfoManager().updateOwnInfoByAttribute(attribute, value, new EMValueCallBack<String>() {
                    @Override
                    public void onSuccess(String response) {
                        CircleUser user = getUserDao().loadUserByUserId(AppUserInfoManager.getInstance().getCurrentUserName());
                        if (user == null) {
                            user = new CircleUser(getCurrentUser());
                        }

                        if (attribute == EMUserInfo.EMUserInfoType.AVATAR_URL) {
                            user.setAvatar(value);
                        } else if (attribute == EMUserInfo.EMUserInfoType.NICKNAME) {
                            user.setNickname(value);
                        }
                        getUserDao().insert(user);

                        callBack.onSuccess(createLiveData(user));
                        LiveEventBus.get(Constants.USERINFO_CHANGE).post(null);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleUser>> updateCurrentUserNickname(String nickname) {
        return updateCurrentUserInfo(EMUserInfo.EMUserInfoType.NICKNAME, nickname);
    }


    private void sortData(List<CircleUser> data) {
        if (data == null || data.isEmpty()) {
            return;
        }
        Collections.sort(data, new Comparator<CircleUser>() {

            @Override
            public int compare(CircleUser lhs, CircleUser rhs) {
                if (TextUtils.equals(lhs.getInitialLetter(), rhs.getInitialLetter())) {
                    return lhs.getNickname().compareTo(rhs.getNickname());
                } else {
                    if ("#".equals(lhs.getInitialLetter())) {
                        return 1;
                    } else if ("#".equals(rhs.getInitialLetter())) {
                        return -1;
                    }
                    return lhs.getInitialLetter().compareTo(rhs.getInitialLetter());
                }

            }
        });
    }
}
