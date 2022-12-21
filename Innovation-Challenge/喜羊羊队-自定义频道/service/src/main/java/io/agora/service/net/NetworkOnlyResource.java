package io.agora.service.net;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.WorkerThread;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;

import com.blankj.utilcode.util.ThreadUtils;
import com.hyphenate.util.EMLog;

import io.agora.service.callbacks.ResultCallBack;


/**
 * This class is used to pull asynchronous data from  Chat SDK or other time-consuming operations
 * @param <ResultType>
 */
public abstract class NetworkOnlyResource<ResultType> {
    private static final String TAG = "NetworkBoundResource";
    private final MediatorLiveData<Resource<ResultType>> result = new MediatorLiveData<>();

    public NetworkOnlyResource() {
        if(ThreadUtils.isMainThread()) {
            init();
        }else {
            ThreadUtils.runOnUiThread(this::init);
        }
    }

    /**
     * work on main thread
     */
    private void init() {
        result.setValue(Resource.loading(null));
        fetchFromNetwork();
    }

    /**
     * work on main thread
     */
    private void fetchFromNetwork() {
        createCall(new ResultCallBack<LiveData<ResultType>>() {
            @Override
            public void onSuccess(LiveData<ResultType> apiResponse) {
                ThreadUtils.runOnUiThread(() -> {
                    result.addSource(apiResponse, response-> {
                        result.removeSource(apiResponse);
                        if(response != null) {
                            if(response instanceof Result) {
                                int code = ((Result) response).code;
                                if(code != ErrorCode.EM_NO_ERROR) {
                                    fetchFailed(code, null);
                                }
                            }
                            ThreadUtils.getCachedPool().execute(() -> {
                                try {
                                    saveCallResult(processResponse(response));
                                } catch (Exception e) {
                                    EMLog.e(TAG, "save call result failed: " + e.toString());
                                }
                                result.postValue(Resource.success(response));
                            });

                        }else {
                            fetchFailed(ErrorCode.ERR_UNKNOWN, null);
                        }
                    });
                });
            }

            @Override
            public void onError(int error, String errorMsg) {
                ThreadUtils.runOnUiThread(() -> {
                    fetchFailed(error, errorMsg);
                });
            }
        });


    }

    @MainThread
    private void fetchFailed(int code, String message) {
        onFetchFailed();
        result.setValue(Resource.error(code, message,null));
    }

    /**
     * Called to save the result of the API response into the database
     * @param item
     */
    @WorkerThread
    protected void saveCallResult(ResultType item){ }

    /**
     * Process request response
     * @param response
     * @return
     */
    @WorkerThread
    protected ResultType processResponse(ResultType response) {
        return response;
    }

    /**
     * This is designed as a callback mode to facilitate asynchronous operations in this method
     * @return
     */
    @MainThread
    protected abstract void createCall(@NonNull ResultCallBack<LiveData<ResultType>> callBack);

    /**
     * Called when the fetch fails. The child class may want to reset components like rate limiter.
     */
    protected void onFetchFailed() {}

    /**
     * Returns a LiveData object that represents the resource that's implemented
     * in the base class.
     * @return
     */
    public LiveData<Resource<ResultType>> asLiveData() {
        return result;
    }

}
