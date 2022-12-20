package io.agora.home.ui;


import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.easeui.utils.ShowMode;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.home.R;
import io.agora.home.databinding.FragmentHomeBinding;
import io.agora.home.model.HomeViewModel;
import io.agora.service.adapter.HomeMenuAdapter;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.bean.ChannelInviteData;
import io.agora.service.bean.server.ServerMembersNotifyBean;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;

public class HomeFragment extends BaseInitFragment<FragmentHomeBinding> implements HomeMenuAdapter.OnMenuClickListener<CircleServer> {
    private HomeViewModel mViewModel;
    private HomeMenuAdapter mAdapter;
    private ServerDetailFragment mServerDetailFragment = ServerDetailFragment.newInstance();
    private ConversationListFragment mConversationListFragment;
    private int mCheckPos;
    private ShowMode showMode = ShowMode.NORMAL;
    private Map<String, CircleServer> joinedServers = new HashMap<>();

    public void showServerPreview(CircleServer server) {
        if (server != null) {
            showMode = ShowMode.SERVER_PREVIEW;
            ArrayList<CircleServer> servers = new ArrayList<>();
            servers.add(server);
            mAdapter.setData(servers);
            mCheckPos = 0;
            mAdapter.setCheckedPos(servers.size());
        }
    }

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_home;
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(HomeViewModel.class);

        mViewModel.JoinedServerlistLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleServer>>() {

                @Override
                public void onSuccess(@Nullable List<CircleServer> data) {
                    //清空历史数据
                    mCheckPos = 0;
                    joinedServers.clear();

                    Map<String, CircleServer> joinedServersCache = AppUserInfoManager.getInstance().getUserJoinedSevers();
                    joinedServersCache.clear();

                    if (data != null) {
                        for (CircleServer circleServer : data) {
                            joinedServers.put(circleServer.serverId, circleServer);
                            //缓存到内存中
                            joinedServersCache.put(circleServer.serverId, circleServer);
                        }
                    }
                    mAdapter.setData(joinedServers.values());
                }
            });
        });

        LiveEventBus.get(Constants.SERVER_CHANGED).observe(getViewLifecycleOwner(), obj -> {
            if (showMode == ShowMode.NORMAL) {
                mViewModel.getJoinedServerList();
            }
        });
        LiveEventBus.get(Constants.ACCEPT_INVITE_CHANNEL, ChannelInviteData.class).observe(getViewLifecycleOwner(), channelInviteData -> {
            if (showMode == ShowMode.NORMAL) {
                mViewModel.getJoinedServerList();
            }
        });
        LiveEventBus.get(Constants.SERVER_UPDATED, CircleServer.class).observe(getViewLifecycleOwner(), circleServer -> {
            if (circleServer != null) {
                joinedServers.put(circleServer.serverId, circleServer);
                AppUserInfoManager.getInstance().getUserJoinedSevers().put(circleServer.serverId, circleServer);
                mAdapter.setData(joinedServers.values());
            }
        });
        LiveEventBus.get(Constants.HOME_CHANGE_MODE, CircleServer.class).observe(getViewLifecycleOwner(), server -> {
            if (showMode != ShowMode.NORMAL) {
                //加入sever成功或者被通知切换模式，改变显示模式
                showMode = ShowMode.NORMAL;
                if (server != null) {
                    joinedServers.put(server.serverId, server);
                }
                mAdapter.setData(joinedServers.values());
                mAdapter.setCheckedPos(joinedServers.size());
            } else {
                if (server != null) {
                    //切换到目标server，显示详情
                    mAdapter.setCheckedServer(server);
                }
            }
        });
        LiveEventBus.get(Constants.SERVER_MEMBER_BE_REMOVED_NOTIFY, ServerMembersNotifyBean.class).observe(getViewLifecycleOwner(), bean -> {
            if (bean != null && showMode == ShowMode.NORMAL) {
                List<String> ids = bean.getIds();
                if (ids != null) {
                    for (int i = 0; i < ids.size(); i++) {
                        if (TextUtils.equals(ids.get(i), AppUserInfoManager.getInstance().getCurrentUserName())) {
                            DatabaseManager.getInstance().getServerDao().deleteByServerId(bean.getServerId());
                        }
                        break;
                    }
                }
            }
        });
        //监听未读数
        LiveEventBus.get(Constants.NOTIFY_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.GROUP_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CHAT_ROOM_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONVERSATION_DELETE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONVERSATION_READ, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONTACT_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONTACT_ADD, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONTACT_DELETE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.CONTACT_UPDATE, EaseEvent.class).observe(getViewLifecycleOwner(), this::getConversationData);
        LiveEventBus.get(Constants.MESSAGE_CALL_SAVE, Boolean.class).observe(getViewLifecycleOwner(), bool -> {
            getConversationData(null);
        });
        LiveEventBus.get(Constants.MESSAGE_NOT_SEND, Boolean.class).observe(getViewLifecycleOwner(), bool -> {
            getConversationData(null);
        });
    }

    public void getConversationData(EaseEvent change) {
        int unreadMsgCount = 0;
        List<EMConversation> conversations = mViewModel.getConversationsWithType(EMConversation.EMConversationType.Chat);
        for (EMConversation conversation : conversations) {
            unreadMsgCount += conversation.getUnreadMsgCount();
        }
        mAdapter.setUnreadMap("-1", unreadMsgCount, 0);
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mConversationListFragment = ConversationListFragment.newInstance();
        replace(mConversationListFragment, R.id.fcv_fragment, "conversation");
    }


    @Override
    protected void initData() {
        mAdapter = new HomeMenuAdapter(mContext);
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);

        mBinding.rvMenu.setLayoutManager(layoutManager);
        mBinding.rvMenu.setAdapter(mAdapter);
        mAdapter.setOnMenuClickListener(this);

        //获取server列表
        mViewModel.getJoinedServerList();
    }

    @Override
    public void onStartClick() {
        mCheckPos = 0;
        replace(mConversationListFragment, R.id.fcv_fragment, "conversation");
    }

    @Override
    public void onItemClick(int pos, CircleServer bean) {
        if (mCheckPos != pos) {
            mCheckPos = pos;
            //切换fragment
            Bundle bundle = new Bundle();
            bundle.putSerializable("server_bean", bean);
            bundle.putSerializable("show_mode", showMode);
            mServerDetailFragment.setArguments(bundle);
            replace(mServerDetailFragment, R.id.fcv_fragment, "server_detail");
            //获取server详情，设置给fragment
            mServerDetailFragment.setServer(bean, showMode);
        }
    }

    @Override
    public void onAddClick() {
        ARouter.getInstance()
                .build("/home/CreateServerActivity")
                .navigation();
    }
}
