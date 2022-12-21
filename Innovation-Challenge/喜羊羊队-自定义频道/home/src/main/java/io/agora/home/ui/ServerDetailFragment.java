package io.agora.home.ui;

import static com.hyphenate.chat.EMCircleChannelStyle.EMChannelStylePrivate;
import static com.hyphenate.chat.EMCircleChannelStyle.EMChannelStylePublic;
import static com.hyphenate.easeui.constants.EaseConstant.CONVERSATION_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_MSG_ID;
import static com.hyphenate.easeui.constants.EaseConstant.SERVER_ID;
import static io.agora.service.utils.CircleUtils.sendInviteCustomMessage;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.alibaba.android.arouter.utils.TextUtils;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ThreadUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMCircleChannel;
import com.hyphenate.chat.EMCircleServerEvent;
import com.hyphenate.chat.EMCircleUserRole;
import com.hyphenate.chat.EMClient;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.easeui.utils.ShowMode;
import com.jeremyliao.liveeventbus.LiveEventBus;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshListener;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.common.base.BaseAdapter;
import io.agora.common.dialog.AlertDialog;
import io.agora.home.R;
import io.agora.home.adapter.ChannelListAdapter;
import io.agora.home.bean.Node;
import io.agora.home.databinding.FragmentServerDetailBinding;
import io.agora.home.utils.TreeHelper;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.bean.ChannelInviteData;
import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.ThreadData;
import io.agora.service.bean.channel.ChannelEventNotifyBean;
import io.agora.service.bean.channel.ChannelMemberRemovedNotifyBean;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.databinding.DialogJoinServerBinding;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.model.ChannelViewModel;
import io.agora.service.repo.ServiceReposity;

public class ServerDetailFragment extends BaseInitFragment<FragmentServerDetailBinding> implements View.OnClickListener, BaseAdapter.ItemClickListener, OnRefreshListener {

    private ServerDetailViewModel mServerViewModel;
    private ChannelViewModel mChannelViewModel;
    private ChannelListAdapter adapter;

    private ConcurrentHashMap<String, ConcurrentHashMap<String, CircleChannel>> channels = new ConcurrentHashMap();//key:serverId , value:(key:channelId , value:channel)
    private ConcurrentHashMap<String, ConcurrentHashMap<String, EMChatThread>> threads = new ConcurrentHashMap();//key:channelId , value:(key:threadId , value:thread)
    private ConcurrentHashMap<String, ConcurrentHashMap<String, CircleServer.Tag>> tags = new ConcurrentHashMap();//key:serverId , value:(key:tagId , value:tag)
    private List<Node> sortedNodes = new ArrayList<>();//装在多级列表真正的数据
    private CircleServer currrentServer;
    private ShowMode showMode = ShowMode.NORMAL;


