package io.agora.service.model;


import android.app.Application;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.databinding.ObservableField;

import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMCircleChannelAttribute;
import com.hyphenate.chat.EMCircleChannelStyle;

import java.util.List;

import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.ThreadData;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.net.Resource;
import io.agora.service.repo.CircleChannelReposity;
import io.agora.service.utils.SingleSourceLiveData;

/**
 * 对channel的所有操作都放在这里
 */
public class ChannelViewModel extends ServiceViewModel {
    public ObservableField<String> channelName = new ObservableField<>();

    private CircleChannelReposity channelReposity = new CircleChannelReposity();
    public SingleSourceLiveData<Resource<List<CircleUser>>> channelMembersLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleChannel>> createChannelResultLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleChannel>> deleteChannelResultLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleChannel>> leaveChannelResultLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> muteUserLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<String>> removeUserLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleChannel>> updateChannelLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<String>> inviteUserToChannelLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CustomInfo>> checkSelfIsInChannelLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<CircleUser>>> fetchChannelMuteUsersLiveData = new SingleSourceLiveData<>();

    public SingleSourceLiveData<Resource<List<EMChatThread>>> channelThreadListLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<EMChatThread>> getThreadLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> deleteThreadResultLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> leaveThreadResultLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<String>>> threadMembersLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<Boolean>> updateChatThreadNameLiveData = new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<ThreadData>>> getThreadLastMessagesLiveData = new SingleSourceLiveData<>();

    public ChannelViewModel(@NonNull Application application) {
        super(application);
    }

    public void getChannelMembers(String serverId, String channelId) {
        channelMembersLiveData.setSource(channelReposity.getChannelMembers(serverId, channelId));
    }

    public void createChannel(String serverId, EMCircleChannelAttribute attribute, EMCircleChannelStyle style) {
        createChannelResultLiveData.setSource(channelReposity.createChannel(serverId, attribute, style));
    }

    public void deleteChannel(CircleChannel channel) {
        deleteChannelResultLiveData.setSource(channelReposity.deleteChannel(channel));
    }

    public void leaveChannel(CircleChannel channel) {
        leaveChannelResultLiveData.setSource(channelReposity.leaveChannel(channel));
    }

    public void delete(View view) {
        channelName.set("");
    }

    public void muteUserInChannel(CircleChannel channel, long muteDuration, String username, boolean mute) {
        muteUserLiveData.setSource(channelReposity.muteUserInChannel(channel.serverId, channel.channelId, muteDuration, username, mute));
    }

    public void removeUserFromChannel(String serverId, String channelId, String username) {
        removeUserLiveData.setSource(channelReposity.removeUserFromChannel(serverId, channelId, username));
    }

    public void updateChannel(CircleChannel channel, EMCircleChannelAttribute attribute) {
        updateChannelLiveData.setSource(channelReposity.updateChannel(channel, attribute));
    }

    public void inviteUserToChannel(String serverId, String channelId, String userId, String welcome) {
        inviteUserToChannelLiveData.setSource(channelReposity.inviteUserToChannel(serverId, channelId, userId, welcome));
    }

    public void fetchChannelMuteUsers(String serverId, String channelId) {
        fetchChannelMuteUsersLiveData.setSource(channelReposity.fetchChannelMuteUsers(serverId,channelId));
    }

    public void getChannlThreadList(String channelId) {
        channelThreadListLiveData.setSource(channelReposity.getChannelThreads(channelId));
    }

    public void getChannlThread(String threadId) {
        getThreadLiveData.setSource(channelReposity.getChannlThread(threadId));
    }


    public void getThreadMembers(String threadId) {
        threadMembersLiveData.setSource(channelReposity.getThreadMembers(threadId));
    }

    public void deleteThread(ThreadData threadData) {
        deleteThreadResultLiveData.setSource(channelReposity.deleteThread(threadData));
    }

    public void leaveThread(ThreadData threadData) {
        leaveThreadResultLiveData.setSource(channelReposity.leaveThread(threadData));
    }

    public void updateChatThreadName(ThreadData threadData, String targetThreadName) {
        updateChatThreadNameLiveData.setSource(channelReposity.updateChatThreadName(threadData, targetThreadName));
    }

    public void checkSelfIsInChannel(CustomInfo customInfo) {
        checkSelfIsInChannelLiveData.setSource(channelReposity.checkSelfIsInChannel(customInfo));
    }

    public void getThreadLastMessages(List<EMChatThread> chatThreads) {
        getThreadLastMessagesLiveData.setSource(channelReposity.getThreadLastMessages(chatThreads));
    }
}
