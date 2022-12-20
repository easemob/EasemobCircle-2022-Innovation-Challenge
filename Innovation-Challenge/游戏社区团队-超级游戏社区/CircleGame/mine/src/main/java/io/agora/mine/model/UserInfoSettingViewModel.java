package io.agora.mine.model;

import android.app.Application;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMUserInfo;

import io.agora.service.db.entity.CircleUser;
import io.agora.service.model.ServiceViewModel;
import io.agora.service.net.Resource;
import io.agora.service.repo.EMContactManagerRepository;
import io.agora.service.repo.ServiceReposity;
import io.agora.service.utils.SingleSourceLiveData;


public class UserInfoSettingViewModel extends ServiceViewModel {
    private EMContactManagerRepository mContactRepository=new EMContactManagerRepository();
    private ServiceReposity serviceReposity=new ServiceReposity();
    public SingleSourceLiveData<Resource<String>> uploadImageLiveData=new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleUser>> updateImageLiveData=new SingleSourceLiveData<>();
    public SingleSourceLiveData<Resource<CircleUser>> updateNicknameLiveData=new SingleSourceLiveData<>();

    public UserInfoSettingViewModel(@NonNull Application application) {
        super(application);

    }

    public void uploadImage(String imagePath){
        uploadImageLiveData.setSource(serviceReposity.uploadFile(mContext,imagePath));
    }

    public void updateUserImage(String mImageUrl) {
        updateImageLiveData.setSource(mContactRepository.updateCurrentUserInfo(EMUserInfo.EMUserInfoType.AVATAR_URL,mImageUrl));
    }
    public void updateUserNickname(String nickName) {
        updateNicknameLiveData.setSource(mContactRepository.updateCurrentUserInfo(EMUserInfo.EMUserInfoType.NICKNAME,nickName));
    }
}
