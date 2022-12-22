package io.agora.contacts.ui;


import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMCircleChannelAttribute;
import com.hyphenate.easeui.widget.EaseTitleBar;

import io.agora.contacts.R;
import io.agora.contacts.databinding.FragmentChannelEditBinding;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;
import io.agora.service.model.ChannelViewModel;

/**
 * 频道编辑页面
 */
public class ChannelEditBottomFragment extends BaseInitFragment<FragmentChannelEditBinding> implements BottomSheetChildHelper
        , EaseTitleBar.OnRightClickListener, EaseTitleBar.OnBackPressListener {
    //输入框初始值
    private int namePrimaryNum = 0;
    private int descPrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    public int mMaxDescNum = 60;
    private TextView rightText;
    private ChannelViewModel mViewModel;
    private CircleChannel channel;
    private RelativeLayout titlebarRightLayout;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_channel_edit;
    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        rightText = titlebar.getRightText();
        rightText.setVisibility(View.VISIBLE);
        rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.gray_979797));
        rightText.setClickable(false);
        rightText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        rightText.setText(getString(io.agora.service.R.string.circle_save));
        titlebarRightLayout = titlebar.getRightLayout();
        titlebar.setLeftLayoutVisibility(View.VISIBLE);
        titlebar.setRightLayoutVisibility(View.VISIBLE);
        titlebar.getRightImage().setVisibility(View.GONE);
        titlebar.setLeftImageResource(io.agora.service.R.drawable.circle_x_delete);
        titlebar.setTitle(getString(R.string.circle_set_channel));
        titlebar.setOnRightClickListener(this);
        titlebar.setOnBackPressListener(this);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mViewModel.updateChannelLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleChannel>() {
                @Override
                public void onSuccess(@Nullable CircleChannel circleChannel) {
                    ToastUtils.showShort(getString(io.agora.service.R.string.update_channel_success));
                    back();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    if(!TextUtils.isEmpty(message)) {
                        ToastUtils.showShort( message);
                    }
                }
            });
        });
        mBinding.setVm(mViewModel);
        initListener();
    }

    private void initListener() {

        mBinding.edtChannelName.addTextChangedListener(new TextWatcher() {
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
                selectionStart = mBinding.edtChannelName.getSelectionStart();
                selectionEnd = mBinding.edtChannelName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtChannelName.setText(s);
                    mBinding.edtChannelName.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateChannelButtonStatus();
            }
        });
        mBinding.edtChannelDesc.addTextChangedListener(new TextWatcher() {
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
                int number = descPrimaryNum + s.length();
                //TextView显示剩余字数
                mBinding.tvDescCount.setText("" + number + "/60");
                selectionStart = mBinding.edtChannelDesc.getSelectionStart();
                selectionEnd = mBinding.edtChannelDesc.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxDescNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtChannelDesc.setText(s);
                    mBinding.edtChannelDesc.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateChannelButtonStatus();
            }
        });
    }

    private void checkCreateChannelButtonStatus() {
        if (rightText != null && titlebarRightLayout != null) {
            String name = mBinding.edtChannelName.getText().toString().trim();
            if (TextUtils.isEmpty(name)) {
                rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_gray_929497));
                titlebarRightLayout.setEnabled(false);
            } else {
                rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_blue_27ae60));
                titlebarRightLayout.setEnabled(true);
            }
        }
    }

    @Override
    protected void initData() {
        super.initData();
        channel = (CircleChannel) getArguments().get(Constants.CHANNEL);
        if (channel != null) {
            mViewModel.channelName.set(channel.name);
            mBinding.edtChannelDesc.setText(channel.desc);
        }
    }

    @Override
    public void onRightClick(View view) {

        String name = mBinding.edtChannelName.getText().toString().trim();
        String desc = mBinding.edtChannelDesc.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            ToastUtils.showShort(getString(io.agora.service.R.string.home_channel_name_is_null));
            return;
        }
        EMCircleChannelAttribute attribute = new EMCircleChannelAttribute();
        attribute.setName(name);
        attribute.setDesc(desc);
        mViewModel.updateChannel(channel, attribute);
    }

    @Override
    public void onBackPress(View view) {
        back();
    }

}
