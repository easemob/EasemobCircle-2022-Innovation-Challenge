package io.agora.service.base;


import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.databinding.ViewDataBinding;

import io.agora.common.base.BaseActivity;
import io.agora.common.dialog.AlertDialog;
import io.agora.service.R;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.net.Resource;
import io.agora.service.net.Status;

public abstract class BaseInitActivity<T extends ViewDataBinding> extends BaseActivity<T> {

    private AlertDialog alertDialog;
    private TextView tvMessage;

    public <T> void parseResource(Resource<T> response, @NonNull OnResourceParseCallback<T> callback) {
        if (response == null) {
            return;
        }
        if (response.status == Status.SUCCESS) {
            callback.onHideLoading();
            callback.onSuccess(response.data);
        } else if (response.status == Status.ERROR) {
            callback.onHideLoading();
            if (!callback.hideErrorMsg) {
//                ToastUtils.showShort(response.getMessage(getApplicationContext()));
            }
            callback.onError(response.errorCode, response.getMessage(getApplicationContext()));
        } else if (response.status == Status.LOADING) {
            callback.onLoading(response.data);
        }
    }

    public void showLoading() {
        showLoading(getString(R.string.loading));
    }

    public void showLoading(String message) {
        showLoading(message, true);
    }

    public void showLoading(String message, boolean cancelable) {
        if (alertDialog == null) {
            alertDialog = new AlertDialog.Builder(this)
                    .setContentView(R.layout.circle_dialog_progressbar)
                    .setCancelable(cancelable)
                    .setGravity(Gravity.CENTER)
                    .create();
        }
        if (tvMessage == null) {
            tvMessage = alertDialog.getViewById(R.id.tv_message);
        }
        if (!TextUtils.isEmpty(message)) {
            tvMessage.setText(message);
            tvMessage.setVisibility(View.VISIBLE);
        } else {
            tvMessage.setText("");
            tvMessage.setVisibility(View.GONE);
        }
        alertDialog.show();
    }

    public void dismissLoading() {
        if (alertDialog != null) {
            alertDialog.dismiss();
        }
    }
}
