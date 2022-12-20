package io.agora.service.callbacks;


import com.hyphenate.EMValueCallBack;

public abstract class ResultCallBack<T> implements EMValueCallBack<T> {

    /**
     * For situations where only error code is returned
     * @param error
     */
    public void onError(int error) {
        onError(error, null);
    }
}
