package io.agora.contacts.notification;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;
import com.hyphenate.easeui.model.EaseEvent;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.Collections;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.notification.viewmodels.NewFriendsViewModel;
import io.agora.contacts.notification.viewmodels.NotificationMsgsViewModel;
import io.agora.contacts.ui.BaseContactListFragment;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;

public class NotificationMsgFragment extends BaseContactListFragment<EMMessage> implements  EaseBaseRecyclerViewAdapter.OnUserPresenceListener {
    private NotificationMsgsViewModel mMsgsViewModel;
    private NewFriendsViewModel mNewFriendViewModel;
    private List<EMMessage> mData;

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mBinding.etSearch.setVisibility(View.GONE);
        mBinding.sideBarContact.setVisibility(View.GONE);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        initViewModel();
    }

    protected void initViewModel() {
        mMsgsViewModel = new ViewModelProvider(this).get(NotificationMsgsViewModel.class);
        mNewFriendViewModel = new ViewModelProvider(this).get(NewFriendsViewModel.class);
        mMsgsViewModel.getChatMessageObservable().observe(this, datas -> {
            mBinding.srlContactRefresh.setRefreshing(false);
            Collections.reverse(datas);
            mData = datas;
            mListAdapter.setData(datas);
        });

        mMsgsViewModel.getSearchResultObservable().observe(this, response -> {
            mListAdapter.setData(response);
        });

        mNewFriendViewModel.agreeObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(String message) {
                    mMsgsViewModel.getAllMessages();
                    ToastUtils.showShort(getString(R.string.circle_accept_invite_success));
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(getString(R.string.circle_accept_invite_failure));
                }
            });
        });
        mNewFriendViewModel.refuseObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<String>() {
                @Override
                public void onSuccess(String message) {
                    mMsgsViewModel.getAllMessages();
                    ToastUtils.showShort(getString(R.string.circle_refuse_invite_success));
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    ToastUtils.showShort(getString(R.string.circle_refuse_invite_failure));
                }
            });
        });
        mMsgsViewModel.presencesObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<EMPresence>>() {
                @Override
                public void onSuccess(@Nullable List<EMPresence> presences) {
                    mListAdapter.notifyDataSetChanged();
                }
            });
        });
        LiveEventBus.get(Constants.GROUP_CHANGE).observe(getViewLifecycleOwner(), this::loadList);
        LiveEventBus.get(Constants.PRESENCES_CHANGED).observe(getViewLifecycleOwner(), this::refreshList);
        LiveEventBus.get(Constants.CHAT_ROOM_CHANGE).observe(getViewLifecycleOwner(), this::loadList);
        LiveEventBus.get(Constants.CONTACT_CHANGE).observe(getViewLifecycleOwner(), this::loadList);
        LiveEventBus.get(Constants.NOTIFY_CHANGE, EaseEvent.class).observe(getViewLifecycleOwner(), this::loadList);
        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(),this::refreshList);
    }
    private void refreshList(Object o){
        mListAdapter.notifyDataSetChanged();
    }

    private void loadList(Object change) {
        if (change == null) {
            return;
        }
        mMsgsViewModel.getAllMessages();
    }

    @Override
    public void onResume() {
        super.onResume();
        mNewFriendViewModel.makeAllMsgRead();
    }

    @Override
    protected void initData() {
        super.initData();
        mMsgsViewModel.getAllMessages();
    }

    @Override
    protected void initListener() {
        super.initListener();
        mListAdapter.setOnUserPresenceListener(this);
    }

    @Override
    public void onRefresh() {
        super.onRefresh();
        mMsgsViewModel.getAllMessages();
    }

    @Override
    protected void searchText(String content) {
        checkSearchContent(content);
    }

    private void checkSearchContent(String content) {
        if (TextUtils.isEmpty(content)) {
            mListAdapter.setData(mData);
            mBinding.srlContactRefresh.setEnabled(true);
        } else {
            mMsgsViewModel.searchMsgs(content);
            mBinding.srlContactRefresh.setEnabled(false);
        }
    }

    @Override
    public void onItemClick(View view, int position) {

    }

    @Override
    protected EaseBaseRecyclerViewAdapter<EMMessage> initAdapter() {
        return new NotificationMsgAdapter();
    }

    @Override
    public void onItemSubViewClick(View view, int position) {
        int id = view.getId();
        if (id == R.id.btn_accept) {
            mNewFriendViewModel.agreeInvite(mListAdapter.getData().get(position));
        }else if (id == R.id.btn_refuse) {
            mNewFriendViewModel.refuseInvite(mListAdapter.getData().get(position));
        }
    }

    @Override
    public void subscribe(String username, long expireTime) {
        //不能订阅自己
        if (!TextUtils.equals(username, AppUserInfoManager.getInstance().getCurrentUserName())) {
            mMsgsViewModel.subscribePresences(username, expireTime);
        }
    }
}
