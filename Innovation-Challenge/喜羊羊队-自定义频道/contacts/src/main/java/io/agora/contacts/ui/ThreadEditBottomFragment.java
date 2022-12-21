package io.agora.contacts.ui;


import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.easeui.widget.EaseTitleBar;

import io.agora.contacts.R;
import io.agora.contacts.databinding.FragmentThreadEditBinding;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.global.Constants;
import io.agora.service.model.ChannelViewModel;
import io.agora.service.net.Resource;
import io.agora.service.net.Status;

/**
 * 子区编辑页面
 */
public class ThreadEditBottomFragment extends BaseInitFragment<FragmentThreadEditBinding> implements BottomSheetChildHelper
        , EaseTitleBar.OnRightClickListener, EaseTitleBar.OnBackPressListener {
    //输入框初始值
    private int namePrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    private TextView rightText;
    private ChannelViewModel mViewModel;
    private ThreadData threadData;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_thread_edit;
    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        rightText = titlebar.getRightText();
        rightText.setVisibility(View.VISIBLE);
        rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.gray_979797));
        rightText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        rightText.setText(getString(io.agora.service.R.string.circle_save));
        titlebar.setLeftLayoutVisibility(View.VISIBLE);
        titlebar.setRightLayoutVisibility(View.VISIBLE);
        titlebar.getRightImage().setVisibility(View.GONE);
        titlebar.setLeftImageResource(io.agora.service.R.drawable.circle_x_delete);
        titlebar.setTitle(getString(R.string.circle_edit_thread));
        titlebar.setOnRightClickListener(this);
        titlebar.setOnBackPressListener(this);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mViewModel.updateChatThreadNameLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(@Nullable Boolean bool) {
                    ToastUtils.showShort(getString(io.agora.service.R.string.rename_thread_name_success));
                    back();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    if (!TextUtils.isEmpty(message)) {
                        ToastUtils.showShort(message);
                    }
                }
            });
        });
        initListener();
    }

    private void initListener() {

        mBinding.edtThreadName.addTextChangedListener(new TextWatcher() {
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
                selectionStart = mBinding.edtThreadName.getSelectionStart();
                selectionEnd = mBinding.edtThreadName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtThreadName.setText(s);
                    mBinding.edtThreadName.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateChannelButtonStatus();
            }
        });

    }

    private void checkCreateChannelButtonStatus() {
        String name = mBinding.edtThreadName.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_gray_929497));
        } else {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_blue_27ae60));
        }
    }

    @Override
    protected void initData() {
        super.initData();
        threadData = (ThreadData) getArguments().getSerializable(Constants.THREAD_DATA);
        mBinding.setVm(mViewModel);
    }

    @Override
    public void onRightClick(View view) {

        String name = mBinding.edtThreadName.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            ToastUtils.showShort(getString(io.agora.service.R.string.circle_thread_name_is_null));
            return;
        }
        mViewModel.updateChatThreadName(threadData, name);
    }

    @Override
    public void onBackPress(View view) {
        back();
    }

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
//                ToastUtils.showShort(response.getMessage(mContext));
            }
            callback.onError(response.errorCode, response.getMessage(mContext));
        } else if (response.status == Status.LOADING) {
            callback.onLoading(response.data);
        }
    }

}
