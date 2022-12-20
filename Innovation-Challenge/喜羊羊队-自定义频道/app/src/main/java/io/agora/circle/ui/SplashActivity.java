package io.agora.circle.ui;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import java.util.concurrent.TimeUnit;

import io.agora.circle.R;
import io.agora.circle.model.SplashViewModel;
import io.agora.login.ui.LoginActivity;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

public class SplashActivity extends BaseInitActivity {
    private SplashViewModel mViewModel;

    private Disposable disposable;

    @Override
    protected int getResLayoutId() {
        getWindow().setBackgroundDrawable(null);
        return R.layout.activity_splash;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
    }

    @Override
    protected void initData() {
        super.initData();
        mViewModel=new ViewModelProvider(this).get(SplashViewModel.class);
        disposable = Flowable.intervalRange(0,1,500,500, TimeUnit.MILLISECONDS)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .doOnComplete(() -> {
                    getLoginData();
                })
                .subscribe();
    }

    private void getLoginData() {
        mViewModel.getLoginData().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(@Nullable String username) {
                    Intent intent = new Intent(SplashActivity.this, MainActivity.class);
                    startActivity(intent);
                    finish();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    Intent intent = new Intent(SplashActivity.this, LoginActivity.class);
                    startActivity(intent);
                    finish();
                }
            });
        });

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(disposable!=null) {
            disposable.dispose();
        }
    }
}