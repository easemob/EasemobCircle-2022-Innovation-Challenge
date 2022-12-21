package io.agora.contacts.ui;


import static io.agora.service.utils.CircleUtils.sendInviteCustomMessage;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.adapter.ContactListAdapter;
import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.server.ServerMemberNotifyBean;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.model.ServerViewModel;

public class InviteUserToServerBottomFragment extends ContactListFragment implements BottomSheetChildHelper, EaseTitleBar.OnBackPressListener, EaseBaseRecyclerViewAdapter.OnItemSubViewClickListener {

    protected CircleServer server;
    protected ServerViewModel mServerModel;
    protected List<CircleUser> serverMembers = new ArrayList<>();

    @Override
    protected void initConfig() {
        super.initConfig();
        server = (CircleServer) getArguments().getSerializable(Constants.SERVER);
        mServerModel = new ViewModelProvider(this).get(ServerViewModel.class);
        mServerModel.serverMembersLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(@Nullable List<CircleUser> data) {
                    serverMembers.clear();
                    if (data != null) {
                        serverMembers.addAll(data);
                    }
                    setData(mData);
                }
            });
        });
        mServerModel.inviteToServerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(@Nullable String invitee) {
                    ToastUtils.showShort(getString(R.string.circle_invite_success));
                    //刷新ui
                    List<CircleUser> circleUsers = mListAdapter.getData();
                    for (CircleUser circleUser : circleUsers) {
                        if (TextUtils.equals(circleUser.getUsername(), invitee)) {
                            circleUser.inviteState = 1;
                        }
                    }
                    mListAdapter.notifyDataSetChanged();
                    //发送一条私聊消息给对方
                    CustomInfo customInfo = new CustomInfo();
                    customInfo.setServerId( server.serverId);
                    customInfo.setServerName( server.name);
                    customInfo.setServerIcon(server.icon);
                    customInfo.setServerDesc(server.desc);
                    customInfo.setChannelId(server.defaultChannelID);

                    sendInviteCustomMessage(Constants.INVITE_SERVER, customInfo, invitee);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(getString(R.string.circle_invite_failure));
                }
            });
        });
        LiveEventBus.get(Constants.SERVER_MEMBER_LEFT_NOTIFY, ServerMemberNotifyBean.class).observe(getViewLifecycleOwner(), bean -> {
            if (bean != null && TextUtils.equals(bean.getServerId(), server.serverId)) {
                mServerModel.getServerMembers(server.serverId);
            }
        });
        LiveEventBus.get(Constants.SERVER_MEMBER_JOINED_NOTIFY, ServerMemberNotifyBean.class).observe(getViewLifecycleOwner(), bean -> {
            if (bean != null && TextUtils.equals(bean.getServerId(), server.serverId)) {
                mServerModel.getServerMembers(server.serverId);
            }
        });
        mListAdapter.setOnItemSubViewClickListener(this);
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mBinding.sideBarContact.setVisibility(View.GONE);
    }

    @Override
    protected void initData() {
        super.initData();
        ((ContactListAdapter) mListAdapter).setDisplayMode(ContactListAdapter.DisplayMode.SHOW_INVITE);
        if (server != null) {
            mServerModel.getServerMembers(server.serverId);
        }
    }

    @Override
    protected synchronized void setData(List<CircleUser> targetUsers) {
        if (!CollectionUtils.isEmpty(serverMembers)) {
            for (CircleUser serverMember : serverMembers) {
                for (int i = 0; i < targetUsers.size(); i++) {
                    CircleUser circleUser = targetUsers.get(i);
                    if (circleUser.getUsername().equals(serverMember.getUsername())) {
                        targetUsers.remove(circleUser);
                        i--;
                    }
                }
            }
        }
        mListAdapter.setData(targetUsers);
    }

    @Override
    public void onContainerTitleBarInitialize(EaseTitleBar titlebar) {
        titlebar.getLeftLayout().setVisibility(View.VISIBLE);
        titlebar.setTitle(getString(R.string.contacts_invite_friend));
        titlebar.setOnBackPressListener(this);
        titlebar.setLeftImageResource(io.agora.service.R.drawable.back_arrow_bold);
    }

    protected void checkView(String content) {
        if (TextUtils.isEmpty(content)) {
            mBinding.srlContactRefresh.setEnabled(true);
        } else {
            mBinding.srlContactRefresh.setEnabled(false);
        }
    }

    @Override
    public void onBackPress(View view) {
        back();
    }

    @Override
    public void onItemSubViewClick(View view, int position) {
        if (view.getId() == R.id.btn_invite) {
            List<CircleUser> circleUsers = mListAdapter.getData();
            //邀请好友加入server
            mServerModel.inviteToServer(server.serverId, circleUsers.get(position).getUsername(), getString(R.string.circle_invite_to_server_welcome, server.name));
        }
    }
}
