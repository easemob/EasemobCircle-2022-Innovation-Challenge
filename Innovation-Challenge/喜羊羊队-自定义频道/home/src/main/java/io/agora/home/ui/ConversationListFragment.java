package io.agora.home.ui;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.model.EaseEvent;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.common.base.BaseAdapter;
import io.agora.home.R;
import io.agora.home.adapter.ConversationListAdapter;
import io.agora.home.databinding.FragmentConversationListBinding;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.global.Constants;

public class ConversationListFragment extends BaseInitFragment<FragmentConversationListBinding> {

    private ConversationListViewModel mViewModel;
    private ConversationListAdapter adapter;

    public static ConversationListFragment newInstance() {
        return new ConversationListFragment();
    }


    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_conversation_list;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        LinearLayoutManager manager = new LinearLayoutManager(mContext);
        mBinding.rvConversation.setLayoutManager(manager);
        adapter = new ConversationListAdapter(mContext);
        mBinding.rvConversation.setAdapter(adapter);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ConversationListViewModel.class);
        mViewModel.presencesObservable().observe(this, listResource -> {
            parseResource(listResource, new OnResourceParseCallback<List<EMPresence>>() {
                @Override
                public void onSuccess(@Nullable List<EMPresence> data) {
                    adapter.notifyDataSetChanged();
                }
            });
        });
        LiveEventBus.get(Constants.PRESENCES_CHANGED, ConcurrentHashMap.class).observe(getViewLifecycleOwner(), new Observer<ConcurrentHashMap>() {
                    @Override
                    public void onChanged(ConcurrentHashMap map) {
                        adapter.notifyDataSetChanged();
                    }
                }
        );

        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                adapter.notifyDataSetChanged();
            }
        });
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
        adapter.setOnItemClickListener(new BaseAdapter.ItemClickListener() {
            @Override
            public void onClick(View itemView, int positon) {
                List<EMConversation> datas = adapter.getDatas();
                if (datas != null) {
                    EMConversation conversation = datas.get(positon);
                    EMConversation.EMConversationType type = conversation.getType();
                    int chatType = Constants.CHATTYPE_SINGLE;
                    if (type == EMConversation.EMConversationType.Chat) {
                        chatType = Constants.CHATTYPE_SINGLE;
                    } else if (type == EMConversation.EMConversationType.GroupChat) {
                        chatType = Constants.CHATTYPE_GROUP;
                    } else if (type == EMConversation.EMConversationType.ChatRoom) {
                        chatType = Constants.CHATTYPE_CHATROOM;
                    }
                    ARouter.getInstance().build("/chat/ChatActivity")
                            .withString(EaseConstant.EXTRA_CONVERSATION_ID, conversation.conversationId())
                            .withInt(EaseConstant.EXTRA_CHAT_TYPE, chatType)
                            .navigation();
                }
            }
        });
        adapter.setOnUserPresenceListener(new BaseAdapter.OnUserPresenceListener() {
            @Override
            public void subscribe(String username, long expireTime) {
                mViewModel.subscribePresences(username, expireTime);
            }
        });
    }

    @Override
    protected void initData() {
        super.initData();
        getConversationData(null);
    }

    public void getConversationData(EaseEvent change) {
        List<EMConversation> conversations = mViewModel.getConversationsWithType(EMConversation.EMConversationType.Chat);
        adapter.refresh(conversations);
    }

}