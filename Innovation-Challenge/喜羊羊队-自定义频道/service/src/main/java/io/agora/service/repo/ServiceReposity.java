package io.agora.service.repo;


import static com.hyphenate.EMError.GENERAL_ERROR;

import android.content.Context;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ThreadUtils;
import com.google.gson.Gson;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatManager;
import com.hyphenate.chat.EMChatRoomManager;
import com.hyphenate.chat.EMChatThreadManager;
import com.hyphenate.chat.EMCircleManager;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMContactManager;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.chat.EMPushManager;
import com.hyphenate.cloud.EMCloudOperationCallback;
import com.hyphenate.cloud.EMHttpClient;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.ImageUtils;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

import io.agora.service.R;
import io.agora.service.bean.UploadFileResultBean;
import io.agora.service.bean.UserAccountBean;
import io.agora.service.callbacks.ResultCallBack;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleChannelDao;
import io.agora.service.db.dao.CircleServerDao;
import io.agora.service.db.dao.CircleUserDao;
import io.agora.service.global.Constants;
import io.agora.service.global.URLHelper;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.managers.PreferenceManager;
import io.agora.service.net.ErrorCode;
import io.agora.service.net.NetworkOnlyResource;
import io.agora.service.net.Resource;

public class ServiceReposity {
    private String TAG = getClass().getSimpleName();

    @DrawableRes
    public static int getRandomServerIcon(String serverId) {
        List<Integer> icons = new ArrayList();
        icons.add(R.drawable.cover01);
        icons.add(R.drawable.cover02);
        icons.add(R.drawable.cover03);
        icons.add(R.drawable.cover04);
        icons.add(R.drawable.cover05);
        icons.add(R.drawable.cover06);
        icons.add(R.drawable.cover07);
        icons.add(R.drawable.cover08);
        icons.add(R.drawable.cover09);
        int i = 0;
        if (serverId == null) {
            i = new Random().nextInt(icons.size());
        } else {
            char c = serverId.charAt(serverId.length() - 1);
            i = Integer.valueOf(c).intValue() % 9 + 1;
        }
        if (i < 1) {
            i = 1;
        } else if (i > icons.size()) {
            i = icons.size();
        }
        return icons.get(i-1);
    }

    /**
     * Data to be loaded after login
     *
     * @return
     */
    public LiveData<Resource<String>> loadAllInfoFromHX() {
        return new NetworkOnlyResource<String>() {

            @Override
            protected void createCall(ResultCallBack<LiveData<String>> callBack) {
                if (isAutoLogin()) {
                    ThreadUtils.runOnUiThread(() -> {
                        if (isLoggedIn()) {
                            loginSuccess(false, EMClient.getInstance().getCurrentUser(), callBack);
                        } else {
                            callBack.onError(ErrorCode.NOT_LOGIN);
                        }

                    });
                } else {
                    callBack.onError(ErrorCode.NOT_LOGIN);
                }

            }
        }.asLiveData();
    }

    public boolean isLoggedIn() {
        return EMClient.getInstance().isSdkInited() && EMClient.getInstance().isLoggedInBefore();
    }

    public boolean isAutoLogin() {
        return EMClient.getInstance().isSdkInited() && EMClient.getInstance().getOptions().getAutoLogin();
    }

