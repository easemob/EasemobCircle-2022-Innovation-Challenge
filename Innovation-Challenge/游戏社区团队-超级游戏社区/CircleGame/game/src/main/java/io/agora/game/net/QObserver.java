package io.agora.game.net;


import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;


import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.ToastUtils;

import io.agora.common.base.BaseActivity;
import io.agora.common.base.BaseFragment;
import io.agora.game.bean.CommonBean;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;

public abstract class QObserver<T> implements Observer<CommonBean<T>> {
    private BaseActivity mContext;
    private boolean isDismissDialogAfter = true;
    private boolean mShowError = true;
    private boolean showLoading = true;

    public QObserver(BaseActivity context) {
        mContext = context;
        initDialog();
    }

    public QObserver(BaseActivity context, boolean dismissDialogAfter) {
        mContext = context;
        isDismissDialogAfter = dismissDialogAfter;
        initDialog();
    }

    public QObserver(BaseActivity context, boolean dismissDialogAfter, boolean showError) {
        mContext = context;
        isDismissDialogAfter = dismissDialogAfter;
        mShowError = showError;
        initDialog();
    }


    public QObserver(BaseActivity context, boolean dismissDialogAfter, boolean showError, boolean showLoading) {
        mContext = context;
        isDismissDialogAfter = dismissDialogAfter;
        mShowError = showError;
        this.showLoading = showLoading;
        initDialog();
    }

    @Override
    public void onSubscribe(@NonNull Disposable d) {
        start();
        if (showLoading)
        LoadingUtil.getInstance().showDialog();
    }

    @Override
    public void onNext(@NonNull CommonBean<T> commonBean) {

        if (TextUtils.isEmpty(commonBean.getError())) {
            Log.e("tagqi", "onNext: " + GsonUtils.toJson(commonBean));
            if (commonBean.getPost() != null){
                next(commonBean.getPost());
            } else {
                next(commonBean.getListElements());
            }

        } else {
            if (mShowError) ToastUtils.showLong(commonBean.getError());
            Log.e("tagqi", "error: " + commonBean.getError());
            error(commonBean.getError(), commonBean.getError());
        }
//        if (TextUtils.equals(commonBean.getCode(), "0000")) {
//            Log.e("tagqi", "onNext: " + GsonUtils.toJson(commonBean));
//            next(commonBean.getData());
//        } else {
//            if (mShowError) ToastUtils.showLong(commonBean.getMsg());
//            Log.e("tagqi", "error: " + commonBean.getMsg());
//            error(commonBean.getCode(), commonBean.getMsg());
//        }
        dismissDialog();
    }

    @Override
    public void onError(@NonNull Throwable e) {
        Log.e("tagqi", "error: " + e.getMessage());
        error("xxxx", e.getMessage());
        if (mShowError) ToastUtils.showLong(e.getMessage());
        dismissDialog();
    }

    private void dismissDialog() {
        if (!isDismissDialogAfter) {
            return;
        }
        if (showLoading)
        LoadingUtil.getInstance().dismissDialog();
    }

    @Override
    public void onComplete() {
        Log.e("tagqi", "onComplete: ");
        complete();
        dismissDialog();
    }

    private void initDialog() {
//        LoadingUtil.getInstance().init(mContext);
    }

    protected void start() {
    }

    public abstract void next(T t);

    public void error(String code, String msg) {

    }

    public void complete() {

    }
}
