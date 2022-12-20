package io.agora.contacts.ui;


import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.Group;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.example.zhouwei.library.CustomPopWindow;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMCircleUserRole;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.widget.EaseRecyclerView;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.adapter.ContactListAdapter;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.model.ChannelViewModel;
import io.agora.service.model.ServerViewModel;
import io.agora.service.net.Resource;
import io.agora.service.net.Status;

public class ThreadSettingBottomFragment extends ContactListFragment implements BottomSheetChildHelper, View.OnClickListener {
    private ConstraintLayout headView;
    private ChannelViewModel mChannelViewModel;
    private ServerViewModel mServerViewModel;
    private ThreadData threadData;
    private CustomPopWindow mCustomPopWindow;
    private TextView tvEditThread;
    private Group clsGroup;
    private EMChatThread thread;
    private EMCircleUserRole selfRoleInServer = EMCircleUserRole.USER;

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        Bundle arguments = getArguments();
        threadData = (ThreadData) arguments.getSerializable(Constants.THREAD_DATA);

        mBinding.etSearch.setVisibility(View.GONE);
        headView = (ConstraintLayout) LayoutInflater.from(mContext).inflate(R.layout.layout_thread_setting_head, (ViewGroup) mBinding.getRoot(), false);
        tvEditThread = headView.findViewById(R.id.tv_edit_thread);
        clsGroup = headView.findViewById(R.id.csl_group);
        ((EaseRecyclerView) mRecyclerView).addHeaderView(headView);
        mRecyclerView.setNestedScrollingEnabled(false);
        mBinding.sideBarContact.setVisibility(View.GONE);

    }

    @Override
    protected void initConfig() {
        mChannelViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mServerViewModel = new ViewModelProvider(this).get(ServerViewModel.class);
        mChannelViewModel.presencesObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<EMPresence>>() {
                @Override
                public void onSuccess(@Nullable List<EMPresence> data) {
                    setData(mData);
//                    checkView(mBinding.etSearch.getText().toString().trim());
                }
            });
        });
        mChannelViewModel.deleteThreadResultLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(@Nullable Boolean data) {
                    if (data) {
                        ToastUtils.showShort(getString(R.string.delete_thread_success));
                        hide();
                    } else {
                        ToastUtils.showShort(getString(R.string.delete_thread_failure));
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
        mChannelViewModel.threadMembersLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<String>>() {
                @Override
                public void onSuccess(@Nullable List<String> data) {
                    if (data != null) {
                        List<CircleUser> users = CircleUser.parseListIds(data);
                        for (CircleUser user : users) {
                            user.roleID = EMCircleUserRole.USER.getRoleId();
                        }
                        mData = users;
                        setData(mData);
                        mChannelViewModel.subscribePresencesWithUsers(users, Constants.PRESENCE_SUBSCRIBE_EXPIRY);
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

        mChannelViewModel.leaveThreadResultLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {

                @Override
                public void onSuccess(@Nullable Boolean data) {
                    if (data) {
                        ToastUtils.showShort(getString(R.string.leave_thread_success));
                        hide();
                    } else {
                        ToastUtils.showShort(getString(R.string.leave_thread_failure));
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
        mChannelViewModel.getThreadLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<EMChatThread>() {
                @Override
                public void onSuccess(@Nullable EMChatThread data) {
                    thread = data;
                    if (data != null) {
                        if (TextUtils.equals(AppUserInfoManager.getInstance().getCurrentUserName(), data.getOwner())) {
                            clsGroup.setVisibility(View.VISIBLE);
                        } else {
                            clsGroup.setVisibility(View.GONE);
                        }
                    }
                }
            });
        });
        AppUserInfoManager.getInstance().getSelfServerRoleMapLiveData().observe(getViewLifecycleOwner(), serverRoleMap -> {
            if (serverRoleMap != null && threadData != null) {
                Integer roleId = serverRoleMap.get(threadData.getServerId());
                if (roleId != null) {
                    if (roleId.intValue() == EMCircleUserRole.USER.getRoleId()) {
                        selfRoleInServer = EMCircleUserRole.USER;
                    } else if (roleId.intValue() == EMCircleUserRole.MODERATOR.getRoleId()) {
                        selfRoleInServer=EMCircleUserRole.MODERATOR;
                    } else if (roleId.intValue() == EMCircleUserRole.OWNER.getRoleId()) {
                        selfRoleInServer=EMCircleUserRole.OWNER;
                    }
                }
            }
        });

        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                mListAdapter.notifyDataSetChanged();
            }
        });
        LiveEventBus.get(Constants.PRESENCES_CHANGED).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                setData(mData);
            }
        });
        tvEditThread.setOnClickListener(this);
        mListAdapter.setOnItemClickListener(this);
    }

    @Override
    protected void initData() {
        mRecyclerView.setAdapter(concatAdapter);
        ((ContactListAdapter) mListAdapter).setDisplayMode(ContactListAdapter.DisplayMode.SHOW_NONE);
        ((ContactListAdapter) mListAdapter).setShowStatusText(false);
        mChannelViewModel.getThreadMembers(threadData.getThreadId());
        mChannelViewModel.getChannlThread(threadData.getThreadId());
    }

    protected void checkView(String content) {
        super.checkView(content);
        mBinding.sideBarContact.setVisibility(View.GONE);
        if (!TextUtils.isEmpty(content)) {
            ((EaseRecyclerView) mRecyclerView).removeHeaderViews();
        }
    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        titlebar.setTitle(getString(R.string.circle_thread_setting));
        titlebar.setLeftLayoutVisibility(View.VISIBLE);
        titlebar.getRightImage().setVisibility(View.VISIBLE);
        titlebar.setRightImageResource(io.agora.service.R.drawable.circle_more_vertical);
        titlebar.setLeftImageResource(io.agora.service.R.drawable.circle_x_delete);
        titlebar.setOnRightClickListener(new EaseTitleBar.OnRightClickListener() {
            @Override
            public void onRightClick(View view) {
                showPopWindow(titlebar.getRightText());
            }
        });
    }

    private void showPopWindow(TextView locationView) {

        View contentView = LayoutInflater.from(mContext).inflate(R.layout.thread_setting_menu, (ViewGroup) locationView.getParent(), false);
        //处理popWindow 显示内容
        handleLogic(contentView);

        //显示PopupWindow
        mCustomPopWindow = new CustomPopWindow.PopupWindowBuilder(mContext)
                .setView(contentView)
                .size(ConvertUtils.dp2px(104), ViewGroup.LayoutParams.WRAP_CONTENT)
                .setFocusable(true)
                .setOutsideTouchable(true)
                .create()
                .showAsDropDown(locationView, ConvertUtils.dp2px(-70), 120);

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
                if (id == R.id.tv_delete_thread) {
                    mChannelViewModel.deleteThread(threadData);
                } else if (id == R.id.tv_exit_thread) {
                    mChannelViewModel.leaveThread(threadData);
                }
            }
        };
        TextView tvDelete = contentView.findViewById(R.id.tv_delete_thread);
        TextView tvExit = contentView.findViewById(R.id.tv_exit_thread);
        View line = contentView.findViewById(R.id.line);
        tvDelete.setOnClickListener(listener);
        tvExit.setOnClickListener(listener);
        if (thread != null) {
            if (selfRoleInServer==EMCircleUserRole.OWNER) {
                tvDelete.setVisibility(View.VISIBLE);
                line.setVisibility(View.VISIBLE);
            } else {
                tvDelete.setVisibility(View.GONE);
                line.setVisibility(View.GONE);
            }
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.tv_edit_thread) {
            //去编辑子区页面
            ThreadEditBottomFragment serverEditBottomFragment = new ThreadEditBottomFragment();
            Bundle bundle = new Bundle();
            bundle.putSerializable(Constants.THREAD_DATA, threadData);
            serverEditBottomFragment.setArguments(bundle);
            startFragment(serverEditBottomFragment, serverEditBottomFragment.getClass().getSimpleName());
        }
    }

    @Override
    public void onItemClick(View view, int position) {

        List<CircleUser> datas = mListAdapter.getData();
        if (datas != null) {
            CircleUser circleUser = datas.get(position - 1);
            if (!TextUtils.equals(circleUser.getUsername(), AppUserInfoManager.getInstance().getCurrentUserName())) {
                ARouter.getInstance().build("/chat/ChatActivity")
                        .withString(EaseConstant.EXTRA_CONVERSATION_ID, circleUser.getUsername())
                        .withInt(EaseConstant.EXTRA_CHAT_TYPE, Constants.CHATTYPE_SINGLE)
                        .navigation();
            }
        }
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
