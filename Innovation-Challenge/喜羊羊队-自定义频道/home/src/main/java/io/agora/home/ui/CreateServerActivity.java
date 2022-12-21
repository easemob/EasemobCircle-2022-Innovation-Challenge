package io.agora.home.ui;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.easeui.utils.EaseCompat;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.jeremyliao.liveeventbus.LiveEventBus;
import com.tbruyelle.rxpermissions2.RxPermissions;

import io.agora.home.R;
import io.agora.home.databinding.ActivityCreateServerBinding;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.model.ServerViewModel;
import io.agora.service.utils.UriFormatUtils;

@Route(path = "/home/CreateServerActivity")
public class CreateServerActivity extends BaseInitActivity<ActivityCreateServerBinding> implements
        EaseTitleBar.OnBackPressListener, EaseTitleBar.OnRightClickListener, View.OnClickListener {
    private static final int REQUEST_CODE_LOCAL = 1;
    private String imagePath;
    //输入框初始值
    private int namePrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    //输入框初始值
    private int descPrimaryNum = 0;
    //输入框最大值
    public int mMaxDescNum = 120;
    private ServerViewModel mViewModel;
    private TextView rightText;
    private RxPermissions rxPermissions;

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_create_server;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        rightText = mBinding.titleBar.getRightText();
        mBinding.titleBar.setLeftLayoutVisibility(View.VISIBLE);
        rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_gray_929497));
        rightText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        mBinding.titleBar.getRightLayout().setEnabled(false);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ServerViewModel.class);
        mViewModel.createServerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer data) {
                    dismissLoading();
                    ToastUtils.showShort(getString(io.agora.service.R.string.home_create_server_success));
                    finish();
                    //发出通知
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(data);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    dismissLoading();
                    mBinding.titleBar.getRightLayout().setEnabled(true);
                    ToastUtils.showShort("error code :" + code + ",error message:" + message);
                }
            });
        });
        initListener();
    }

    private void initListener() {

        mBinding.edtServerName.addTextChangedListener(new TextWatcher() {
            //记录输入的字数
            private CharSequence wordNum;
            private int selectionStart;
            private int selectionEnd;

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
                int number = namePrimaryNum + s.length();
                //TextView显示剩余字数
                mBinding.tvNameCount.setText("" + number + "/16");
                selectionStart = mBinding.edtServerName.getSelectionStart();
                selectionEnd = mBinding.edtServerName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtServerName.setText(s);
                    mBinding.edtServerName.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateServerButtonStatus();
            }
        });
        mBinding.edtServerDesc.addTextChangedListener(new TextWatcher() {
            //记录输入的字数
            private CharSequence wordNum;
            private int selectionStart;
            private int selectionEnd;

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
                int number = descPrimaryNum + s.length();
                //TextView显示剩余字数
                mBinding.tvDescCount.setText("" + number + "/120");
                selectionStart = mBinding.edtServerDesc.getSelectionStart();
                selectionEnd = mBinding.edtServerDesc.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxDescNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtServerDesc.setText(s);
                    mBinding.edtServerDesc.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateServerButtonStatus();
            }
        });
        mBinding.ivAddBg.setOnClickListener(this);
        mBinding.titleBar.setOnRightClickListener(this);
        mBinding.titleBar.setOnBackPressListener(this);

    }

    private void checkCreateServerButtonStatus() {
        String name = mBinding.edtServerName.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_gray_929497));
            mBinding.titleBar.getRightLayout().setEnabled(false);
        } else {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_blue_27ae60));
            mBinding.titleBar.getRightLayout().setEnabled(true);
        }
    }

    @Override
    public void onBackPress(View view) {
        finish();
    }

    @Override
    protected void initData() {
        super.initData();
        rxPermissions = new RxPermissions(this);
    }

    @Override
    public void onRightClick(View view) {
        mBinding.titleBar.getRightLayout().setEnabled(false);
        String name = mBinding.edtServerName.getText().toString().trim();
        String desc = mBinding.edtServerDesc.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            ToastUtils.showShort(getString(io.agora.service.R.string.home_server_name_is_null));
            return;
        }
        hideKeyboard();
        showLoading(null);
        mViewModel.createServer(imagePath, name, desc);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_add_bg) {
            //申请权限
            rxPermissions
                    .request(
                            Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            // All requested permissions are granted
                            //去相册选择
                            EaseCompat.openImage(this, REQUEST_CODE_LOCAL);
                        }
                    });

        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_LOCAL) { // send local image
                onActivityResultForLocalPhotos(data);
            }
        }
    }

    /**
     * 选择本地图片处理结果
     *
     * @param data
     */
    private void onActivityResultForLocalPhotos(@Nullable Intent data) {
        if (data != null) {
            Uri selectedImage = data.getData(); //获取系统返回的照片的Uri
            imagePath = UriFormatUtils.getPathByUri4kitkat(mContext, selectedImage);
            Glide.with(this).load(imagePath).placeholder(getDrawable(io.agora.service.R.color.color_gray_474747)).into(mBinding.ivAddBg);
            mBinding.ivAdd.setImageResource(R.drawable.home_change_cover);
            mBinding.tvServerIcon.setText(getString(io.agora.service.R.string.home_change_conver));
        }
    }
}