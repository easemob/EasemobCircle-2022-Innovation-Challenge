package io.agora.contacts.ui;


import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.easeui.utils.EaseCompat;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.tbruyelle.rxpermissions2.RxPermissions;

import java.util.List;

import io.agora.common.dialog.AlertDialog;
import io.agora.contacts.R;
import io.agora.contacts.databinding.FragmentServerEditBinding;
import io.agora.contacts.widget.TagView;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.model.ServerViewModel;
import io.agora.service.utils.UriFormatUtils;

public class ServerEditBottomFragment extends BaseInitFragment<FragmentServerEditBinding> implements BottomSheetChildHelper,
        EaseTitleBar.OnRightClickListener, EaseTitleBar.OnBackPressListener, View.OnClickListener {
    private static final int REQUEST_CODE_LOCAL = 1;
    private String imagePath;
    //输入框初始值
    private int namePrimaryNum = 0;
    //输入框最大值
    public int mMaxNameNum = 16;
    //输入框初始值
    private int descPrimaryNum = 0;
    //输入框最大值
    public int mMaxDescNum = 120;
    private ServerViewModel mViewModel;

    private TextView rightText;
    private AlertDialog alertDialog;
    private EditText edtTag;
    private CircleServer server;
    private RxPermissions rxPermissions;
    private RelativeLayout titlebarRightLayout;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_server_edit;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);

    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        BottomSheetChildHelper.super.onContainerTitleBarInitialize(titlebar);
        rightText = titlebar.getRightText();
        rightText.setVisibility(View.VISIBLE);
        rightText.setTextColor(ContextCompat.getColor(mContext, io.agora.service.R.color.color_blue_27ae60));
        rightText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        rightText.setText(getString(io.agora.service.R.string.circle_save));
        titlebarRightLayout = titlebar.getRightLayout();
        titlebar.setTitle(getString(R.string.circle_set_server));
        titlebar.setLeftLayoutVisibility(View.VISIBLE);
        titlebar.setRightLayoutVisibility(View.VISIBLE);
        titlebar.getRightImage().setVisibility(View.GONE);
        titlebar.setOnRightClickListener(this);
        titlebar.setOnBackPressListener(this);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ServerViewModel.class);
        mViewModel.updateServerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer circleServer) {
                    //隐藏进度条
                    dismissLoading();
                    ToastUtils.showShort(getString(io.agora.service.R.string.home_update_server_success));
                    hide();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    dismissLoading();
                    if (!TextUtils.isEmpty(message)) {
                        ToastUtils.showShort(message);
                    }
                    hide();
                }
            });
        });
        mViewModel.addServerTagsLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleServer.Tag>>() {
                @Override
                public void onSuccess(@Nullable List<CircleServer.Tag> allTags) {
                    //插入容器
                    insertContainer(allTags);
                    if (alertDialog != null) {
                        alertDialog.dismiss();
                    }
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
        mViewModel.removeServerTagLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer circleServer) {
                    server = circleServer;
                    //插入容器
                    insertContainer(circleServer.tags);
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
        mBinding.setVm(mViewModel);
        initListener();
    }

    private void initListener() {

        mBinding.edtServerName.addTextChangedListener(new TextWatcher() {
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
                selectionStart = mBinding.edtServerName.getSelectionStart();
                selectionEnd = mBinding.edtServerName.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxNameNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtServerName.setText(s);
                    mBinding.edtServerName.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateServerButtonStatus();
            }
        });
        mBinding.edtServerDesc.addTextChangedListener(new TextWatcher() {
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
                mBinding.tvDescCount.setText("" + number + "/120");
                selectionStart = mBinding.edtServerDesc.getSelectionStart();
                selectionEnd = mBinding.edtServerDesc.getSelectionEnd();
                //判断大于最大值
                if (wordNum.length() > mMaxDescNum) {
                    //删除多余输入的字（不会显示出来）
                    s.delete(selectionStart - 1, selectionEnd);
                    int tempSelection = selectionEnd;
                    mBinding.edtServerDesc.setText(s);
                    mBinding.edtServerDesc.setSelection(tempSelection);//设置光标在最后
                }
                checkCreateServerButtonStatus();
            }
        });
        mBinding.cslServerIcon.setOnClickListener(this);

        mBinding.ivAddTag.setOnClickListener(this);

    }

    private void checkCreateServerButtonStatus() {
        if (rightText != null && titlebarRightLayout != null) {
            String name = mBinding.edtServerName.getText().toString().trim();
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
        rxPermissions = new RxPermissions(this);
        server = (CircleServer) getArguments().get(Constants.SERVER);
        if (server != null) {
            Glide.with(this).load(server.icon).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(mBinding.ivAvater);
            String name = server.name;
            if (name != null) {
                mViewModel.serverName.set(name);
            }
            String desc = server.desc;
            if (desc != null) {
                mBinding.edtServerDesc.setText(desc);
            }

            List<CircleServer.Tag> tags = server.tags;
            insertContainer(tags);
        }
    }

    @Override
    public void onBackPress(View view) {
        back();
    }

    @Override
    public void onRightClick(View view) {

        String name = mBinding.edtServerName.getText().toString().trim();
        String desc = mBinding.edtServerDesc.getText().toString().trim();
        if (TextUtils.isEmpty(name)) {
            ToastUtils.showShort(getString(io.agora.service.R.string.home_server_name_is_null));
            return;
        }
        if (TextUtils.isEmpty(imagePath)) {
            imagePath = server.icon;
        }
        showLoading(null);
        mViewModel.updateServer(server, imagePath, name, desc);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.csl_server_icon) {
            //去相册选择
            //申请权限
            rxPermissions
                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE)
                    .subscribe(granted -> {
                        if (granted) {
                            // All requested permissions are granted
                            //去相册选择
                            EaseCompat.openImage(this, REQUEST_CODE_LOCAL);
                        }
                    });

        } else if (v.getId() == R.id.iv_add_tag) {
            int childCount = mBinding.llContainerTags.getChildCount();
            if (childCount > 10) {
                ToastUtils.showShort(getString(io.agora.service.R.string.circle_tags_to_max, "10"));
                return;
            }
            //添加标签弹框
            alertDialog = new AlertDialog.Builder(mContext)
                    .setContentView(R.layout.dialog_add_tag)
                    .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                    .setOnClickListener(R.id.tv_cancel, new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            alertDialog.dismiss();
                        }
                    })
                    .setOnClickListener(R.id.tv_confirm, new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            String tag = edtTag.getText().toString().trim();
                            if (!TextUtils.isEmpty(tag) && server != null) {
                                //更新到服务器
                                mViewModel.addTagToServer(server, tag);
                            }
                        }
                    })
                    .show();
            edtTag = alertDialog.getViewById(R.id.edt_tag);
            TextView tvCount = alertDialog.getViewById(R.id.tv_tag_count);

            edtTag.addTextChangedListener(new TextWatcher() {
                //记录输入的字数
                private CharSequence wordNum;
                private int selectionStart;
                private int selectionEnd;
                private int tagPrimaryNum;

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
                    int number = tagPrimaryNum + s.length();
                    //TextView显示剩余字数
                    tvCount.setText("" + number + "/16");
                    selectionStart = edtTag.getSelectionStart();
                    selectionEnd = edtTag.getSelectionEnd();
                    //判断大于最大值
                    if (wordNum.length() > mMaxNameNum) {
                        //删除多余输入的字（不会显示出来）
                        s.delete(selectionStart - 1, selectionEnd);
                        int tempSelection = selectionEnd;
                        edtTag.setText(s);
                        edtTag.setSelection(tempSelection);//设置光标在最后
                    }
                }
            });
        }
    }

    private void insertContainer(List<CircleServer.Tag> tags) {
        mBinding.llContainerTags.removeAllViews();
        if (CollectionUtils.isEmpty(tags)) {
            return;
        }
        for (CircleServer.Tag tag : tags) {
            TagView tagView = new TagView(mContext);
            tagView.setTagData(tag);
            mBinding.llContainerTags.addView(tagView);
            tagView.setonDeleteClickListener(new TagView.OnDeleteClickListener() {
                @Override
                public void onClick(View view) {
                    mViewModel.removeTagFromServer(server, ((TagView) view).getData());
                }
            });
        }
        mBinding.tvTagsCount.setText(mBinding.llContainerTags.getChildCount() + "/10");
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_LOCAL) { // send local image
                onActivityResultForLocalPhotos(data);
            }
        }
    }

    /**
     * 选择本地图片处理结果
     *
     * @param data
     */
    private void onActivityResultForLocalPhotos(@Nullable Intent data) {
        if (data != null) {
            try {
                Uri selectedImage = data.getData(); //获取系统返回的照片的Uri
                imagePath = UriFormatUtils.getPathByUri4kitkat(mContext, selectedImage);
                Glide.with(this).load(imagePath).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(mBinding.ivAvater);
            } catch (Exception e) {
                imagePath = null;
                e.printStackTrace();
            }
        }
    }
}
