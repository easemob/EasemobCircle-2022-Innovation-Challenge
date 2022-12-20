package io.agora.ground.model;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;

import java.util.List;

import io.agora.service.db.entity.CircleServer;
import io.agora.service.model.ServerViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.CircleServerReposity;
import io.agora.service.utils.SingleSourceLiveData;

public class GroundViewModel extends ServerViewModel {

    private CircleServerReposity reposity=new CircleServerReposity();
    public SingleSourceLiveData<Resource<List<CircleServer>>> serverJoinedListLiveData =new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<List<CircleServer>>> serverRecommendListLiveData =new SingleSourceLiveData<>();

    public GroundViewModel(@NonNull Application application) {
        super(application);
    }

    public LiveData<Resource<List<CircleServer>>> getServerListByKey(String key){
       return reposity.getServerListByKey(key);
    }

    public void getServerJoinedList(){
        serverJoinedListLiveData.setSource(reposity.getServerJoinedList());
    }

    public void getRecommandServerList(){
        serverRecommendListLiveData.setSource(reposity.getRecommendServerList());
    }
}