    public static ServerDetailFragment newInstance() {
        return new ServerDetailFragment();
    }

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_server_detail;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        adapter = new ChannelListAdapter(mContext, null, new BaseAdapter.MuitiTypeSupport() {
            @Override
            public int getLayoutId(int positon) {
                int level = adapter.getDatas().get(positon).getLevel();
                switch (level) {
                    case 0:
                        return R.layout.item_channel;
                    case 1:
                        return R.layout.item_thread_head;
                    case 2:
                        return R.layout.item_thread;
                }
                return R.layout.item_channel;
            }

            @Override
            public int getItemCount() {
                return adapter.getDatas().size();
            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false);
        mBinding.rvChannel.setLayoutManager(layoutManager);
        showViewByMode(showMode);
    }

    @Override
    protected void initData() {
        super.initData();
        mBinding.rvChannel.setAdapter(adapter);
        CircleServer server = (CircleServer) getArguments().get("server_bean");
        ShowMode showMode = (ShowMode) getArguments().get("show_mode");
        setServer(server, showMode);
    }

    public void setServer(CircleServer server, ShowMode showMode) {
        if (server == null || getActivity() == null) {
            return;
        }
        this.currrentServer = server;
        this.showMode = showMode;
        showViewByMode(showMode);
        setServerData(server);
        setChannelData(server.serverId);
    }

    private void showViewByMode(ShowMode showMode) {
        if (showMode == ShowMode.NORMAL) {
            mBinding.btnJoinIn.setVisibility(View.GONE);
            mBinding.ivInvite.setVisibility(View.VISIBLE);
            mBinding.ivMore.setVisibility(View.VISIBLE);
        } else if (showMode == ShowMode.SERVER_PREVIEW) {
            mBinding.btnJoinIn.setVisibility(View.VISIBLE);
            mBinding.ivInvite.setVisibility(View.GONE);
            mBinding.ivMore.setVisibility(View.GONE);
        }
    }

    private void setChannelData(String serverId) {
        //包含了说明已经请求过了，避免重复请求,对刷新有实时性要求的可在这里放开
        if (!channels.containsKey(serverId)) {
            mServerViewModel.getChannelData(serverId);
        } else {
            refreshList();
        }
    }

    private void setServerData(CircleServer server) {
        int randomServerIcon = ServiceReposity.getRandomServerIcon(server.serverId);
        Glide.with(mContext).load(server.icon).placeholder(randomServerIcon).into(mBinding.ivServer);
        mBinding.tvServerName.setText(server.name);
        String desc = server.desc;
        if (TextUtils.isEmpty(desc)) {
            mBinding.tvDesc.setText(getString(R.string.server_no_desc));
        } else {
            mBinding.tvDesc.setText(server.desc);
        }

        Map<String, Integer> roleMap = AppUserInfoManager.getInstance().getSelfServerRoleMapLiveData().getValue();
        if (roleMap == null || roleMap.get(server.serverId) == null) {
            mServerViewModel.fetchSelfServerRole(server.serverId);
        } else {
            initViewByRole(roleMap.get(server.serverId).intValue());
        }

        if (!tags.containsKey(server.serverId)) {
            mServerViewModel.fetchServerTags(server.serverId);
        } else {
            setServerTags();
        }
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mServerViewModel = new ViewModelProvider(this).get(ServerDetailViewModel.class);
        mChannelViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mServerViewModel.getChannelsLiveData.observe(getViewLifecycleOwner(), response -> {
            if (mBinding.srlRefresh.isRefreshing()) {
                mBinding.srlRefresh.finishRefresh();
            }
            parseResource(response, new OnResourceParseCallback<List<CircleChannel>>() {
                @Override
                public void onSuccess(@Nullable List<CircleChannel> data) {

                    getChannelDataSuccess(data);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    refreshList();
                }
            });
        });
        mServerViewModel.joinServerLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer data) {
                    //发出通知，使首页改变显示模式
                    LiveEventBus.get(Constants.HOME_CHANGE_MODE, CircleServer.class).post(data);
                    ToastUtils.showShort(getString(io.agora.service.R.string.circle_join_in_server_success));
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    if (!android.text.TextUtils.isEmpty(message)) {
                        ToastUtils.showShort(message);
                    }
                }
            });
        });
        mServerViewModel.getThreadsLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<EMChatThread>>() {
                @Override
                public void onSuccess(@Nullable List<EMChatThread> chatThreads) {
                    getThreadDataSuccess(chatThreads);
                    refreshList();
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    refreshList();
                }
            });
        });
        mServerViewModel.getServerTagsLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleServer.Tag>>() {
                @Override
                public void onSuccess(@Nullable List<CircleServer.Tag> data) {
                    onGetTagSuccess(data);
                }
            });
        });
        mChannelViewModel.checkSelfIsInChannelLiveData.observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<CustomInfo>() {
                @Override
                public void onSuccess(@Nullable CustomInfo data) {
                    if (data.isIn()) {
                        CircleChannel channel = channels.get(currrentServer.serverId).get(data.getChannelId());
                        jumpToChannel(data.getServerId(), data.getChannelId(), channel.custom);
                    } else {
                        showJoinChannelDialog(data.getServerId(), data.getChannelId());
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

        mServerViewModel.selfRoleLiveData.observe(getViewLifecycleOwner(), response -> {
        });

        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).observe(getViewLifecycleOwner(), obj -> {
            adapter.notifyDataSetChanged();
        });

        LiveEventBus.get(Constants.CONVERSATION_READ, EaseEvent.class).observe(getViewLifecycleOwner(), refreshCurrentServer -> {
            adapter.notifyDataSetChanged();
        });
        LiveEventBus.get(Constants.SERVER_CHANGED, CircleServer.class).observe(getViewLifecycleOwner(), serverChanged -> {
            if (serverChanged != null) {
                refreshServerData(serverChanged);
            }
        });
        LiveEventBus.get(Constants.SERVER_UPDATED, CircleServer.class).observe(getViewLifecycleOwner(), serverUpdated -> {
            if (serverUpdated != null) {
                refreshServerData(serverUpdated);
            }
        });
        LiveEventBus.get(Constants.CHANNEL_DELETE, CircleChannel.class).observe(getViewLifecycleOwner(), circleChannel -> {
            if (circleChannel != null) {
                removeChannel(circleChannel.serverId, circleChannel.channelId);
            }
        });
        LiveEventBus.get(Constants.CHANNEL_LEAVE, CircleChannel.class).observe(this, circleChannel -> {
            if (circleChannel != null) {
                if (circleChannel.type == EMChannelStylePrivate.getCode()) {
                    //私有频道离开，应该从首页列表里移除不展示，公开频道离开不用理会
                    removeChannel(circleChannel.serverId, circleChannel.channelId);
                } else {
                    removeChannelThreads(circleChannel.serverId, circleChannel.channelId);
                }
            }
        });
        LiveEventBus.get(Constants.ACCEPT_INVITE_CHANNEL, ChannelInviteData.class).observe(getViewLifecycleOwner(), channelInviteData -> {
            if (channelInviteData != null) {
                //接收邀请加入频道，刷新channel列表
                refreshServerData(currrentServer);
            }
        });
        LiveEventBus.get(Constants.THREAD_DESTROY, ThreadData.class).observe(getViewLifecycleOwner(), threadData -> {
            if (threadData != null) {
                ConcurrentHashMap<String, EMChatThread> threadMap = threads.get(threadData.getThreadPId());
                if (threadMap != null) {
                    threadMap.remove(threadData.getThreadId());
                    refreshList();
                }
            }
        });
        LiveEventBus.get(Constants.THREAD_UPDATE, ThreadData.class).observe(getViewLifecycleOwner(), threadData -> {
            if (threadData != null && showMode == ShowMode.NORMAL) {
                mServerViewModel.getChannelThreads(threadData.getThreadPId());
            }
        });
        LiveEventBus.get(Constants.THREAD_CHANGE, EMChatThread.class).observe(getViewLifecycleOwner(), thread -> {
            if (thread != null) {
                getThreadsContainer(thread.getParentId()).put(thread.getChatThreadId(), thread);
                refreshList();
            }
        });
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            refreshList();
        });
        LiveEventBus.get(Constants.CONVERSATION_READ, EaseEvent.class).observe(getViewLifecycleOwner(), event -> {
            refreshList();
        });

        LiveEventBus.get(Constants.CHANNEL_DESTORYED_NOTIFY, ChannelEventNotifyBean.class).observe(getViewLifecycleOwner(), bean -> {
            if (bean != null) {
                removeChannel(bean.getServerId(), bean.getChannelId());
            }
        });
        LiveEventBus.get(Constants.MEMBER_REMOVED_FROM_CHANNEL_NOTIFY, ChannelMemberRemovedNotifyBean.class).observe(getViewLifecycleOwner(), bean -> {
            if (bean != null) {
                CircleChannel circleChannel = getChannelsContainer(bean.getServerId()).get(bean.getChannelId());
                if (circleChannel != null) {
                    if (circleChannel.type == EMChannelStylePrivate.getCode()) {
                        removeChannel(bean.getServerId(), bean.getChannelId());
                    } else {
                        removeChannelThreads(bean.getServerId(), bean.getChannelId());
                    }
                }
            }
        });
        LiveEventBus.get(Constants.SERVER_UPDATED_NOTIFY, EMCircleServerEvent.class).observe(getViewLifecycleOwner(), event -> {
            //社区其他信息已在GlobalEventMonitor通过room传递给首页livedata更新，此处只用更新tag即可
            mServerViewModel.fetchServerTags(event.getId());
        });

        LiveEventBus.get(Constants.CREATE_CHANNEL_MULTIPLY_NOTIFY).observe(getViewLifecycleOwner(), obj -> {
            channels.clear();
            threads.clear();
            tags.clear();
            onRefresh(null);
        });

        AppUserInfoManager.getInstance().getSelfServerRoleMapLiveData().observe(getViewLifecycleOwner(), serverRoleMap -> {
            refreshByRoleChanged(serverRoleMap);
        });
        initListener();
    }

    /**
     * 刷新跟角色相关的view及数据等
     *
     * @param serverRoleMap
     */
    private void refreshByRoleChanged(Map<String, Integer> serverRoleMap) {
        if (serverRoleMap != null) {
            Integer roleId = serverRoleMap.get(currrentServer.serverId);
            if (roleId != null) {
                initViewByRole(roleId.intValue());
                initDataByRole(roleId.intValue());
            }
        }
    }

    private void initViewByRole(int roleId) {
        if (roleId == EMCircleUserRole.USER.getRoleId()) {//普通成员
            mBinding.ivAddChannel.setVisibility(View.GONE);
        } else if (roleId == EMCircleUserRole.MODERATOR.getRoleId()) {//管理员
            mBinding.ivAddChannel.setVisibility(View.GONE);
        } else {//拥有者owner
            mBinding.ivAddChannel.setVisibility(View.VISIBLE);
        }
    }

    private void initDataByRole(final int roleId) {
        if (roleId == EMCircleUserRole.USER.getRoleId()) {//普通成员
            //移除私有频道
            removeAllPrivateChannels();
            refreshList();
        } else if (roleId == EMCircleUserRole.MODERATOR.getRoleId()) {//管理员
            //重新拉取私有频道
            channels.clear();
            onRefresh(null);
        }
    }

    private void removeAllPrivateChannels() {
        for (ConcurrentHashMap<String, CircleChannel> channnelsByServerIdMap : channels.values()) {
            Collection<CircleChannel> channnelsByServerId = channnelsByServerIdMap.values();
            Iterator<CircleChannel> iterator = channnelsByServerId.iterator();
            while (iterator.hasNext()) {
                CircleChannel circleChannel = iterator.next();
                if (circleChannel.type == EMChannelStylePrivate.getCode()) {
                    channnelsByServerIdMap.remove(circleChannel.channelId);
                }
            }
        }
    }

    private void onGetTagSuccess(List<CircleServer.Tag> data) {
        //数据放到集合里，再刷新列表
        if (!CollectionUtils.isEmpty(data)) {
            CircleServer.Tag firstTag = data.get(0);
            if (firstTag != null) {
                ConcurrentHashMap<String, CircleServer.Tag> tagsContainer = getTagsContainer(firstTag.serverId);
                tagsContainer.clear();

                for (CircleServer.Tag tag : data) {
                    tagsContainer.put(tag.id, tag);
                }
                //更新当前server
                if (android.text.TextUtils.equals(currrentServer.serverId, firstTag.serverId)) {
                    currrentServer.tags = data;
                }
            }
        }
        setServerTags();
    }

    private void setServerTags() {
        mBinding.llTags.removeAllViews();
        ConcurrentHashMap<String, CircleServer.Tag> tagsContainer = getTagsContainer(currrentServer.serverId);
        Collection<CircleServer.Tag> tags = tagsContainer.values();
        if (this.tags != null && this.tags.size() > 0) {
            for (CircleServer.Tag tag : tags) {
                if (mContext != null) {
                    TextView textView = new TextView(mContext);
                    Drawable drawableLeft = mContext.getResources().getDrawable(io.agora.service.R.drawable.circle_bookmark);
                    textView.setCompoundDrawablesWithIntrinsicBounds(drawableLeft,
                            null, null, null);
                    textView.setCompoundDrawablePadding(4);
                    textView.setText(tag.name);
                    textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10);
                    textView.setTextColor(Color.WHITE);
                    textView.setPadding(0, 0, ConvertUtils.dp2px(8), 0);
                    mBinding.llTags.addView(textView);
                }
            }
        }
    }

    private void removeChannel(String targetServerId, String targetChannelId) {
        ConcurrentHashMap<String, CircleChannel> channelsContainer = getChannelsContainer(targetServerId);
        if (channelsContainer != null) {
            channelsContainer.remove(targetChannelId);
            //数据库里也得删掉
            DatabaseManager.getInstance().getChannelDao().deleteByChannelId(targetChannelId);
            //对应channel的thread数据清空
            removeChannelThreads(targetServerId, targetChannelId);
        }
    }

    private void removeChannelThreads(String targetServerId, String targetChannelId) {
        threads.remove(targetChannelId);
        if (android.text.TextUtils.equals(targetServerId, currrentServer.serverId) && showMode == ShowMode.NORMAL) {
            refreshList();
        }
    }

    private void refreshServerData(CircleServer serverModified) {
        if (serverModified != null) {
            ConcurrentHashMap<String, CircleChannel> channelsContainer = getChannelsContainer(serverModified.serverId);
            Set<String> channelsSet = channelsContainer.keySet();
            if (channelsSet != null) {
                for (String channelId : channelsSet) {
                    threads.remove(channelId);
                }
            }
            channels.remove(serverModified.serverId);
            tags.remove(serverModified.serverId);

            if (android.text.TextUtils.equals(serverModified.serverId, currrentServer.serverId)) {
                setServer(serverModified, showMode);
            }
        }
    }

    private void showJoinChannelDialog(String serverId, String channelId) {
        if (currrentServer == null || !android.text.TextUtils.equals(serverId, currrentServer.serverId)) {
            return;
        }
        CircleChannel circleChannel = getChannelsContainer(serverId).get(channelId);
        if (circleChannel == null) {
            return;
        }
        DialogJoinServerBinding joinChannelBinding = DialogJoinServerBinding.inflate(getLayoutInflater());
        AlertDialog dialog = new AlertDialog.Builder(mContext)
                .setContentView(joinChannelBinding.getRoot())
                .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                .show();
        joinChannelBinding.tvChannelName.setVisibility(View.VISIBLE);
        Glide.with(this).load(currrentServer.icon).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(joinChannelBinding.ivServer);
        joinChannelBinding.tvServerName.setText(currrentServer.name);
        joinChannelBinding.tvDesc.setText(currrentServer.desc);
        joinChannelBinding.tvChannelName.setText(circleChannel.name);
        joinChannelBinding.btnCancel.setText(getString(io.agora.service.R.string.circle_let_me_think));
        joinChannelBinding.btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        joinChannelBinding.btnJoinImmediately.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EMClient.getInstance().chatCircleManager().joinChannel(serverId, channelId, new EMValueCallBack<EMCircleChannel>() {
                            @Override
                            public void onSuccess(EMCircleChannel value) {
                                //拉取子区
                                ThreadUtils.runOnUiThread(() -> {
                                    mServerViewModel.getChannelThreads(value.getChannelId());
                                });
                                ToastUtils.showShort(getString(io.agora.service.R.string.circle_join_in_channel_success));
                                LiveEventBus.get(Constants.CHANNEL_CHANGED).post(null);
                                //发送一条私聊消息给对方
                                CustomInfo customInfo = new CustomInfo();
                                customInfo.setServerId(currrentServer.serverId);
                                customInfo.setServerName(currrentServer.name);
                                customInfo.setServerIcon(currrentServer.icon);
                                customInfo.setServerDesc(currrentServer.desc);
                                customInfo.setChannelId(circleChannel.channelId);
                                customInfo.setChannelName(circleChannel.name);

                                sendInviteCustomMessage(Constants.ACCEPT_INVITE_CHANNEL, customInfo, circleChannel.channelId);
                                jumpToChannel(serverId, channelId, value.getExt());
                            }

                            @Override
                            public void onError(int error, String errorMsg) {
                                if (!TextUtils.isEmpty(errorMsg)) {
                                    ToastUtils.showShort(errorMsg);
                                }
                            }
                        }
                );
                dialog.dismiss();
            }
        });
    }


    private synchronized void refreshList() {
        List<Node> serverNodes = getServerNodes(currrentServer.serverId);
        if (serverNodes == null || serverNodes.size() == 0) {
            return;
        }
        try {
            sortedNodes = TreeHelper.getSortedNodes(serverNodes, 0);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        adapter.refresh(sortedNodes);
    }

    /**
     * @param serverId
     * @return 进入多级列表之前的原始数据
     */
    private List<Node> getServerNodes(String serverId) {
        List<Node> allNodes = new ArrayList<>();
        ConcurrentHashMap<String, CircleChannel> channelsContainer = getChannelsContainer(serverId);
        Collection<CircleChannel> serverChannels = channelsContainer.values();
        for (CircleChannel channel : serverChannels) {
            //构造频道item数据
            Node node = new Node(channel.channelId, null, channel.name);
            if (channel.type == EMChannelStylePublic.getCode()) {
                node.setIcon(R.drawable.circle_channel_public_icon);
            } else {
                node.setIcon(R.drawable.circle_channel_private_icon);
            }
            node.setDefault(channel.isDefault);
            allNodes.add(node);

            Collection<EMChatThread> channelThreads = getThreadsContainer(channel.channelId).values();
            Iterator<EMChatThread> iterator = channelThreads.iterator();
            if (iterator.hasNext()) {
                EMChatThread chatThread = iterator.next();
                //构造子区标题栏数据
                //id=固定Id+pid,保证唯一性即可
                allNodes.add(getThreadHeadNode(chatThread));
                allNodes.add(getThreadItemNode(chatThread));
            }
            while (iterator.hasNext()) {
                EMChatThread chatThread = iterator.next();
                allNodes.add(getThreadItemNode(chatThread));
            }
        }
        sortNodes(allNodes);
        return allNodes;
    }

    private Node getThreadItemNode(EMChatThread chatThread) {
        Node node = new Node(chatThread.getChatThreadId(), Constants.THREAD_ID + chatThread.getParentId(), chatThread.getChatThreadName());
        return node;
    }

    private Node getThreadHeadNode(EMChatThread chatThread) {
        Node node = new Node(Constants.THREAD_ID + chatThread.getParentId(), chatThread.getParentId(), chatThread.getChatThreadName());
        return node;
    }

    private void sortNodes(List<Node> allNodes) {
        //通用频道放到最前边
        Node defaultChannelNode = null;
        for (Node node : allNodes) {
            if (node.isDefault()) {
                defaultChannelNode = node;
                break;
            }
        }
        if (defaultChannelNode != null) {
            allNodes.remove(defaultChannelNode);
        }
        allNodes.add(0, defaultChannelNode);
    }

    private void getThreadDataSuccess(List<EMChatThread> chatThreads) {
        if (chatThreads != null && !chatThreads.isEmpty()) {
            for (int i = 0; i < chatThreads.size(); i++) {
                EMChatThread chatThread = chatThreads.get(i);
                ConcurrentHashMap<String, EMChatThread> threadsContainer = getThreadsContainer(chatThread.getParentId());
                threadsContainer.put(chatThread.getChatThreadId(), chatThread);
            }
        }
    }

    private void getChannelDataSuccess(List<CircleChannel> data) {
        if (!CollectionUtils.isEmpty(data)) {
            for (CircleChannel channel : data) {
                ConcurrentHashMap<String, CircleChannel> channelsContainer = getChannelsContainer(channel.serverId);
                channelsContainer.put(channel.channelId, channel);
                mServerViewModel.getChannelThreads(channel.channelId);
            }
        }
    }

    private synchronized ConcurrentHashMap<String, CircleChannel> getChannelsContainer(String serverId) {
        ConcurrentHashMap<String, CircleChannel> serverChannels = channels.get(serverId);
        if (serverChannels == null) {
            serverChannels = new ConcurrentHashMap<>();
            channels.put(serverId, serverChannels);
        }
        return serverChannels;
    }

    private synchronized ConcurrentHashMap<String, EMChatThread> getThreadsContainer(String channelId) {
        ConcurrentHashMap<String, EMChatThread> channelThreads = threads.get(channelId);
        if (channelThreads == null) {
            channelThreads = new ConcurrentHashMap<>();
            threads.put(channelId, channelThreads);
        }
        return channelThreads;
    }

    private synchronized ConcurrentHashMap<String, CircleServer.Tag> getTagsContainer(String serverId) {
        ConcurrentHashMap<String, CircleServer.Tag> serverTags = tags.get(serverId);
        if (serverTags == null) {
            serverTags = new ConcurrentHashMap<>();
            tags.put(serverId, serverTags);
        }
        return serverTags;
    }


    private void initListener() {
        mBinding.ivInvite.setOnClickListener(this);
        mBinding.ivMore.setOnClickListener(this);
        mBinding.llChannelType.setOnClickListener(this);
        mBinding.ivAddChannel.setOnClickListener(this);
        mBinding.btnJoinIn.setOnClickListener(this);
        adapter.setOnItemClickListener(this);
        mBinding.srlRefresh.setOnRefreshListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_invite) {
            //去邀请联系人页面
            // 通知Mainactivity弹框
            if (currrentServer != null) {
                LiveEventBus.get(Constants.SHOW_SERVER_INVITE_FRAGMENT).post(currrentServer);
            }
        } else if (v.getId() == R.id.iv_more) {
            //弹框
            LiveEventBus.get(Constants.SHOW_SERVER_SETTING_FRAGMENT, CircleServer.class).post(currrentServer);
        } else if (v.getId() == R.id.ll_channel_type) {
            //变更箭头方向，收齐展开recycleview
            int channelVisibility = mBinding.rvChannel.getVisibility();
            if (channelVisibility == View.VISIBLE) {
                mBinding.ivChannnelList.setImageResource(io.agora.service.R.drawable.circle_arrow_right_gray);
                mBinding.rvChannel.setVisibility(View.GONE);
            } else {
                mBinding.ivChannnelList.setImageResource(io.agora.service.R.drawable.circle_arrow_up);
                mBinding.rvChannel.setVisibility(View.VISIBLE);
            }

        } else if (v.getId() == R.id.iv_add_channel) {
            if (showMode == ShowMode.NORMAL) {
                //去创建频道
                LiveEventBus.get(Constants.SHOW_CREATE_CHANNEL_FRAGMENT, CircleServer.class).post(currrentServer);
            } else {
                ToastUtils.showShort(getString(io.agora.service.R.string.circle_preview_mode));
            }
        } else if (v.getId() == R.id.btn_join_in) {
            //加入server
            mServerViewModel.joinServer(currrentServer.serverId);
        }
    }

    @Override
    public void onClick(View itemView, int positon) {
        List<Node> datas = adapter.getDatas();
        Node node = datas.get(positon);
        switch (node.getLevel()) {
            case 0:
                //首先判断是否在这个频道里，没有就弹框
                if (showMode == ShowMode.NORMAL) {
                    CustomInfo info = new CustomInfo();
                    info.setServerId(currrentServer.serverId);
                    info.setChannelId(node.getId());
                    mChannelViewModel.checkSelfIsInChannel(info);
                } else {
                    //预览模式直接跳转到会话页面
                    CircleChannel channel = channels.get(currrentServer.serverId).get(node.getId());
                    jumpToChannel(currrentServer.serverId, node.getId(),channel.custom);
                }
                break;
            case 1:
                if (!node.isLeaf()) {
                    node.setExpand(!node.isExpand());
                    List<Node> visiableNodes = TreeHelper.filterVisibleNode(sortedNodes);
                    adapter.refresh(visiableNodes);
                }
                break;
            case 2:
                EMChatThread chatThread = getThreadsContainer(node.getParent().getpId()).get(node.getId());
                if (chatThread != null) {
                    ARouter.getInstance().build("/app/ChatThreadActivity")
                            .withString(CONVERSATION_ID, node.getId())
                            .withString(SERVER_ID, currrentServer.serverId)
                            .withString(PARENT_MSG_ID, chatThread.getMessageId())
                            .withSerializable(PARENT_ID, chatThread.getParentId())
                            .withString(Constants.THREAD_NAME, chatThread.getChatThreadName())
                            .withString(Constants.CHANNEL_NAME, node.getParent().getParent().getName())
                            .navigation();
                }
                break;
        }


    }

    private void jumpToChannel(String serverId, String channelId, String custom) {
        CircleChannel circleChannel = getChannelsContainer(serverId).get(channelId);
        if (circleChannel != null) {
            ARouter.getInstance().build("/chat/ChatActivity")
                    .withString(EaseConstant.EXTRA_CONVERSATION_ID, circleChannel.channelId)
                    .withSerializable(Constants.CHANNEL, circleChannel)
                    .withInt(EaseConstant.EXTRA_CHAT_TYPE, Constants.CHATTYPE_GROUP)
                    .withString(EaseConstant.EXTRA_CHANNEL_TYPE,custom)
                    .withSerializable(Constants.SHOW_MODE, showMode)
                    .navigation();
        }
    }

    @Override
    public void onRefresh(RefreshLayout refreshLayout) {
        if (currrentServer != null) {
            channels.remove(currrentServer.serverId);
            mServerViewModel.getChannelData(currrentServer.serverId);
        }
    }
}