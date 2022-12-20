package io.agora.contacts.ui;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMPresence;

import java.util.ArrayList;
import java.util.List;

import io.agora.common.base.BaseAdapter;
import io.agora.contacts.R;
import io.agora.contacts.adapter.AddFriendAdapter;
import io.agora.contacts.databinding.ActivityAddFriendBinding;
import io.agora.contacts.model.ContactsViewModel;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;

public class AddFriendActivity extends BaseInitActivity<ActivityAddFriendBinding> {
    private ContactsViewModel mViewModel;
    private AddFriendAdapter adapter;
    private List<CircleUser> users = new ArrayList<>();

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_add_friend;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        adapter = new AddFriendAdapter(this, R.layout.item_add_friend);
        mBinding.rvResult.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mBinding.rvResult.setAdapter(adapter);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ContactsViewModel.class);
        mViewModel.getUserInfoLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleUser>() {
                @Override
                public void onSuccess(@Nullable CircleUser data) {
                    users.clear();
                    if (data != null) {
                        users.add(data);
                        mViewModel.subscribePresences(data.getUsername(), 7 * 24 * 60 * 60);
                    }
                    adapter.refresh(users);
                }
            });
        });
        mViewModel.presencesObservable().observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<EMPresence>>() {
                @Override
                public void onSuccess(@Nullable List<EMPresence> data) {
                    adapter.refresh(users);
                }
            });
        });
        mViewModel.addContactLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<Boolean>() {
                @Override
                public void onSuccess(@Nullable Boolean bool) {
                    if (bool) {
                        ToastUtils.showShort(getString(R.string.circle_has_send_friend_request));
                    }
                }
            });
        });
        initlistener();
    }

    private void initlistener() {
        mBinding.etSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                String key = mBinding.etSearch.getText().toString();
                if (key.length() > 0) {
                    mBinding.ivClear.setVisibility(View.VISIBLE);
                } else {
                    mBinding.ivClear.setVisibility(View.GONE);
                }
            }
        });
        mBinding.ivClear.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mBinding.etSearch.setText("");
                adapter.refresh(null);
            }
        });

        mBinding.etSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    doSearch();
                    return true;
                }
                return false;
            }
        });
        adapter.setOnSubViewClickListener(new BaseAdapter.SubViewClickListener() {
            @Override
            public void onSubViewClick(View v, int positon) {
                if (v.getId() == R.id.btn_add_friend) {
                    boolean enabled = v.isEnabled();
                    if (enabled) {
                        v.setEnabled(false);
                        mViewModel.addFriend(users.get(positon).getUsername());
                        ((Button) v).setText(getString(R.string.circle_adding));
                        ((Button) v).setTextColor(ContextCompat.getColor(mContext, R.color.color_gray_40f2f2f2));
                    }
                }
            }
        });
        mBinding.ivBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    private void doSearch() {
        String key = mBinding.etSearch.getText().toString();
        if (TextUtils.isEmpty(key.trim())) {
            ToastUtils.showShort(getString(R.string.hx_id_not_empty));
            return;
        }
        if (!TextUtils.equals(key, AppUserInfoManager.getInstance().getCurrentUserName())) {
            mViewModel.getUserInfoById(key);
        }
    }

}