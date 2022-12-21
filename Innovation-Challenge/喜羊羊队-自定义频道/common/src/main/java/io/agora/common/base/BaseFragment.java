package io.agora.common.base;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;

import com.blankj.utilcode.util.LogUtils;

public abstract class BaseFragment<T extends ViewDataBinding> extends Fragment {
    protected String TAG=getClass().getSimpleName();
    protected T mBinding;
    protected Context mContext;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext =  context;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        mBinding = DataBindingUtil.inflate(inflater, getResLayoutId(), container, false);
        if(mBinding==null) {
            return inflater.inflate(getResLayoutId(),container,false);
        }
        return mBinding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if(mBinding!=null) {
            mBinding.setLifecycleOwner(getViewLifecycleOwner());
        }
        initView(savedInstanceState);
        initConfig();
        initData();
    }
    /**
     * 必要的view初始化
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


    protected abstract int getResLayoutId();

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(mBinding!=null) {
            mBinding.unbind();
        }
    }
}
