package io.agora.login.model;


import static io.agora.service.utils.MobileUtil.isPhoneLegal;

import android.app.Application;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.databinding.ObservableBoolean;
import androidx.databinding.ObservableField;
import androidx.databinding.ObservableInt;

import com.hyphenate.EMError;
import com.hyphenate.chat.EMClient;

import io.agora.login.R;
import io.agora.service.bean.UserAccountBean;
import io.agora.service.global.GlobalServer;
import io.agora.service.model.ServiceViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.ServiceReposity;
import io.agora.service.utils.SingleSourceLiveData;

public class LoginViewModel extends ServiceViewModel {

    public ObservableField<String> obAccount = new ObservableField<>();
    public ObservableField<String> obPwd = new ObservableField<>();
    public ObservableInt mode = new ObservableInt(1);
    public ObservableBoolean agreement = new ObservableBoolean(true);

    private ServiceReposity reposity=new ServiceReposity();
    public SingleSourceLiveData<Resource<String>> loginLiveData=new SingleSourceLiveData();
    public SingleSourceLiveData<Resource<UserAccountBean>> registerLiveData=new SingleSourceLiveData();

    public LoginViewModel(@NonNull Application application) {
        super(application);
    }

    public void delete(View view) {
        obAccount.set("");
    }

    public void showPwd(View view) {
        if (mode.get() == 1) {
            mode.set(0);
        } else {
            mode.set(1);
        }
    }

    public void login() {
        if(!EMClient.getInstance().isSdkInited()) {
            GlobalServer.getInstance().initHX(mContext);
        }
        if(checkAccount()) {
            loginLiveData.setSource(reposity.loginToServer(obAccount.get(), "1"));
        }else{
            loginLiveData.setValue(Resource.error(EMError.GENERAL_ERROR, mContext.getString(R.string.circle_phone_illegal),null));
        }

    }
    public void register(){
        if(checkAccount()) {
            registerLiveData.setSource(reposity.registerToHx(obAccount.get(), "1"));
        }else{
            registerLiveData.setValue(Resource.error(EMError.GENERAL_ERROR, mContext.getString(R.string.circle_phone_illegal),null));
        }
    }

    private boolean checkAccount() {
        //只能是手机号
       return isPhoneLegal(obAccount.get());
    }
}
