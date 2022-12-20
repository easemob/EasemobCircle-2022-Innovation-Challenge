package io.agora.circle.model;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;

import io.agora.service.model.ServiceViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.ServiceReposity;


public class SplashViewModel extends ServiceViewModel {
    private ServiceReposity serviceReposity=new ServiceReposity();

    public SplashViewModel(@NonNull Application application) {
        super(application);
    }

    public LiveData<Resource<String>> getLoginData() {
        return serviceReposity.loadAllInfoFromHX();
    }

}
