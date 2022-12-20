package io.agora.contacts.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.alibaba.android.arouter.launcher.ARouter;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;
import com.hyphenate.easeui.constants.EaseConstant;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.model.ContactsListViewModel;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;


public class ContactListFragment extends BaseContactListFragment<CircleUser> implements EaseBaseRecyclerViewAdapter.OnUserPresenceListener {
    protected ContactsListViewModel mContactsListViewModel;
    protected List<CircleUser> mData = new ArrayList<>();//源数据
    protected List<CircleUser> mSearchData = new ArrayList<>();//搜索过滤后的数据

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mBinding.etSearch.setVisibility(View.VISIBLE);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        initContactsListViewModel();
        mListAdapter.setOnUserPresenceListener(this);
    }

    private void initContactsListViewModel() {

        mContactsListViewModel = new ViewModelProvider(this).get(ContactsListViewModel.class);
        mContactsListViewModel.presencesObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<EMPresence>>() {
                @Override
                public void onSuccess(@Nullable List<EMPresence> data) {
                    setData(mData);
                    checkView(mBinding.etSearch.getText().toString().trim());
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                }
            });
        });
        mContactsListViewModel.getContactObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(List<CircleUser> data) {
                    mBinding.srlContactRefresh.setRefreshing(false);
                    mData = data;
                    setData(mData);
                    mContactsListViewModel.subscribePresencesWithUsers(data, 7 * 24 * 60 * 60);
                }

                @Override
                public void onLoading(@Nullable List<CircleUser> data) {
                    super.onLoading(data);
                    if (data != null && data.size() > 0) {
                        mData = data;
                        setData(mData);
                        checkView(mBinding.etSearch.getText().toString().trim());
                    }
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    getActivity().runOnUiThread(() -> mBinding.srlContactRefresh.setRefreshing(false));
                }
            });
        });
        mContactsListViewModel.resultObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean data) {
                    mContactsListViewModel.loadContactList(false);
                }
            });
        });

        mContactsListViewModel.deleteObservable().observe(getViewLifecycleOwner(), response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean data) {
                    mContactsListViewModel.loadContactList(false);
                }
            });
        });

        mContactsListViewModel.getSearchObservable().observe(getViewLifecycleOwner(), result -> {
            parseResource(result, new OnResourceParseCallback<List<CircleUser>>() {
                @Override
                public void onSuccess(@Nullable List<CircleUser> data) {
                    mContactsListViewModel.subscribePresencesWithUsers(data, 7 * 24 * 60 * 60);
                }
            });
        });
        LiveEventBus.get(Constants.CONTACT_CHANGE).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                mContactsListViewModel.loadContactList(false);
            }
        });
        LiveEventBus.get(Constants.CONTACT_DELETE).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                mContactsListViewModel.loadContactList(false);
            }
        });
        LiveEventBus.get(Constants.CONTACT_ADD).observe(getViewLifecycleOwner(), new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                mContactsListViewModel.loadContactList(false);
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
                mListAdapter.notifyDataSetChanged();
            }
        });
    }

    protected void setData(List<CircleUser> datas) {
        mListAdapter.setData(datas);
    }


    @Override
    protected void initData() {
        super.initData();
        mContactsListViewModel.loadContactList(true);
    }

    @Override
    public void onRefresh() {
        super.onRefresh();
        mContactsListViewModel.loadContactList(true);
    }

    @Override
    public void onItemClick(View view, int position) {

        List<CircleUser> datas = mListAdapter.getData();
        CircleUser circleUser = datas.get(position);
        if (!TextUtils.equals(circleUser.getUsername(), AppUserInfoManager.getInstance().getCurrentUserName())) {
            ARouter.getInstance().build("/chat/ChatActivity")
                    .withString(EaseConstant.EXTRA_CONVERSATION_ID, circleUser.getUsername())
                    .withInt(EaseConstant.EXTRA_CHAT_TYPE, Constants.CHATTYPE_SINGLE)
                    .navigation();
        }
    }

    @Override
    public void onItemSubViewClick(View view, int position) {
        if (view.getId() == R.id.presenceView) {
            List<CircleUser> datas = mListAdapter.getData();
            if (datas != null) {
                CircleUser circleUser = datas.get(position);
                //跳转到用户详情页
                if (!TextUtils.equals(circleUser.username, AppUserInfoManager.getInstance().getCurrentUserName())) {
                    //跳转到详情页面
                    ARouter.getInstance()
                            .build("/contacts/UserDetailActivity")
                            .withString(Constants.USERNAME, circleUser.username)
                            .navigation();
                }
            }

        }
    }

    @Override
    protected void searchText(String content) {
        checkSearchContent(content);
        checkView(content);
    }

    protected void checkSearchContent(String content) {
        if (TextUtils.isEmpty(content)) {
            setData(mData);
        } else {
            filterDataByKeyWord(content);
        }
    }

    //筛选出名字或者昵称里带搜索关键字的数据
    protected void filterDataByKeyWord(String keyWord) {
        mSearchData.clear();
        for (CircleUser circleUser : mData) {
            if (circleUser.username.contains(keyWord) || circleUser.nickname.contains(keyWord)) {
                mSearchData.add(circleUser);
            }
        }
        setData(mSearchData);
    }

    protected void checkView(String content) {
        if (TextUtils.isEmpty(content)) {
            mBinding.srlContactRefresh.setEnabled(true);
        } else {
            mBinding.srlContactRefresh.setEnabled(false);
        }
    }

    @Override
    public void subscribe(String username, long expireTime) {
        mContactsListViewModel.subscribePresences(username, expireTime);
    }

}
