package io.agora.ground.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.alibaba.android.arouter.facade.Postcard;
import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.google.gson.Gson;
import com.hyphenate.easeui.utils.ShowMode;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.common.dialog.AlertDialog;
import io.agora.ground.R;
import io.agora.ground.adapter.GroundAdapter;
import io.agora.ground.callbacks.OnItemClickListener;
import io.agora.ground.databinding.ActivitySearchGroundBinding;
import io.agora.ground.model.GroundViewModel;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.databinding.DialogJoinServerBinding;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;

public class SearchGroundActivity extends BaseInitActivity<ActivitySearchGroundBinding> implements TextWatcher, TextView.OnEditorActionListener, OnItemClickListener<CircleServer> {
    private GroundViewModel mViewModel;
    private RecyclerView mRvResult;
    private GroundAdapter mAdapter;
    private EditText mEtSearch;
    private ImageView mIvClear;
    private ArrayList<CircleServer> servers;

    public static void actionStart(Context context, ArrayList<CircleServer> servers) {
        Intent intent = new Intent(context, SearchGroundActivity.class);
        if (!CollectionUtils.isEmpty(servers)) {
            new Gson().toJson(servers);
            intent.putParcelableArrayListExtra("servers", servers);
        }
        context.startActivity(intent);
    }

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_search_ground;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        servers = getIntent().getParcelableArrayListExtra("servers");
        mRvResult = findViewById(R.id.rv_result);
        mEtSearch = findViewById(R.id.et_search);
        mEtSearch.requestFocus();
        mIvClear = findViewById(R.id.iv_clear);
    }


    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(GroundViewModel.class);
        mViewModel.joinServerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer data) {
                    if (data != null) {
                        //存入缓存
                        AppUserInfoManager.getInstance().getUserJoinedSevers().put(data.serverId, data);
                        ToastUtils.showShort(getString(io.agora.service.R.string.circle_join_in_server_success));
                        //发送广播
                        LiveEventBus.get(Constants.SERVER_CHANGED).post(data);
                    }
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    if(!TextUtils.isEmpty(message)) {
                        ToastUtils.showShort(message);
                    }
                }
            });
        });
        mEtSearch.addTextChangedListener(this);
        mEtSearch.setOnEditorActionListener(this);
    }

    @Override
    protected void initData() {
        StaggeredGridLayoutManager layoutManager = new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL);
        mRvResult.setLayoutManager(layoutManager);
        mAdapter = new GroundAdapter(false);
        mAdapter.setOnItemClickListener(this);
        mRvResult.setAdapter(mAdapter);
        mAdapter.setData(servers);
    }

    private void getServerListByKey(String key) {
        mViewModel.getServerListByKey(key).observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleServer>>() {
                @Override
                public void onSuccess(@Nullable List<CircleServer> data) {
                    mAdapter.setData(data, key);
                    hideKeyboard();
                    if (CollectionUtils.isEmpty(data)) {
                        ToastUtils.showShort(getString(io.agora.service.R.string.circle_no_result));
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
    }

    public void onClear(View v) {
        mEtSearch.setText("");
        mAdapter.clearData();
    }

    public void onCancel(View v) {
        finish();
    }

    public void onSeach(View v) {
        doSearch();
    }

    @Override
    public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

    }

    @Override
    public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

    }

    @Override
    public void afterTextChanged(Editable editable) {
        String key = mEtSearch.getText().toString();
        if (key.length() > 0) {
            mIvClear.setVisibility(View.VISIBLE);
        } else {
            mIvClear.setVisibility(View.GONE);
        }
    }

    @Override
    public boolean onEditorAction(TextView textView, int actionId, KeyEvent keyEvent) {
        if (actionId == EditorInfo.IME_ACTION_SEARCH) {
            doSearch();
            return true;
        }
        return false;
    }

    private void doSearch() {
        String key = mEtSearch.getText().toString();
        if (TextUtils.isEmpty(key.trim())) {
            ToastUtils.showShort(getString(R.string.keyword_not_empty));
            return;
        }
        getServerListByKey(key);
    }

    @Override
    public void onItemClick(CircleServer circleServer) {
        if (circleServer == null) {
            return;
        }
        if (AppUserInfoManager.getInstance().getUserJoinedSevers().containsKey(circleServer.serverId)) {
            //跳转去首页展示详情
            //跳转到首页，显示社区详情
            Postcard postcard = ARouter.getInstance().build("/app/MainActivity");
            //直接跳转到首页,显示目标server详情
            postcard.withSerializable(Constants.SHOW_MODE, ShowMode.NORMAL);
            postcard.withInt(Constants.NAV_POSITION, 0);
            postcard.withParcelable(Constants.SERVER, circleServer);
            postcard.navigation();
            finish();
        } else {
            //弹框
            DialogJoinServerBinding joinServerBinding = DialogJoinServerBinding.inflate(getLayoutInflater());
            AlertDialog dialog = new AlertDialog.Builder(this)
                    .setContentView(joinServerBinding.getRoot())
                    .setLayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                    .show();
            Glide.with(this).load(circleServer.icon).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(joinServerBinding.ivServer);
            joinServerBinding.tvServerName.setText(circleServer.name);
            joinServerBinding.tvDesc.setText(circleServer.desc);
            joinServerBinding.btnCancel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //跳转到首页预览模式
//                    Postcard postcard = ARouter.getInstance().build("/app/MainActivity");
//                    //直接跳转到首页,显示目标server详情
//                    postcard.withSerializable(Constants.SHOW_MODE, ShowMode.SERVER_PREVIEW);
//                    postcard.withInt(Constants.NAV_POSITION, 0);
//                    postcard.withParcelable(Constants.SERVER, circleServer);
//                    postcard.navigation();
                    dialog.dismiss();
                }
            });
            joinServerBinding.btnJoinImmediately.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mViewModel.joinServer(circleServer.serverId);
                    dialog.dismiss();
                }
            });
        }
    }
}
