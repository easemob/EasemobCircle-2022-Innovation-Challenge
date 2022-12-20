package io.agora.service.repo;


import static com.hyphenate.EMError.GENERAL_ERROR;
import static com.hyphenate.chat.EMCircleUserRole.MODERATOR;
import static com.hyphenate.chat.EMCircleUserRole.OWNER;
import static com.hyphenate.chat.EMCircleUserRole.USER;

import android.text.TextUtils;
import android.util.Pair;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ThreadUtils;
import com.google.gson.Gson;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMCircleServer;
import com.hyphenate.chat.EMCircleServerAttribute;
import com.hyphenate.chat.EMCircleTag;
import com.hyphenate.chat.EMCircleUser;
import com.hyphenate.chat.EMCircleUserRole;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.cloud.EMHttpClient;
import com.hyphenate.exceptions.HyphenateException;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.RecommendServiceBean;
import io.agora.service.callbacks.ResultCallBack;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleServerDao;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.global.URLHelper;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.net.NetworkBoundResource;
import io.agora.service.net.NetworkOnlyResource;
import io.agora.service.net.Resource;

public class CircleServerReposity extends ServiceReposity {

    public LiveData<Resource<List<CircleServer>>> getServerListByKey(String key) {
        return new NetworkOnlyResource<List<CircleServer>>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleServer>>> callBack) {
                EMClient.getInstance().chatCircleManager().fetchServersWithKeyword(key, new EMValueCallBack<List<EMCircleServer>>() {
                    @Override
                    public void onSuccess(List<EMCircleServer> value) {
                        callBack.onSuccess(new MutableLiveData(CircleServer.converToCirlceServerList(value)));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<List<CircleServer>>> getServerJoinedList() {
        return new NetworkBoundResource<List<CircleServer>, List<CircleServer>>() {
            @Override
            protected boolean shouldFetch(List<CircleServer> data) {
                return true;
            }

            @Override
            protected LiveData<List<CircleServer>> loadFromDb() {
                LiveData<List<CircleServer>> joinedServersLiveData = DatabaseManager.getInstance().getServerDao().getJoinedServersLiveData();
                return joinedServersLiveData;
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleServer>>> callBack) {
                int limit = 20;
                String cursor = null;
                ArrayList<CircleServer> servers = new ArrayList<>();
                doGetServerJoinedList(limit, cursor, servers, callBack);
            }

            @Override
            protected void saveCallResult(List<CircleServer> item) {
                if (item != null && !item.isEmpty()) {
                    CircleServerDao serverDao = DatabaseManager.getInstance().getServerDao();
                    serverDao.deleteAll();
                    for (int i = 0; i < item.size(); i++) {
                        item.get(i).isJoined = true;
                    }
                    serverDao.insert(item);
                }
            }
        }.asLiveData();
    }

    private void doGetServerJoinedList(int limit, String cursor, ArrayList<CircleServer> servers, ResultCallBack<LiveData<List<CircleServer>>> callBack) {

        EMClient.getInstance().chatCircleManager().fetchJoinedServers(limit, cursor, new EMValueCallBack<EMCursorResult<EMCircleServer>>() {
            @Override
            public void onSuccess(EMCursorResult<EMCircleServer> value) {
                List<CircleServer> circleServers = CircleServer.converToCirlceServerList(value.getData());
                if (circleServers != null) {
                    servers.addAll(circleServers);
                }
                if (!TextUtils.isEmpty(value.getCursor())) {
                    doGetServerJoinedList(limit, value.getCursor(), servers, callBack);
                } else {
                    callBack.onSuccess(new MutableLiveData<>(servers));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }

    public LiveData<Resource<List<CircleServer>>> getRecommendServerList() {
        return new NetworkOnlyResource<List<CircleServer>>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleServer>>> callBack) {
                ThreadUtils.getCachedPool().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Pair<Integer, String> response = EMHttpClient.getInstance().sendRequestWithToken(URLHelper.GET_RECOMMEND_SERVER_URL, null, EMHttpClient.GET);
                            if (response != null) {
                                int resCode = response.first;
                                String responseInfo = response.second;
                                RecommendServiceBean recommendServiceBean = new Gson().fromJson(responseInfo, RecommendServiceBean.class);
                                if (resCode == 200 && recommendServiceBean != null && !CollectionUtils.isEmpty(recommendServiceBean.getServers())) {
                                    List<CircleServer> servers = new ArrayList<>();
                                    for (RecommendServiceBean.Servers server : recommendServiceBean.getServers()) {
                                        CircleServer circleServer = new CircleServer(
                                                server.getServer_id(),
                                                server.getDefault_channel_id(),
                                                server.getName(),
                                                server.getIcon_url(),
                                                server.getDescription(),
                                                server.getCustom(),
                                                server.getOwner(),
                                                server.getTags(),
                                                null,
                                                null,
                                                true,
                                                false);
                                        servers.add(circleServer);
                                    }
                                    callBack.onSuccess(createLiveData(servers));
                                } else {
                                    callBack.onError(resCode, responseInfo);
                                }
                            } else {
                                callBack.onError(GENERAL_ERROR, "response is null ");
                            }
                        } catch (HyphenateException e) {
                            e.printStackTrace();
                            callBack.onError(GENERAL_ERROR, e.getMessage());
                        }
                    }
                });
            }
        }.asLiveData();
    }


    public LiveData<Resource<CircleServer>> createServer(String icon, String name, String desc) {
        return new NetworkOnlyResource<CircleServer>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleServer>> callBack) {

                EMCircleServerAttribute attribute = new EMCircleServerAttribute();
                attribute.setName(name);
                attribute.setDesc(desc);
                attribute.setIcon(icon);
                getCircleManager().createServer(attribute, new EMValueCallBack<EMCircleServer>() {
                    @Override
                    public void onSuccess(EMCircleServer value) {
                        CircleServer circleServer = new CircleServer(value);
                        callBack.onSuccess(createLiveData(circleServer));
                        DatabaseManager.getInstance().getServerDao().insert(circleServer);
                        LiveEventBus.get(Constants.SERVER_CHANGED).post(circleServer);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();
    }


    public LiveData<Resource<List<CircleUser>>> getServerMembers(String serverID) {
        return new NetworkOnlyResource<List<CircleUser>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleUser>>> callBack) {
                int limit = 20;
                List<CircleUser> users = new ArrayList<>();
                doFetchServerMembers(serverID, limit, users, null, callBack);
            }
        }.asLiveData();
    }

    private void doFetchServerMembers(String serverID, int limit, List<CircleUser> users, String cursor, ResultCallBack<LiveData<List<CircleUser>>> callBack) {
        getCircleManager().fetchServerMembers(serverID, limit, cursor, new EMValueCallBack<EMCursorResult<EMCircleUser>>() {
            @Override
            public void onSuccess(EMCursorResult<EMCircleUser> value) {

                if (!CollectionUtils.isEmpty(value.getData())) {
                    for (EMCircleUser emCircleUser : value.getData()) {
                        CircleUser circleUser = getUserDao().loadUserByUserId(emCircleUser.getUserId());
                        if (circleUser == null) {
                            circleUser = new CircleUser(emCircleUser.getUserId());
                            circleUser.setContact(3);//没有从数据中找到说明不是好友
                        }
                        circleUser.roleID = emCircleUser.getRole().getRoleId();
                        getUserDao().insert(circleUser);
                        users.add(circleUser);
                    }
                }
                if (!TextUtils.isEmpty(value.getCursor())) {
                    doFetchServerMembers(serverID, limit, users, value.getCursor(), callBack);
                } else {
                    callBack.onSuccess(createLiveData(users));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }

    public LiveData<Resource<Boolean>> deleteServer(String serverId) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getCircleManager().destroyServer(serverId, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        AppUserInfoManager.getInstance().getUserJoinedSevers().remove(serverId);
                        getServerDao().deleteByServerId(serverId);
                        callBack.onSuccess(createLiveData(true));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> leaveServer(String serverId) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getCircleManager().leaveServer(serverId, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        AppUserInfoManager.getInstance().getUserJoinedSevers().remove(serverId);
                        getServerDao().deleteByServerId(serverId);
                        callBack.onSuccess(createLiveData(true));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleServer>> updateServer(String serverID, String icon, String name, String desc) {
        return new NetworkOnlyResource<CircleServer>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleServer>> callBack) {
                EMCircleServerAttribute attribute = new EMCircleServerAttribute();
                attribute.setIcon(icon);
                attribute.setDesc(desc);
                attribute.setName(name);
                getCircleManager().updateServer(serverID, attribute, new EMValueCallBack<EMCircleServer>() {

                    @Override
                    public void onSuccess(EMCircleServer value) {
                        CircleServer circleServer = getServerDao().getServerById(value.getServerId());
                        CircleServer server = new CircleServer(value);
                        if (circleServer != null) {
                            server.isJoined = circleServer.isJoined;
                            server.isRecommand = circleServer.isRecommand;
                            server.channels = circleServer.channels;
                            server.modetators = circleServer.modetators;
                        }
                        callBack.onSuccess(createLiveData(server));
                        //发出通知
                        LiveEventBus.get(Constants.SERVER_UPDATED).post(server);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }

            @Override
            protected void saveCallResult(CircleServer item) {
                super.saveCallResult(item);
                getServerDao().insert(item);
            }
        }.asLiveData();
    }

    public LiveData<Resource<List<CircleServer.Tag>>> addTagToServer(CircleServer circleServer, String tag) {
        return new NetworkOnlyResource<List<CircleServer.Tag>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleServer.Tag>>> callBack) {
                List tags = new ArrayList();
                tags.add(tag);
                getCircleManager().addTagsToServer(circleServer.serverId, tags, new EMValueCallBack<List<EMCircleTag>>() {

                    @Override
                    public void onSuccess(List<EMCircleTag> tags) {
                        List<CircleServer.Tag> myTags = new ArrayList();
                        for (EMCircleTag circleTag : tags) {
                            CircleServer.Tag myTag = new CircleServer.Tag(circleTag);
                            myTags.add(myTag);
                        }
                        //发出广播tag更新
                        circleServer.tags.addAll(myTags);
                        callBack.onSuccess(createLiveData(circleServer.tags));
                        LiveEventBus.get(Constants.SERVER_UPDATED).post(circleServer);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }

            @Override
            protected void saveCallResult(List<CircleServer.Tag> item) {
                super.saveCallResult(item);
                CircleServer server = getServerDao().getServerById(circleServer.serverId);
                server.tags.addAll(item);
                getServerDao().updateCircleServer(server);
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleServer>> removeTagFromServer(CircleServer circleServer, CircleServer.Tag tag) {
        return new NetworkOnlyResource<CircleServer>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleServer>> callBack) {
                List tags = new ArrayList();
                tags.add(tag.id);
                getCircleManager().removeTagsFromServer(circleServer.serverId, tags, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        circleServer.tags.remove(tag);
                        callBack.onSuccess(createLiveData(circleServer));
                        //发出广播tag更新
                        LiveEventBus.get(Constants.SERVER_UPDATED).post(circleServer);
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }

            @Override
            protected void saveCallResult(CircleServer circleServer) {
                CircleServer server = getServerDao().getServerById(circleServer.serverId);
                server.tags = circleServer.tags;
                getServerDao().updateCircleServer(server);
            }
        }.asLiveData();
    }

    public LiveData<Resource<EMCircleUserRole>> fetchSelfServerRole(String serverID) {
        return new NetworkBoundResource<EMCircleUserRole, EMCircleUserRole>() {
            @Override
            protected boolean shouldFetch(EMCircleUserRole data) {
                return true;
            }

            @Override
            protected LiveData<EMCircleUserRole> loadFromDb() {
                CircleUser user = getUserDao().loadUserByUserId(AppUserInfoManager.getInstance().getCurrentUserName());
                EMCircleUserRole role = USER;
                if (user.roleID == OWNER.getRoleId()) {
                    role = OWNER;
                } else if (user.roleID == MODERATOR.getRoleId()) {
                    role = MODERATOR;
                } else if (user.roleID == USER.getRoleId()) {
                    role = USER;
                }
                return createLiveData(role);
            }

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<EMCircleUserRole>> callBack) {
                getCircleManager().fetchSelfServerRole(serverID, new EMValueCallBack<EMCircleUserRole>() {

                    @Override
                    public void onSuccess(EMCircleUserRole role) {
                        AppUserInfoManager.getInstance().saveSelfServerRole(serverID, role.getRoleId());
                        callBack.onSuccess(createLiveData(role));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }

            @Override
            protected void saveCallResult(EMCircleUserRole role) {
                String currentUserName = AppUserInfoManager.getInstance().getCurrentUserName();
                CircleUser user = getUserDao().loadUserByUserId(currentUserName);
                user.roleID = role.getRoleId();
                getUserDao().insert(user);

//                CircleServer circleServer = getServerDao().getServerById(serverID);
//                if(circleServer!=null) {
//                    if(role== MODERATOR) {
//                        List<String> modetators = circleServer.modetators;
//                        if(!modetators.contains(currentUserName)) {
//                            modetators.add(currentUserName);
//                        }
//                        getServerDao().updateCircleServer(circleServer);
//                    }
//                }
            }
        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> addModeratorToServer(String serverId, String username) {
        return new NetworkOnlyResource<Boolean>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getCircleManager().addModeratorToServer(serverId, username, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(true));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }

        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> removeModeratorFromServer(String serverId, String
            username) {
        return new NetworkOnlyResource<Boolean>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getCircleManager().removeModeratorFromServer(serverId, username, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(true));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }

        }.asLiveData();
    }

    public LiveData<Resource<CircleServer>> joinServer(String serverId) {
        return new NetworkOnlyResource<CircleServer>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleServer>> callBack) {
                getCircleManager().joinServer(serverId, new EMValueCallBack<EMCircleServer>() {
                            @Override
                            public void onSuccess(EMCircleServer value) {
                                CircleServer server = new CircleServer(value);
                                server.isJoined = true;
                                getServerDao().insert(server);
                                AppUserInfoManager.getInstance().getUserJoinedSevers().put(server.serverId, server);
                                callBack.onSuccess(createLiveData(server));
                            }

                            @Override
                            public void onError(int code, String error) {
                                callBack.onError(code, error);
                            }
                        }
                );
            }

        }.asLiveData();
    }

    public LiveData<Resource<String>> inviteToServer(String serverId, String invitee, String
            welcome) {
        return new NetworkOnlyResource<String>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                getCircleManager().inviteUserToServer(serverId, invitee, welcome, new EMCallBack() {
                            @Override
                            public void onSuccess() {
                                callBack.onSuccess(createLiveData(invitee));
                            }

                            @Override
                            public void onError(int code, String error) {
                                callBack.onError(code, error);
                            }
                        }
                );
            }

        }.asLiveData();
    }

    public LiveData<Resource<String>> removeUserFromServer(String serverId, String userId) {
        return new NetworkOnlyResource<String>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                getCircleManager().removeUserFromServer(serverId, userId, new EMCallBack() {
                            @Override
                            public void onSuccess() {
                                callBack.onSuccess(createLiveData(userId));
                            }

                            @Override
                            public void onError(int code, String error) {
                                callBack.onError(code, error);
                            }
                        }
                );
            }

        }.asLiveData();
    }

    public LiveData<Resource<List<CircleServer.Tag>>> fetchServerTags(String serverId) {
        return new NetworkBoundResource<List<CircleServer.Tag>, List<CircleServer.Tag>>() {

            @Override
            protected boolean shouldFetch(List<CircleServer.Tag> data) {
                return true;
            }

            @Override
            protected LiveData<List<CircleServer.Tag>> loadFromDb() {
                CircleServer circleServer = getServerDao().getServerById(serverId);
                if (circleServer != null) {
                    return createLiveData(circleServer.tags);
                }
                return null;
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleServer.Tag>>> callBack) {
                getCircleManager().fetchServerTags(serverId, new EMValueCallBack<List<EMCircleTag>>() {
                    @Override
                    public void onSuccess(List<EMCircleTag> value) {
                        List<CircleServer.Tag> tags = CircleServer.Tag.EMTagsConvertToTags(value);
                        for (CircleServer.Tag tag : tags) {
                            tag.serverId = serverId;
                        }
                        callBack.onSuccess(createLiveData(tags));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }

            @Override
            protected void saveCallResult(List<CircleServer.Tag> tags) {
                CircleServer circleServer = getServerDao().getServerById(serverId);
                if (circleServer != null) {
                    circleServer.tags = tags;
                    getServerDao().updateCircleServer(circleServer);
                }
            }
        }.asLiveData();
    }

    public LiveData<Resource<CustomInfo>> checkSelfIsInServer(CustomInfo customInfo) {
        return new NetworkOnlyResource<CustomInfo>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CustomInfo>> callBack) {
                getCircleManager().checkSelfIsInServer(customInfo.getServerId(), new EMValueCallBack<Boolean>() {
                    @Override
                    public void onSuccess(Boolean value) {
                        customInfo.setIn(value);
                        callBack.onSuccess(createLiveData(customInfo));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();

    }
}
