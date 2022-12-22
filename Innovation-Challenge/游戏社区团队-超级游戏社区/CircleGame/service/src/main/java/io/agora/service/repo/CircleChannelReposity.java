package io.agora.service.repo;


import static io.agora.service.db.entity.CircleChannel.converToCirlceChannelList;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.blankj.utilcode.util.CollectionUtils;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMCircleChannel;
import com.hyphenate.chat.EMCircleChannelAttribute;
import com.hyphenate.chat.EMCircleChannelStyle;
import com.hyphenate.chat.EMCircleUser;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.ResultCallBack;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleChannelDao;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.net.NetworkBoundResource;
import io.agora.service.net.NetworkOnlyResource;
import io.agora.service.net.Resource;

public class CircleChannelReposity extends ServiceReposity {


    public LiveData<Resource<List<CircleChannel>>> getPublicChannelList(String serverID) {
        return new NetworkBoundResource<List<CircleChannel>, List<CircleChannel>>() {
            @Override
            protected boolean shouldFetch(List<CircleChannel> data) {
                return true;
            }

            @Override
            protected LiveData<List<CircleChannel>> loadFromDb() {
                LiveData<List<CircleChannel>> channelsLiveData = DatabaseManager.getInstance().getChannelDao().getPublicChannelsByChannelServerID(serverID);
                return channelsLiveData;
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleChannel>>> callBack) {
                int limit = 10;
                String cursor = null;
                ArrayList<CircleChannel> channels = new ArrayList<>();
                doGetPublicChannelList(serverID, limit, cursor, channels, callBack);
            }

            @Override
            protected void saveCallResult(List<CircleChannel> item) {
                if (item != null && !item.isEmpty()) {
                    CircleChannelDao channelDao = getChannelDao();
                    channelDao.deleteAllPublicChannelsByServerID(serverID);
                    channelDao.insert(item);
                }
            }
        }.asLiveData();
    }