    /**
     * 注册
     *
     * @param userName
     * @param pwd
     * @return
     */
    public LiveData<Resource<UserAccountBean>> registerToHx(String userName, String pwd) {
        return new NetworkOnlyResource<UserAccountBean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<UserAccountBean>> callBack) {
                ThreadUtils.getCachedPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            EMClient.getInstance().createAccount(userName, pwd);
                            callBack.onSuccess(createLiveData(new UserAccountBean(userName, pwd)));
                        } catch (HyphenateException e) {
                            callBack.onError(e.getErrorCode(), e.getMessage());
                        }
                    }
                });
            }
        }.asLiveData();
    }

    /**
     * 登录到服务器，可选择密码登录或者token登录
     * 登录之前先初始化数据库，如果登录失败，再关闭数据库;如果登录成功，则再次检查是否初始化数据库
     *
     * @param userName
     * @param pwd
     * @return
     */
    public LiveData<Resource<String>> loginToServer(String userName, String pwd) {
        return new NetworkOnlyResource<String>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                EMClient.getInstance().login(userName, pwd, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        loginSuccess(false, userName, callBack);
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                        closeDB();
                    }
                });
            }
        }.asLiveData();
    }

    private void loginSuccess(boolean autologin, String userName, ResultCallBack<LiveData<String>> callBack) {
        // 初始化数据库
        PreferenceManager.getInstance().setAutoLogin(true);
        initDb();
        if (!autologin) {
            //encryptData(pwd);
            // manually load all local groups and conversation
            // 从本地数据库加载所有的对话及群组
            EMClient.getInstance().chatManager().loadAllConversations();
            EMClient.getInstance().groupManager().loadAllGroups();
            //从服务器拉取加入的群，防止进入会话页面只显示id
            getAllJoinGroup();
            // get contacts from server
            getContactsFromServer();
        }
        //持久化缓存
        AppUserInfoManager.getInstance().saveCurrentUserName(userName);
        //更新用户信息
        AppUserInfoManager.getInstance().updateUserInfo(userName);
        AppUserInfoManager.getInstance().loadUsers();
        callBack.onSuccess(new MutableLiveData(userName));
    }

    private void getContactsFromServer() {
        DatabaseManager.getInstance().getUserDao().clearUsers();
        new EMContactManagerRepository().fetchContactListFromServer(null);
    }


    private void getAllJoinGroup() {
        getAllGroups(new ResultCallBack<List<EMGroup>>() {
            @Override
            public void onSuccess(List<EMGroup> value) {
                //加载完群组信息后，刷新会话列表页面，保证展示群组名称
                EMLog.i(TAG, "login isGroupsSyncedWithServer success");
                LiveEventBus.get(Constants.GROUP_CHANGE).post(value);
            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    /**
     * 获取所有群组列表
     *
     * @param callBack
     */
    public void getAllGroups(ResultCallBack<List<EMGroup>> callBack) {
        if (!isLoggedIn()) {
            callBack.onError(ErrorCode.NOT_LOGIN);
            return;
        }
        EMClient.getInstance().groupManager().asyncGetJoinedGroupsFromServer(new EMValueCallBack<List<EMGroup>>() {
            @Override
            public void onSuccess(List<EMGroup> value) {
                if (callBack != null) {
                    callBack.onSuccess(value);
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

    private void initDb() {
        DatabaseManager.getInstance().initDB(EMClient.getInstance().getCurrentUser());
    }

    /**
     * 退出登录
     *
     * @param unbindDeviceToken
     * @return
     */
    public LiveData<Resource<Boolean>> logout(boolean unbindDeviceToken) {
        return new NetworkOnlyResource<Boolean>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                EMClient.getInstance().logout(unbindDeviceToken, new EMCallBack() {

                    @Override
                    public void onSuccess() {
                        AppUserInfoManager.getInstance().clear();
                        PreferenceManager.getInstance().setAutoLogin(false);
                        closeDB();
                        //reset();
                        if (callBack != null) {
                            callBack.onSuccess(createLiveData(true));
                        }

                    }

                    @Override
                    public void onProgress(int progress, String status) {
                    }

                    @Override
                    public void onError(int code, String error) {
                        //reset();
                        if (callBack != null) {
                            callBack.onError(code, error);
                        }
                    }
                });
            }
        }.asLiveData();
    }

    private void closeDB() {
        DatabaseManager.getInstance().closeDb();
    }

    public LiveData<Resource<List<EMPresence>>> fetchPresenceStatus(List<String> userIds) {
        return new NetworkOnlyResource<List<EMPresence>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<EMPresence>>> callBack) {
                EMClient.getInstance().presenceManager().fetchPresenceStatus(userIds, new EMValueCallBack<List<EMPresence>>() {
                    @Override
                    public void onSuccess(List<EMPresence> presences) {
                        for (EMPresence presence : presences) {
                            AppUserInfoManager.getInstance().getPresences().put(presence.getPublisher(), presence);
                        }
                        callBack.onSuccess(createLiveData(presences));
                    }

                    @Override
                    public void onError(int i, String s) {
                        callBack.onError(i);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<List<EMPresence>>> subscribePresences(List<String> ids, long expiry) {
        return new NetworkOnlyResource<List<EMPresence>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<EMPresence>>> callBack) {
                EMClient.getInstance().presenceManager().subscribePresences(ids, expiry, new EMValueCallBack<List<EMPresence>>() {
                    @Override
                    public void onSuccess(List<EMPresence> presences) {
                        for (EMPresence presence : presences) {
                            AppUserInfoManager.getInstance().getPresences().put(presence.getPublisher(), presence);
                        }
                        callBack.onSuccess(createLiveData(presences));
                    }

                    @Override
                    public void onError(int i, String s) {
                        callBack.onError(i);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> publishPresence(String ext) {
        return new NetworkOnlyResource<Boolean>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                EMClient.getInstance().presenceManager().publishPresence(ext, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(true));
                    }

                    @Override
                    public void onError(int i, String s) {
                        callBack.onError(i);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<String>> uploadFile(Context context, String localUri) {
        return new NetworkOnlyResource<String>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                ThreadUtils.getCachedPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        String scaledImagePath = ImageUtils.getScaledImageByUri(context, localUri);
                        EMHttpClient.getInstance().uploadFile(scaledImagePath, URLHelper.UPLOAD_IMAGE_URL, new HashMap<>(), new EMCloudOperationCallback() {
                            @Override
                            public void onSuccess(String result) {
                                //targetUrl=remoteurl+uuid
                                UploadFileResultBean uploadFileResult = new Gson().fromJson(result, UploadFileResultBean.class);
                                List<UploadFileResultBean.Entities> entitiesList = uploadFileResult.getEntities();
                                if (!CollectionUtils.isEmpty(entitiesList)) {
                                    String uuid = entitiesList.get(0).getUuid();
                                    String imageUrl = uploadFileResult.getUri() + "/" + uuid;
                                    callBack.onSuccess(createLiveData(imageUrl));
                                } else {
                                    callBack.onError(GENERAL_ERROR, "uploadFile uuid  is null ");
                                }
                            }

                            @Override
                            public void onError(String msg) {
                                callBack.onError(GENERAL_ERROR, msg);
                            }

                            @Override
                            public void onProgress(int progress) {
                            }
                        });
                    }
                });
            }
        }.asLiveData();
    }

    public <T> LiveData<T> createLiveData(T item) {
        return new MutableLiveData<>(item);
    }

    protected String getCurrentUser() {
        return EMClient.getInstance().getCurrentUser();
    }

    protected CircleUserDao getUserDao() {
        return DatabaseManager.getInstance().getUserDao();
    }

    protected CircleServerDao getServerDao() {
        return DatabaseManager.getInstance().getServerDao();
    }

    protected CircleChannelDao getChannelDao() {
        return DatabaseManager.getInstance().getChannelDao();
    }

    protected EMContactManager getContactManager() {
        return EMClient.getInstance().contactManager();
    }

    protected EMChatManager getChatManager() {
        return EMClient.getInstance().chatManager();
    }

    protected AppUserInfoManager getAppUserInfoManager() {
        return AppUserInfoManager.getInstance();
    }

    protected DatabaseManager getDBManager() {
        return DatabaseManager.getInstance();
    }

    protected EMCircleManager getCircleManager() {
        return EMClient.getInstance().chatCircleManager();
    }

    protected EMChatRoomManager getChatRoomManager() {
        return EMClient.getInstance().chatroomManager();

    }

    protected EMPushManager getPushManager() {

        return EMClient.getInstance().pushManager();
    }

    protected EMChatThreadManager getThreadManager() {
        return EMClient.getInstance().chatThreadManager();
    }


}
