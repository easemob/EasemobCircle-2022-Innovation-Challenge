package io.agora.contacts.ui;


import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMCircleChannelAttribute;
import com.hyphenate.chat.EMCircleChannelRank;
import com.hyphenate.chat.EMCircleChannelStyle;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.widget.EaseTitleBar;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.adapter.ChannelOptAdapter;
import io.agora.contacts.bean.ChannelOpt;
import io.agora.contacts.databinding.FragmentChannelCreateBinding;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.model.ChannelViewModel;
import io.agora.service.widget.SwitchItemView;

public class CreateChannelBottomFragment extends BaseInitFragment<FragmentChannelCreateBinding> implements BottomSheetChildHelper,
        EaseTitleBar.OnRightClickListener, EaseTitleBar.OnBackPressListener, SwitchItemView.OnCheckedChangeListener {
    //输入框初始值
    private int namePrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    public int mMaxDescNum = 60;

    private ChannelViewModel mViewModel;

    private TextView rightText;
    private CircleServer server;
    private EMCircleChannelStyle style = EMCircleChannelStyle.EMChannelStylePublic;
    private RelativeLayout rightLayout;
    private ChannelOptAdapter mAdapter;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_channel_create;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);

        mBinding.rvChannels.setLayoutManager(new LinearLayoutManager(mContext));
        mAdapter = new ChannelOptAdapter(mContext, R.layout.item_channel_opt);
        List<ChannelOpt> list = new ArrayList<>();
        list.add(new ChannelOpt(R.drawable.circle_channel_icon,"文字频道"));
        list.add(new ChannelOpt(R.drawable.circle_channel_icon,"视频频道"));
        mBinding.rvChannels.setAdapter(mAdapter);
        mAdapter.refresh(list);
    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        rightText = titlebar.getRightText();
        rightText.setVisibility(View.VISIBLE);
        rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.gray_979797));
        rightText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        rightText.setText(getString(io.agora.service.R.string.circle_create));
        rightLayout = titlebar.getRightLayout();
        rightLayout.setEnabled(false);
        titlebar.setLeftLayoutVisibility(View.VISIBLE);
        titlebar.setRightLayoutVisibility(View.VISIBLE);
        titlebar.getRightImage().setVisibility(View.GONE);
        titlebar.setLeftImageResource(io.agora.service.R.drawable.circle_x_delete);
        titlebar.setTitle(getString(R.string.circle_create_channel));
        titlebar.setOnRightClickListener(this);
        titlebar.setOnBackPressListener(this);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mViewModel.createChannelResultLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleChannel>() {
                @Override
                public void onSuccess(@Nullable CircleChannel circleChannel) {
                    ToastUtils.showShort(getString(io.agora.service.R.string.create_channel_success));
                    //跳转到聊天页面
                    if (mAdapter.getChecked() == 0){
                        ARouter.getInstance().build("/chat/ChatActivity")
                                .withString(EaseConstant.EXTRA_CONVERSATION_ID, circleChannel.channelId)
                                .withSerializable(Constants.CHANNEL, circleChannel)
                                .withInt(EaseConstant.EXTRA_CHAT_TYPE, Constants.CHATTYPE_GROUP)
                                .navigation();
                    }

                    hide();
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
                int number = namePrimaryNum + s.length();
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

        mBinding.swiPrivate.setOnCheckedChangeListener(this);
    }

    private void checkCreateChannelButtonStatus() {
        String name = mBinding.edtChannelName.getText().toString().trim();
        String desc = mBinding.edtChannelDesc.getText().toString().trim();
        if (TextUtils.isEmpty(name) && TextUtils.isEmpty(desc)) {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_gray_929497));
            rightLayout.setEnabled(false);
        } else {
            rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_blue_27ae60));
            rightLayout.setEnabled(true);
        }
    }

    @Override
    protected void initData() {
        super.initData();
        server = (CircleServer) getArguments().get(Constants.SERVER);
        mBinding.setVm(mViewModel);
    }

    @Override
    public void onBackPress(View view) {
        back();
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
        attribute.setExt(mAdapter.getChecked() == 1?"video":"text");
        attribute.setRank(EMCircleChannelRank.RANK_2000);
        mViewModel.createChannel(server.serverId, attribute, style);
    }


    @Override
    public void onCheckedChanged(SwitchItemView buttonView, boolean isChecked) {
        if (isChecked) {
            style = EMCircleChannelStyle.EMChannelStylePrivate;
        } else {
            style = EMCircleChannelStyle.EMChannelStylePublic;
        }
    }
}
