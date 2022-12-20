package io.agora.service.base;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ConvertUtils;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import io.agora.service.R;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.net.Resource;

/**
 * 底部弹框的基类，提取一些公共方法和管理隐藏显示逻辑
 */
public class BaseBottomSheetFragment extends BottomSheetDialogFragment {
    private int topOffset;
    private BottomSheetBehavior mBehavior;
    public Context mContext;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext=context;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        BottomSheetDialog dialog;
        dialog = new BottomSheetDialog(requireContext(), R.style.transparentBottomSheetStyle);
        return dialog;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initArgument();
        initView();
        initListener();
        initData();
    }

    @Override
    public void onStart() {
        super.onStart();
        if(getDialog() != null) {
            getDialog().setCanceledOnTouchOutside(getCanceledOnTouchOutside());
        }
        ViewGroup.LayoutParams layoutParams = requireView().getLayoutParams();
        layoutParams.height = getHeight();
        mBehavior = BottomSheetBehavior.from((View) requireView().getParent());
        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
    }

    protected <T extends View> T findViewById(@IdRes int id) {
        return requireView().findViewById(id);
    }

    /**
     * Get fragment's height
     */
    private int getHeight() {
        return getResources().getDisplayMetrics().heightPixels - getTopOffset();
    }

    protected int getTopOffset() {
        return topOffset;
    }

    protected void setTopOffset(int topOffset) {
        this.topOffset = topOffset;
    }

    protected BottomSheetBehavior<FrameLayout> getBehavior() {
        return mBehavior;
    }

    public void hide() {
        if (mBehavior != null) {
            mBehavior.setState(BottomSheetBehavior.STATE_HIDDEN);
        }
    }

    protected void initArgument() {
    }

    protected void initData() {
    }

    protected void initListener() {
    }

    protected void initView() {
        // Set default top offset
        topOffset= ConvertUtils.dp2px(56);
    }

    protected boolean getCanceledOnTouchOutside() {
        return true;
    }


    /**
     * Parse Resource<T>
     * @param response
     * @param callback
     * @param <T>
     */
    public <T> void parseResource(Resource<T> response, @NonNull OnResourceParseCallback<T> callback) {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity) mContext).parseResource(response, callback);
        }
    }

    public void showLoading() {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity) mContext).showLoading();
        }
    }

    public void showLoading(String message) {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity) mContext).showLoading(message);
        }
    }

    public void dismissLoading() {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity) mContext).dismissLoading();
        }
    }

}