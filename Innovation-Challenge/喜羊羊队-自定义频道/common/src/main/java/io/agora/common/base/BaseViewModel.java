package io.agora.common.base;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.blankj.utilcode.util.ThreadUtils;


/**
 * 存放与业务无关的公用功能封装
 */
public class BaseViewModel extends AndroidViewModel {
    protected Context mContext;

    protected MutableLiveData<Boolean> isLoading = new MutableLiveData();

    public BaseViewModel(@NonNull Application application) {
        super(application);
        this.mContext=application;
    }

    protected <T> void executeTask(Runnable runnable) {
        ThreadUtils.getCachedPool().execute(new Runnable() {
            @Override
            public void run() {
                isLoading.postValue(true);
                runnable.run();
                isLoading.postValue(false);
            }
        });
    }


    protected void onCleared() {
        ThreadUtils.cancel();
    }
}
