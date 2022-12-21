package io.agora.mine.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.jeremyliao.liveeventbus.LiveEventBus;

import io.agora.common.dialog.AlertDialog;
import io.agora.mine.R;
import io.agora.mine.databinding.FragmentMineBinding;
import io.agora.mine.model.MineViewModel;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;


public class MineFragment extends BaseInitFragment<FragmentMineBinding> implements Toolbar.OnMenuItemClickListener {

    private MineViewModel mViewModel;
    private AlertDialog dialog;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_mine;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        AppUserInfoManager.getInstance().getCurrentUserLiveData().observe(this, new Observer<CircleUser>() {
            @Override
            public void onChanged(CircleUser currentUser) {
                if (currentUser != null) {
                    setUserData(currentUser);
                }
            }
        });

        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                CircleUser currentUser = AppUserInfoManager.getInstance().getCurrentUser();
                if (currentUser != null) {
                    setUserData(currentUser);
                }
            }
        });
    }

    private void setUserData(CircleUser currentUser) {
        Glide.with(MineFragment.this)
                .load(currentUser.getAvatar())
                .placeholder(io.agora.service.R.drawable.circle_default_avatar)
                .into(mBinding.ivUser);
        mBinding.tvNickName.setText(currentUser.getNickname());
        mBinding.tvId.setText(getString(io.agora.service.R.string.hx_id) + currentUser.getUsername());
    }


    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(MineViewModel.class);
        mBinding.toolbar.setOnMenuItemClickListener(this);
    }

    @Override
    protected void initData() {
        super.initData();

    }

    @Override
    public boolean onMenuItemClick(MenuItem item) {
        if (item.getItemId() == R.id.action_logout) {
            showLogoutDialog();

        } else if (item.getItemId() == R.id.action_setting) {
            Intent intent = new Intent(mContext, UserInfoSettingActivity.class);
            startActivity(intent);
        }
        return false;
    }

    private void showLogoutDialog() {
//        AlertDialog dialog = new AlertDialog.Builder(mContext)
//                .setTitle(R.string.circle_logout)
//                .setMessage(R.string.circle_logout_message)
//                .setPositiveButton(R.string.circle_logout_exit, new DialogInterface.OnClickListener() {
//                    @Override
//                    public void onClick(DialogInterface dialog, int which) {
//                        logout();
//                        dialog.dismiss();
//                    }
//                })
//                .setNeutralButton(R.string.circle_logout_cancel, new DialogInterface.OnClickListener() {
//                    @Override
//                    public void onClick(DialogInterface dialog, int which) {
//                        dialog.dismiss();
//                    }
//                })
//                .show();

        dialog = new AlertDialog.Builder(mContext)
                .setContentView(R.layout.dialog_logout)
                .setOnClickListener(R.id.tv_exit, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        logout();
                        dialog.dismiss();
                    }
                })
                .setOnClickListener(R.id.tv_cancel, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dialog.dismiss();
                    }
                })
                .setCancelable(true)
                .show();
    }

    private void logout() {
        mViewModel.logout(true).observe(this, booleanResource -> {
            parseResource(booleanResource, new OnResourceParseCallback<Boolean>(true) {
                @Override
                public void onSuccess(@Nullable Boolean data) {
                    ARouter.getInstance().build("/login/LoginActivity").navigation();
                    getActivity().finish();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(message);
                }
            });
        });

    }
}