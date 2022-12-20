package io.agora.common.base;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;

import com.blankj.utilcode.util.LogUtils;


/**
 * As a basic activity, place some public methods
 */
public abstract class BaseActivity<T extends ViewDataBinding> extends AppCompatActivity {
    protected String TAG=getClass().getSimpleName();
    protected T mBinding;
    protected Context mContext;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mBinding=bindView(getResLayoutId());
        mContext =getApplicationContext();
        if(mBinding!=null) {
            mBinding.setLifecycleOwner(this);
        }
        initView(savedInstanceState);
        initConfig();
        initData();
    }

    /**
     * 必要的view初始化
     * @param savedInstanceState
     */
    protected void  initView(Bundle savedInstanceState) {
        LogUtils.d(TAG+" 初始化 initView");
    }

    /**
     * view初始化后的必要配置
     */
    protected void  initConfig() {
        LogUtils.d(TAG+" 初始化 initConfig");
    }

    /**
     * view初始化后的必要数据
     */
    protected void  initData() {
        LogUtils.d(TAG+" 初始化 initData");
    }

    protected abstract @LayoutRes int getResLayoutId();

    protected T bindView(@LayoutRes int layout){
        return DataBindingUtil.setContentView(this,layout);
    }
    
    protected T bindView(View view){
       return DataBindingUtil.bind(view);
    }

    /**
     * hide keyboard
     */
    public void hideKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null && getWindow().getAttributes().softInputMode != WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN) {
            if (getCurrentFocus() != null) {
                imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
            }
        }
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(mBinding!=null) {
            mBinding.unbind();
        }
    }
}
