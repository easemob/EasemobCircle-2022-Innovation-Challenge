package io.agora.mine.model;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.ViewModel;

import io.agora.service.net.Resource;
import io.agora.service.repo.ServiceReposity;


public class MineViewModel extends ViewModel {
    private ServiceReposity serviceReposity=new ServiceReposity();

    public LiveData<Resource<Boolean>> logout(boolean unbindtoken) {
       return serviceReposity.logout(unbindtoken);
    }
}
