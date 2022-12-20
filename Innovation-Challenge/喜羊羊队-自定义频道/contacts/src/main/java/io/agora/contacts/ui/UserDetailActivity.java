package io.agora.contacts.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.example.zhouwei.library.CustomPopWindow;
import com.hyphenate.easeui.constants.EaseConstant;

import java.util.List;

import io.agora.common.dialog.AlertDialog;
import io.agora.contacts.R;
import io.agora.contacts.databinding.ActivityUserDetailBinding;
import io.agora.contacts.model.ContactsViewModel;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;

@Route(path = "/contacts/UserDetailActivity")
public class UserDetailActivity extends BaseInitActivity<ActivityUserDetailBinding> implements View.OnClickListener {

    private String username;
    private CircleUser circleUser;
    private AlertDialog dialog;
    private ContactsViewModel viewModel;
    private CustomPopWindow mCustomPopWindow;

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_user_detail;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        username = getIntent().getStringExtra(Constants.USERNAME);

        mBinding.btnAddFriend.setVisibility(View.GONE);
        mBinding.ivMore.setVisibility(View.GONE);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        viewModel = new ViewModelProvider(this).get(ContactsViewModel.class);
        viewModel.deleteContactLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(@Nullable Boolean data) {
                    ToastUtils.showShort(getString(R.string.delete_friend_success));
                    finish();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(getString(R.string.delete_friend_failure));
                }
            });
        });
        viewModel.addContactLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(@Nullable Boolean data) {
                    mBinding.btnAddFriend.setEnabled(false);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                }
            });
        });
        viewModel.getContactsLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(@Nullable List<CircleUser> users) {
                    if (!CollectionUtils.isEmpty(users)) {
                        checkUserIsFriend(users);
                    }

                }
            });
        });
        viewModel.getUserInfoLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleUser>() {
                @Override
                public void onSuccess(@Nullable CircleUser data) {
                    circleUser = data;
                    setUserData(circleUser);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                }
            });
        });
        mBinding.btnAddFriend.setOnClickListener(this);
        mBinding.btnToChat.setOnClickListener(this);

        mBinding.ivMore.setOnClickListener(this);
        mBinding.ivBack.setOnClickListener(this);

    }

    private void setUserData(CircleUser currentUser) {
        Glide.with(this)
                .load(currentUser.getAvatar())
                .placeholder(io.agora.service.R.drawable.circle_default_avatar)
                .into(mBinding.ivUser);
        mBinding.tvNickName.setText(currentUser.getNickname());
        mBinding.tvId.setText(getString(io.agora.service.R.string.hx_id) + currentUser.getUsername());
    }

    private void checkUserIsFriend(List<CircleUser> users) {
        boolean isFriend = false;
        for (int i = 0; i < users.size(); i++) {
            CircleUser user = users.get(i);
            if (TextUtils.equals(user.getUsername(), username)) {
                isFriend = true;
            }
        }
        if (isFriend) {
            mBinding.btnAddFriend.setVisibility(View.GONE);
            mBinding.btnToChat.setVisibility(View.VISIBLE);
            mBinding.ivMore.setVisibility(View.VISIBLE);
        } else {
            mBinding.btnAddFriend.setVisibility(View.VISIBLE);
            mBinding.ivMore.setVisibility(View.GONE);
            mBinding.btnToChat.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected void initData() {
        super.initData();
        circleUser = AppUserInfoManager.getInstance().getUserInfobyId(username);
        viewModel.getContactsFromServer();
        viewModel.getUserInfoById(username);
    }


    private void showDeleteDialog() {
        String nickName = username;
        if (circleUser != null) {
            nickName = circleUser.getNickname();
        }
        dialog = new AlertDialog.Builder(this)
                .setContentView(R.layout.dialog_delete_friend)
                .setText(R.id.tv_content, getString(R.string.circle_delete_friend_content, nickName))
                .setOnClickListener(R.id.tv_confirm, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        viewModel.deleteFriend(username);
                        dialog.dismiss();
                    }
                })
                .setOnClickListener(R.id.tv_cancel, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dialog.dismiss();
                    }
                })
                .show();

    }

    private void showPopWindow(View locationView) {

        View contentView = LayoutInflater.from(this).inflate(R.layout.delete_friend_menu, (ViewGroup) getWindow().getDecorView(), false);
        //处理popWindow 显示内容
        handleLogic(contentView);

        //显示PopupWindow
        mCustomPopWindow = new CustomPopWindow.PopupWindowBuilder(this)
                .setView(contentView)
                .size(ConvertUtils.dp2px(114), ConvertUtils.dp2px(36))
                .setFocusable(true)
                .setOutsideTouchable(true)
                .create()
                .showAsDropDown(locationView, ConvertUtils.dp2px(-70), 40);

    }

    /**
     * 处理弹出显示内容、点击事件等逻辑
     *
     * @param contentView
     */
    private void handleLogic(View contentView) {
        View.OnClickListener listener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCustomPopWindow != null) {
                    mCustomPopWindow.dissmiss();
                }
                int id = v.getId();
                if (id == R.id.tv_delete_friend) {
                    showDeleteDialog();
                }
            }
        };
        contentView.findViewById(R.id.tv_delete_friend).setOnClickListener(listener);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_add_friend) {
            //加好友
            viewModel.addFriend(username);
        } else if (id == R.id.btn_to_chat) {
            //去聊天
            //跳转到聊天页面
            ARouter.getInstance().build("/chat/ChatActivity")
                    .withString(EaseConstant.EXTRA_CONVERSATION_ID, username)
                    .withInt(EaseConstant.EXTRA_CHAT_TYPE, Constants.CHATTYPE_SINGLE)
                    .navigation();
        } else if (id == R.id.iv_more) {
            //弹框 删除好友
            showPopWindow(v);
        } else if (id == R.id.iv_back) {
            finish();
        }
    }

}