    private void doGetPublicChannelList(String serverID, int limit, String cursor, ArrayList<CircleChannel> channels, ResultCallBack<LiveData<List<CircleChannel>>> callBack) {
        getCircleManager().fetchPublicChannelsInServer(serverID, limit, cursor, new EMValueCallBack<EMCursorResult<EMCircleChannel>>() {
            @Override
            public void onSuccess(EMCursorResult<EMCircleChannel> value) {
                List<CircleChannel> circleChannels = converToCirlceChannelList(value.getData());
                if (!CollectionUtils.isEmpty(circleChannels)) {
                    channels.addAll(circleChannels);
                }
                if (value != null && !TextUtils.isEmpty(value.getCursor())) {
                    doGetPublicChannelList(serverID, limit, value.getCursor(), channels, callBack);
                } else {
                    callBack.onSuccess(new MutableLiveData<>(channels));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }

    public LiveData<Resource<List<CircleChannel>>> getPrivateChannelList(String serverID) {
        return new NetworkBoundResource<List<CircleChannel>, List<CircleChannel>>() {
            @Override
            protected boolean shouldFetch(List<CircleChannel> data) {
                return true;
            }

            @Override
            protected LiveData<List<CircleChannel>> loadFromDb() {
                LiveData<List<CircleChannel>> channelsLiveData = DatabaseManager.getInstance().getChannelDao().getPrivateChannelsByChannelServerID(serverID);
                return channelsLiveData;
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleChannel>>> callBack) {
                int limit = 10;
                String cursor = null;
                ArrayList<CircleChannel> channels = new ArrayList<>();
                doGetPrivateChannelList(serverID, limit, cursor, channels, callBack);
            }

            @Override
            protected void saveCallResult(List<CircleChannel> item) {
                if (item != null && !item.isEmpty()) {
                    CircleChannelDao channelDao = DatabaseManager.getInstance().getChannelDao();
                    channelDao.deleteAllPrivateChannelsByServerID(serverID);
                    channelDao.insert(item);
                }
            }
        }.asLiveData();
    }

    private void doGetPrivateChannelList(String serverID, int limit, String cursor, ArrayList<CircleChannel> channels, ResultCallBack<LiveData<List<CircleChannel>>> callBack) {
        getCircleManager().fetchVisiblePrivateChannelsInServer(serverID, limit, cursor, new EMValueCallBack<EMCursorResult<EMCircleChannel>>() {
            @Override
            public void onSuccess(EMCursorResult<EMCircleChannel> value) {
                List<CircleChannel> circleChannels = converToCirlceChannelList(value.getData());
                if (!CollectionUtils.isEmpty(circleChannels)) {
                    channels.addAll(circleChannels);
                }
                if (!TextUtils.isEmpty(value.getCursor())) {
                    doGetPublicChannelList(serverID, limit, value.getCursor(), channels, callBack);
                } else {
                    callBack.onSuccess(new MutableLiveData<>(channels));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }

    public LiveData<Resource<List<CircleUser>>> getChannelMembers(String serverId, String channelId) {
        return new NetworkBoundResource<List<CircleUser>, List<CircleUser>>() {
            @Override
            protected boolean shouldFetch(List<CircleUser> data) {
                return true;
            }

            @Override
            protected LiveData<List<CircleUser>> loadFromDb() {
                CircleChannelDao channelDao = getChannelDao();
                if (channelDao != null) {
                    CircleChannel channel = channelDao.getChannelByChannelID(channelId);
                    return createLiveData(channel.channelUsers);
                }
                return null;
            }

            @Override
            protected void createCall(ResultCallBack<LiveData<List<CircleUser>>> callBack) {
                int limit = 20;
                List<CircleUser> users = new ArrayList<>();
                doFetchChannelMembers(serverId, channelId, limit, users, null, callBack);

            }

            @Override
            protected void saveCallResult(List<CircleUser> circleUsers) {
                CircleChannelDao channelDao = getChannelDao();
                if (channelDao != null) {
                    CircleChannel channel = channelDao.getChannelByChannelID(channelId);
                    channel.channelUsers = circleUsers;
                    channelDao.updateChannel(channel);
                }
            }
        }.asLiveData();
    }

    private void doFetchChannelMembers(String serverID, String channelID, int limit, List<CircleUser> users, String cursor, ResultCallBack<LiveData<List<CircleUser>>> callBack) {
        getCircleManager().fetchChannelMembers(serverID, channelID, limit, cursor, new EMValueCallBack<EMCursorResult<EMCircleUser>>() {
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
                    doFetchChannelMembers(serverID, channelID, limit, users, value.getCursor(), callBack);
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

    public LiveData<Resource<CircleChannel>> deleteChannel(CircleChannel channel) {
        return new NetworkOnlyResource<CircleChannel>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleChannel>> callBack) {
                getCircleManager().destroyChannel(channel.serverId, channel.channelId, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        //数据库中也要移除
                        DatabaseManager.getInstance().getChannelDao().deleteByChannelId(channel.channelId);
                        callBack.onSuccess(createLiveData(channel));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleChannel>> leaveChannel(CircleChannel channel) {
        return new NetworkOnlyResource<CircleChannel>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleChannel>> callBack) {
                getCircleManager().leaveChannel(channel.serverId, channel.channelId, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        //发出通知
                        LiveEventBus.get(Constants.CHANNEL_LEAVE).post(channel);
                        callBack.onSuccess(createLiveData(channel));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<CircleChannel>> createChannel(String serverId, EMCircleChannelAttribute attribute, EMCircleChannelStyle stype) {
        return new NetworkOnlyResource<CircleChannel>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleChannel>> callBack) {
                getCircleManager().createChannel(serverId, attribute, stype, new EMValueCallBack<EMCircleChannel>() {

                    @Override
                    public void onSuccess(EMCircleChannel value) {
                        callBack.onSuccess(createLiveData(new CircleChannel(value)));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }

            @Override
            protected void saveCallResult(CircleChannel item) {
                super.saveCallResult(item);
                getChannelDao().insert(item);
            }
        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> muteUserInChannel(String serverId, String channelId, long muteDuration, String username, boolean mute) {
        if (mute) {
            return new NetworkOnlyResource<Boolean>() {
                @Override
                protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                    getCircleManager().muteUserInChannel(serverId, channelId, username, muteDuration, new EMCallBack() {
                        @Override
                        public void onSuccess() {
                            CircleUser circleUser = getUserDao().loadUserByUserId(username);
                            if (circleUser != null) {
                                circleUser.isMuted = true;
                            }
                            getUserDao().insert(circleUser);
                            callBack.onSuccess(createLiveData(mute));
                        }

                        @Override
                        public void onError(int code, String error) {
                            callBack.onError(code, error);
                        }
                    });
                }
            }.asLiveData();
        } else {
            return new NetworkOnlyResource<Boolean>() {

                @Override
                protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                    getCircleManager().unmuteUserInChannel(serverId, channelId, username, new EMCallBack() {
                        @Override
                        public void onSuccess() {
                            CircleUser circleUser = getUserDao().loadUserByUserId(username);
                            if (circleUser != null) {
                                circleUser.isMuted = false;
                            }
                            getUserDao().insert(circleUser);
                            callBack.onSuccess(createLiveData(mute));
                        }

                        @Override
                        public void onError(int code, String error) {
                            callBack.onError(code, error);
                        }
                    });
                }
            }.asLiveData();
        }
    }

    public LiveData<Resource<String>> removeUserFromChannel(String serverId, String channelId, String username) {
        return new NetworkOnlyResource<String>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                getCircleManager().removeUserFromChannel(serverId, channelId, username, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(username));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<List<EMChatThread>>> getChannelThreads(String channelId) {
        return new NetworkOnlyResource<List<EMChatThread>>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<EMChatThread>>> callBack) {
                int limit = 20;
                List<EMChatThread> threads = new ArrayList<>();
                doFetchChannelThreads(channelId, limit, threads, null, callBack);
            }
        }.asLiveData();
    }

    private void doFetchChannelThreads(String channelID, int limit, List<EMChatThread> threads, String cursor, ResultCallBack<LiveData<List<EMChatThread>>> callBack) {
        getThreadManager().getChatThreadsFromServer(channelID, limit, cursor, new EMValueCallBack<EMCursorResult<EMChatThread>>() {
            @Override
            public void onSuccess(EMCursorResult<EMChatThread> value) {

                if (!CollectionUtils.isEmpty(value.getData())) {
                    List<EMChatThread> chatThreads = value.getData();
                    if (!CollectionUtils.isEmpty(chatThreads)) {
                        threads.addAll(chatThreads);
                    }
                }
                callBack.onSuccess(createLiveData(threads));
//                if (!TextUtils.isEmpty(value.getCursor())) {
//                    doFetchChannelThreads( channelID, limit, threads, value.getCursor(), callBack);
//                } else {
//                    callBack.onSuccess(createLiveData(threads));
//                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }


    public LiveData<Resource<CircleChannel>> updateChannel(CircleChannel channel, EMCircleChannelAttribute attribute) {
        return new NetworkOnlyResource<CircleChannel>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CircleChannel>> callBack) {
                getCircleManager().updateChannel(channel.serverId, channel.channelId, attribute, new EMValueCallBack<EMCircleChannel>() {

                    @Override
                    public void onSuccess(EMCircleChannel value) {
                        CircleChannel circleChannel = new CircleChannel(value);
                        LiveEventBus.get(Constants.CHANNEL_CHANGED).post(circleChannel);
                        callBack.onSuccess(createLiveData(circleChannel));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }

            @Override
            protected void saveCallResult(CircleChannel item) {
                super.saveCallResult(item);
                getChannelDao().insert(item);
            }
        }.asLiveData();
    }

    public LiveData<Resource<List<String>>> getThreadMembers(String threadId) {
        return new NetworkOnlyResource<List<String>>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<String>>> callBack) {
                int limit = 20;
                List<String> members = new ArrayList<>();
                doFetchThreadMemebers(threadId, limit, members, null, callBack);
            }
        }.asLiveData();
    }

    private void doFetchThreadMemebers(String threadId, int limit, List<String> members, String cursor, ResultCallBack<LiveData<List<String>>> callBack) {
        getThreadManager().getChatThreadMembers(threadId, limit, cursor, new EMValueCallBack<EMCursorResult<String>>() {
            @Override
            public void onSuccess(EMCursorResult<String> value) {

                if (!CollectionUtils.isEmpty(value.getData())) {
                    List<String> chatThreads = value.getData();
                    if (!CollectionUtils.isEmpty(chatThreads)) {
                        members.addAll(chatThreads);
                    }
                }
                callBack.onSuccess(createLiveData(members));
//                if (!TextUtils.isEmpty(value.getCursor())) {
//                    doFetchChannelThreads( channelID, limit, threads, value.getCursor(), callBack);
//                } else {
//                    callBack.onSuccess(createLiveData(threads));
//                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                callBack.onError(error, errorMsg);
            }
        });
    }

    public LiveData<Resource<Boolean>> deleteThread(ThreadData threadData) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getThreadManager().destroyChatThread(threadData.getThreadId(), new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        //发出通知
                        LiveEventBus.get(Constants.THREAD_DESTROY).post(threadData);
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

    public LiveData<Resource<Boolean>> leaveThread(ThreadData threadData) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getThreadManager().leaveChatThread(threadData.getThreadId(), new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        LiveEventBus.get(Constants.THREAD_LEAVE).post(threadData);
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

    public LiveData<Resource<EMChatThread>> getChannlThread(String threadId) {
        return new NetworkOnlyResource<EMChatThread>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<EMChatThread>> callBack) {
                getThreadManager().getChatThreadFromServer(threadId, new EMValueCallBack<EMChatThread>() {
                    @Override
                    public void onSuccess(EMChatThread value) {
                        callBack.onSuccess(createLiveData(value));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<Boolean>> updateChatThreadName(ThreadData threadData, String targetThreadName) {
        return new NetworkOnlyResource<Boolean>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<Boolean>> callBack) {
                getThreadManager().updateChatThreadName(threadData.getThreadId(), targetThreadName, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(true));
                        //发出更改threadname成功的广播
                        threadData.setThreadName(targetThreadName);
                        LiveEventBus.get(Constants.THREAD_UPDATE).post(threadData);
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<String>> inviteUserToChannel(String serverId, String channelId, String userId, String welcome) {
        return new NetworkOnlyResource<String>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<String>> callBack) {
                getCircleManager().inviteUserToChannel(serverId, channelId, userId, welcome, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(createLiveData(userId));
                    }

                    @Override
                    public void onError(int code, String error) {
                        callBack.onError(code, error);
                    }
                });
            }
        }.asLiveData();
    }

    public LiveData<Resource<CustomInfo>> checkSelfIsInChannel(CustomInfo customInfo) {

        return new NetworkOnlyResource<CustomInfo>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<CustomInfo>> callBack) {
                getCircleManager().checkSelfIsInChannel(customInfo.getServerId(), customInfo.getChannelId(), new EMValueCallBack<Boolean>() {
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

    public LiveData<Resource<List<ThreadData>>> getThreadLastMessages(List<EMChatThread> chatThreads) {
        return new NetworkOnlyResource<List<ThreadData>>() {
            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<ThreadData>>> callBack) {
                List<String> threadIds = filterChatThreadsToIds(chatThreads);
                getThreadManager().getChatThreadLatestMessage(threadIds, new EMValueCallBack<Map<String, EMMessage>>() {
                    @Override
                    public void onSuccess(Map<String, EMMessage> lastMsgs) {
                        List threadDatas = new ArrayList();
                        for (EMChatThread chatThread : chatThreads) {
                            ThreadData threadData = new ThreadData(chatThread.getChatThreadName(), chatThread.getChatThreadId(), chatThread.getParentId(), lastMsgs.get(chatThread.getChatThreadId()), chatThread.getMessageId());
                            threadDatas.add(threadData);
                        }
                        callBack.onSuccess(createLiveData(threadDatas));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        callBack.onError(error, errorMsg);
                    }
                });

            }
        }.asLiveData();
    }

    private List<String> filterChatThreadsToIds(List<EMChatThread> chatThreads) {
        List<String> ids = new ArrayList<>();
        if (chatThreads != null) {
            for (int i = 0; i < chatThreads.size(); i++) {
                EMChatThread chatThread = chatThreads.get(i);
                if (chatThread != null) {
                    ids.add(chatThread.getChatThreadId());
                }
            }
        }
        return ids;
    }

    public LiveData<Resource<List<CircleUser>>> fetchChannelMuteUsers(String serverId, String channelId) {

        return new NetworkOnlyResource<List<CircleUser>>() {

            @Override
            protected void createCall(@NonNull ResultCallBack<LiveData<List<CircleUser>>> callBack) {
                getCircleManager().fetchChannelMuteUsers(serverId, channelId, new EMValueCallBack<Map<String, Long>>() {
                    @Override
                    public void onSuccess(Map<String, Long> usersMuted) {
                        List<CircleUser> circleUsersMuted = new ArrayList<>();
                        if (usersMuted != null) {
                            for (String username : usersMuted.keySet()) {
                                CircleUser circleUser = getUserDao().loadUserByUserId(username);
                                if (circleUser == null) {
                                    circleUser = new CircleUser(username);
                                }
                                circleUser.isMuted = true;
                                circleUsersMuted.add(circleUser);
                                getUserDao().insert(circleUser);
                            }
                        }
                        callBack.onSuccess(createLiveData(circleUsersMuted));
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
