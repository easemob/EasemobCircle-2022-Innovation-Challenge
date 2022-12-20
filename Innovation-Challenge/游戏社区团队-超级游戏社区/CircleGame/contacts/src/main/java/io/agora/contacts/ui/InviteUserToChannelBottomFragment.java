package io.agora.contacts.ui;


import static io.agora.service.utils.CircleUtils.sendInviteCustomMessage;

import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.adapter.ContactListAdapter;
import io.agora.contacts.model.ContactsListViewModel;
import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.channel.ChannelEventNotifyBean;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.model.ChannelViewModel;

public class InviteUserToChannelBottomFragment extends InviteUserToServerBottomFragment {
    private ChannelViewModel mChannelViewModel;
    protected CircleChannel channel;
    private List<CircleUser> channelMembers= new ArrayList<>();

    @Override
    protected void initConfig() {
        channel = (CircleChannel) getArguments().getSerializable(Constants.CHANNEL);
        mChannelViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mContactsListViewModel = new ViewModelProvider(this).get(ContactsListViewModel.class);
        mChannelViewModel.channelMembersLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(@Nullable List<CircleUser> data) {
                    channelMembers.clear();
                    if (data != null) {
                        channelMembers.addAll(data);
                    }
                    setData(mData);
                }
            });
        });
        mChannelViewModel.inviteUserToChannelLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(@Nullable String invitee) {
                    //刷新ui
                    List<CircleUser> circleUsers = mListAdapter.getData();
                    for (CircleUser circleUser : circleUsers) {
                        if (TextUtils.equals(circleUser.getUsername(), invitee)) {
                            circleUser.inviteState = 1;
                        }
                    }
                    mListAdapter.notifyDataSetChanged();
                    //查询server详情
                    CircleServer server = AppUserInfoManager.getInstance().getUserJoinedSevers().get(channel.serverId);
                    if (server != null) {
                        //发送一条私聊消息给对方
                        CustomInfo customInfo = new CustomInfo();
                        customInfo.setServerId( server.serverId);
                        customInfo.setServerName( server.name);
                        customInfo.setServerIcon(server.icon);
                        customInfo.setServerDesc(server.desc);
                        customInfo.setChannelId(channel.channelId);
                        customInfo.setChannelName(channel.name);

                        sendInviteCustomMessage(Constants.INVITE_CHANNEL, customInfo, invitee);
                    }
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(message);
                }
            });
        });
        mContactsListViewModel.getContactObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(@Nullable List<CircleUser> contacts) {
                    mData.clear();
                    if (!CollectionUtils.isEmpty(contacts)) {
                        mData.addAll(contacts);
                    }
                    setData(mData);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(message);
                }
            });
        });
        LiveEventBus.get(Constants.MEMBER_LEFT_CHANNEL_NOTIFY, ChannelEventNotifyBean.class).observe(getViewLifecycleOwner(), channelEventNotifyBean -> {
            if (channelEventNotifyBean != null && TextUtils.equals(channelEventNotifyBean.getChannelId(), channel.channelId)) {
                mChannelViewModel.getChannelMembers(channel.serverId, channel.channelId);
            }
        });
        LiveEventBus.get(Constants.MEMBER_JOINED_CHANNEL_NOTIFY, ChannelEventNotifyBean.class).observe(getViewLifecycleOwner(), channelEventNotifyBean -> {
            if (channelEventNotifyBean != null && TextUtils.equals(channelEventNotifyBean.getChannelId(), channel.channelId)) {
                mChannelViewModel.getChannelMembers(channel.serverId, channel.channelId);
            }
        });
        mListAdapter.setOnUserPresenceListener(this);
        mListAdapter.setOnItemSubViewClickListener(this);
        initListener();
    }

    @Override
    protected void initData() {
        mRecyclerView.setAdapter(concatAdapter);
        ((ContactListAdapter) mListAdapter).setDisplayMode(ContactListAdapter.DisplayMode.SHOW_INVITE);
        mContactsListViewModel.loadContactList(true);
        mChannelViewModel.getChannelMembers(channel.serverId, channel.channelId);

    }

    protected void setData(List<CircleUser> targetUsers) {
        if (!CollectionUtils.isEmpty(channelMembers)) {
            for (CircleUser channelMember : channelMembers) {
                for (int i = 0; i < targetUsers.size(); i++) {
                    CircleUser circleUser = targetUsers.get(i);
                    if (circleUser.getUsername().equals(channelMember.getUsername())) {
                        targetUsers.remove(circleUser);
                        i--;
                    }
                }
            }
        }
        mListAdapter.setData(targetUsers);
    }

    @Override
    public void onItemSubViewClick(View view, int position) {
        if (view.getId() == R.id.btn_invite) {
            List<CircleUser> circleUsers = mListAdapter.getData();
            //邀请好友加入channel
            mChannelViewModel.inviteUserToChannel(channel.serverId, channel.channelId, circleUsers.get(position).getUsername(), getString(R.string.circle_invite_to_channel_welcome, channel.name));
        }
    }
}
