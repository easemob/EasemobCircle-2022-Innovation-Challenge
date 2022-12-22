package io.agora.home.ui;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.Observer;

import com.hyphenate.chat.EMChatThread;

import java.util.ArrayList;
import java.util.List;

import io.agora.service.db.entity.CircleChannel;
import io.agora.service.model.ServerViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.CircleChannelReposity;

public class ServerDetailViewModel extends ServerViewModel {
    private CircleChannelReposity channelReposity = new CircleChannelReposity();

    public MediatorLiveData<Resource<List<EMChatThread>>> getThreadsLiveData = new MediatorLiveData<>();
    private List<LiveData> threadSources = new ArrayList<>();

    public MediatorLiveData<Resource<List<CircleChannel>>> getChannelsLiveData = new MediatorLiveData<>();
    private List<LiveData> channelSources = new ArrayList<>();

    public ServerDetailViewModel(@NonNull Application application) {
        super(application);
    }

    public void getChannelData(String serverID) {
        getPublicChannelData(serverID);
        getPrivateChannelData(serverID);
    }

    public void getPublicChannelData(String serverID) {
        LiveData<Resource<List<CircleChannel>>> publicChannelListLiveData = channelReposity.getPublicChannelList(serverID);
        getChannelsLiveData.addSource(publicChannelListLiveData, new Observer<Resource<List<CircleChannel>>>() {
            @Override
            public void onChanged(Resource<List<CircleChannel>> listResource) {
                getChannelsLiveData.setValue(listResource);
            }
        });
        channelSources.add(publicChannelListLiveData);
    }

    public void getPrivateChannelData(String serverID) {
        LiveData<Resource<List<CircleChannel>>> privateChannelListLiveData = channelReposity.getPrivateChannelList(serverID);
        getChannelsLiveData.addSource(privateChannelListLiveData, new Observer<Resource<List<CircleChannel>>>() {
            @Override
            public void onChanged(Resource<List<CircleChannel>> listResource) {
                getChannelsLiveData.setValue(listResource);
            }
        });
        channelSources.add(privateChannelListLiveData);
    }

    public void getChannelThreads(String channelId) {
        LiveData<Resource<List<EMChatThread>>> source = channelReposity.getChannelThreads(channelId);
        getThreadsLiveData.addSource(source, new Observer<Resource<List<EMChatThread>>>() {
            @Override
            public void onChanged(Resource<List<EMChatThread>> listResource) {
                getThreadsLiveData.setValue(listResource);
            }
        });
        threadSources.add(source);
    }

    public void clearThreadsSources() {
        for (LiveData source : threadSources) {
            getThreadsLiveData.removeSource(source);
        }
    }

    public void clearChannelsSources() {
        for (LiveData source : channelSources) {
            getChannelsLiveData.removeSource(source);
        }
    }
}