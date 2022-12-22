package io.agora.contacts.ui;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;

import io.agora.contacts.R;
import io.agora.contacts.adapter.ContactListAdapter;
import io.agora.contacts.databinding.FragmentContactListBinding;
import io.agora.service.base.BaseListFragment;
import io.agora.service.widget.SidebarPresenter;


public abstract class BaseContactListFragment<T> extends BaseListFragment<T, FragmentContactListBinding>
        implements SwipeRefreshLayout.OnRefreshListener, EaseBaseRecyclerViewAdapter.OnUserPresenceListener,
        EaseBaseRecyclerViewAdapter.OnItemSubViewClickListener {

    private SidebarPresenter sidebarPresenter;

    private boolean canUseRefresh = true;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_contact_list;
    }


    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);

        mBinding.srlContactRefresh.setEnabled(canUseRefresh);

        sidebarPresenter = new SidebarPresenter();
        sidebarPresenter.setupWithRecyclerView(mRecyclerView, mListAdapter, mBinding.floatingHeader);
        mBinding.sideBarContact.setOnTouchEventListener(sidebarPresenter);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        initListener();
    }

    @Override
    protected RecyclerView initRecyclerView() {
        return mBinding.contactList;
    }

    @Override
    protected EaseBaseRecyclerViewAdapter<T> initAdapter() {
        EaseBaseRecyclerViewAdapter adapter = new ContactListAdapter();
        adapter.setEmptyView(io.agora.service.R.layout.circle_no_data);
        return adapter;
    }

    protected void initListener() {
        mBinding.srlContactRefresh.setOnRefreshListener(this);
        mBinding.etSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                String searchContent = s.toString().trim();
                searchText(searchContent);
            }
        });
        mListAdapter.setOnItemSubViewClickListener(this);
    }

    protected void searchText(String content) {
    }

    @Override
    public void onRefresh() {

    }

    protected void finishRefresh() {
        if (mBinding.srlContactRefresh != null && mBinding.srlContactRefresh.isRefreshing()) {
            mBinding.srlContactRefresh.setRefreshing(false);
        }
    }

    @Override
    public void onItemSubViewClick(View view, int position) {

    }
}
