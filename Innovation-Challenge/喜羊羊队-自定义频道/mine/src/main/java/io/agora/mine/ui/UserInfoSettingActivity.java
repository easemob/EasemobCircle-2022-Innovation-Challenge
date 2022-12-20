package io.agora.mine.ui;

import android.Manifest;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.haoge.easyandroid.easy.EasyMediaFile;
import com.haoge.easyandroid.easy.EasyPermissions;
import com.hyphenate.easeui.widget.EaseTitleBar;

import java.io.File;

import io.agora.common.dialog.AlertDialog;
import io.agora.mine.R;
import io.agora.mine.databinding.ActivityUserInfoSettingBinding;
import io.agora.mine.model.UserInfoSettingViewModel;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

public class UserInfoSettingActivity extends BaseInitActivity<ActivityUserInfoSettingBinding> implements EaseTitleBar.OnBackPressListener, View.OnClickListener {
    private UserInfoSettingViewModel mViewModel;
    private String mImageUrl;
    private CircleUser currentUser;
    private boolean updateUserImageSuccess;
    private boolean updateUserNickname;
    private AlertDialog alertDialog;
    private EditText dialogEdtNickName;
    //输入框最大值
    public int mMaxNameNum = 16;

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_user_info_setting;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mBinding.titleBar.setLeftLayoutVisibility(View.VISIBLE);

        RelativeLayout.LayoutParams titleParams = (RelativeLayout.LayoutParams) mBinding.titleBar.getTitle().getLayoutParams();
        titleParams.setMargins(ConvertUtils.dp2px(48), 0, 0, 0);
        mBinding.titleBar.getTitle().setLayoutParams(titleParams);

        RelativeLayout.LayoutParams iconParams = (RelativeLayout.LayoutParams) mBinding.titleBar.getLeftLayout().getLayoutParams();
        iconParams.setMargins(ConvertUtils.dp2px(6), 0, 0, 0);
        mBinding.titleBar.getLeftLayout().setLayoutParams(iconParams);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(UserInfoSettingViewModel.class);
        mViewModel.uploadImageLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(@Nullable String imageUrl) {
                    dismissLoading();
                    mImageUrl = imageUrl;
                    Glide.with(UserInfoSettingActivity.this).load(imageUrl).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(mBinding.ivAvater);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    dismissLoading();
                    ToastUtils.showShort(getString(io.agora.service.R.string.circle_upLoad_failure));
                }
            });
        });
        mViewModel.updateImageLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleUser>() {
                @Override
                public void onSuccess(@Nullable CircleUser data) {
                    updateUserImageSuccess = true;
                    checkResult();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(message);
                    finish();
                }
            });
        });
        mViewModel.updateNicknameLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleUser>() {
                @Override
                public void onSuccess(@Nullable CircleUser data) {
                    updateUserNickname = true;
                    checkResult();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(message);
                    finish();
                }
            });
        });

        mBinding.titleBar.setOnBackPressListener(this);
        mBinding.clsHeadview.setOnClickListener(this);
        mBinding.tvNickname.setOnClickListener(this);
    }

    private void checkResult() {
        if (updateUserImageSuccess && updateUserNickname) {
            ToastUtils.showShort(getString(io.agora.service.R.string.circle_update_success));
            finish();
        }
    }

    @Override
    protected void initData() {
        super.initData();
        AppUserInfoManager.getInstance().getCurrentUserLiveData().observe(this, new Observer<CircleUser>() {
            @Override
            public void onChanged(CircleUser currentUser) {
                if (currentUser != null) {
                    setUserData(currentUser);
                }
            }
        });
    }

    private void setUserData(CircleUser currentUser) {
        this.currentUser = currentUser;
        Glide.with(this).
                load(currentUser.getAvatar())
                .placeholder(io.agora.service.R.drawable.circle_default_avatar)
                .into(mBinding.ivAvater);
        mBinding.tvNickname.setText(currentUser.getNickname());
    }

    @Override
    public void onBackPress(View view) {
        updateUserInfo();
    }

    private void updateUserInfo() {
        hideKeyboard();
        //更新url和nickname到服务器
        if (!TextUtils.equals(currentUser.getAvatar(), mImageUrl) && !TextUtils.isEmpty(mImageUrl)) {
            mViewModel.updateUserImage(mImageUrl);
        }
        String nickName = mBinding.tvNickname.getText().toString().trim();
        if (!TextUtils.equals(currentUser.getNickname(), nickName)) {
            mViewModel.updateUserNickname(nickName);
        }
        finish();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        updateUserInfo();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.cls_headview) {
            selectedPicture();
        } else if (v.getId() == R.id.tv_nickname) {
            showSetNickNameDialog();
        }
    }

    private void showSetNickNameDialog() {
        alertDialog = new AlertDialog.Builder(this)
                .setContentView(R.layout.dialog_add_nickname)
                .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                .setOnClickListener(R.id.tv_cancel, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        alertDialog.dismiss();
                    }
                })
                .setOnClickListener(R.id.tv_confirm, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        String nickName = dialogEdtNickName.getText().toString().trim();
                        mBinding.tvNickname.setText(nickName);
                        alertDialog.dismiss();
                    }
                })
                .show();
        dialogEdtNickName = alertDialog.getViewById(R.id.edt_nickname);
        TextView tvCount = alertDialog.getViewById(R.id.tv_tag_count);

        dialogEdtNickName.addTextChangedListener(new TextWatcher() {
            //记录输入的字数
            private CharSequence wordNum;
            private int selectionStart;
            private int selectionEnd;
            private int tagPrimaryNum;

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                //实时记录输入的字数
                wordNum = s;
            }

            @Override
            public void afterTextChanged(Editable s) {
                int number = tagPrimaryNum + s.length();
                //TextView显示剩余字数
                tvCount.setText("" + number + "/16");
                selectionStart = dialogEdtNickName.getSelectionStart();
                selectionEnd = dialogEdtNickName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    dialogEdtNickName.setText(s);
                    dialogEdtNickName.setSelection(tempSelection);//设置光标在最后
                }
            }
        });
    }

    private void selectedPicture() {
        mImageUrl = null;
        //去图库选择图片
        EasyMediaFile photo = new EasyMediaFile();// 创建EasyPhoto实例
        //拒绝权限将无法使用
        EasyPermissions.create(
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.CAMERA)
                .callback(new Function1<Boolean, Unit>() {
                    @Override
                    public Unit invoke(Boolean grant) {
                        if (grant) {
                            // 或者跳转图库进行图片选择
                            photo.selectPhoto(UserInfoSettingActivity.this);
                        }
                        return null;
                    }
                }).request(this);
        // 通过设置回调，获取选择到的文件
        photo.setCallback(new Function1<File, Unit>() {
            @Override
            public Unit invoke(File file) {
                //上传图片
                String path = file.getAbsolutePath();
                showLoading(getString(R.string.circle_image_in_uploading));
                mViewModel.uploadImage(path);
                return null;
            }
        });

    }
}