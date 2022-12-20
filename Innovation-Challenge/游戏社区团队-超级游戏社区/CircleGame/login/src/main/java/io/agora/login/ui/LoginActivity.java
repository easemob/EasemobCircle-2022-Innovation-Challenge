package io.agora.login.ui;

import static io.agora.service.utils.CircleUtils.checkAgoraChatAppKey;

import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.EMError;

import io.agora.common.webview.WebViewActivity;
import io.agora.login.R;
import io.agora.login.databinding.ActivityLoginBinding;
import io.agora.login.model.LoginViewModel;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.bean.UserAccountBean;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.net.Resource;

@Route(path = "/login/LoginActivity")
public class LoginActivity extends BaseInitActivity<ActivityLoginBinding> implements View.OnClickListener {

    private LoginViewModel mViewModel;

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_login;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(LoginViewModel.class);
        mBinding.setVm(mViewModel);
        initListener();
    }

    private void initListener() {
        mViewModel.loginLiveData.observe(this, new Observer<Resource<String>>() {
            @Override
            public void onChanged(Resource<String> easeUserResource) {
                parseResource(easeUserResource, new OnResourceParseCallback<String>() {
                    @Override
                    public void onSuccess(@Nullable String username) {
                        dismissLoading();
                        ARouter.getInstance().build("/app/MainActivity").navigation();
                        finish();
                    }

                    @Override
                    public void onError(int code, String message) {
                        super.onError(code, message);
                        if (code == EMError.USER_NOT_FOUND) {
                            mViewModel.register();
                        } else {
                            dismissLoading();
                            if (!TextUtils.isEmpty(message)) {
                                ToastUtils.showShort(message);
                            }
                        }
                    }
                });
            }
        });
        mViewModel.registerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<UserAccountBean>() {
                @Override
                public void onSuccess(@Nullable UserAccountBean data) {
                    mViewModel.login();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    dismissLoading();
                    if (!TextUtils.isEmpty(message)) {
                        ToastUtils.showShort(message);
                    }
                }
            });
        });
        mBinding.btnLogin.setOnClickListener(this);
    }

    @Override
    protected void initData() {
        super.initData();
        mBinding.tvAgreement.setText(getSpannable());
        mBinding.tvAgreement.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private SpannableString getSpannable() {
        SpannableString spanStr = new SpannableString(getString(R.string.circle_login_agreement));
        //设置下划线
        //spanStr.setSpan(new UnderlineSpan(), 3, 7, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spanStr.setSpan(new MyClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                WebViewActivity.actionStart(LoginActivity.this, getResources().getString(io.agora.service.R.string.service_agreement_url));
            }
        }, 2, 10, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        //spanStr.setSpan(new UnderlineSpan(), 10, 14, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spanStr.setSpan(new MyClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                WebViewActivity.actionStart(LoginActivity.this, getResources().getString(io.agora.service.R.string.privacy_agreement_url));
            }
        }, 11, spanStr.length() - 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        return spanStr;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_login) {
            //检查是否设置appkey
            if(checkAgoraChatAppKey(mContext)) {
                showLoading(getString(R.string.circle_in_login), false);
                mViewModel.login();
            }else{
                ToastUtils.showShort(getString(io.agora.service.R.string.circle_no_appkey));
            }
        }
    }

    private abstract class MyClickableSpan extends ClickableSpan {

        @Override
        public void updateDrawState(@NonNull TextPaint ds) {
            super.updateDrawState(ds);
            ds.bgColor = Color.TRANSPARENT;
            ds.setColor(ContextCompat.getColor(LoginActivity.this, io.agora.service.R.color.color_blue_27ae60));
        }
    }
}