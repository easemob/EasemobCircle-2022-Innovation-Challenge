package io.agora.ground.ui;

import static com.scwang.smartrefresh.layout.constant.RefreshState.None;
import static io.agora.ground.adapter.GroundAdapter.TYPE_EMPTY;
import static io.agora.ground.adapter.GroundAdapter.TYPE_NORMAL;
import static io.agora.ground.adapter.GroundAdapter.TYPE_TOP;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.Postcard;
import com.alibaba.android.arouter.launcher.ARouter;
import com.blankj.utilcode.util.ConvertUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.easeui.utils.ShowMode;
import com.jeremyliao.liveeventbus.LiveEventBus;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshLoadMoreListener;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.agora.common.dialog.AlertDialog;
import io.agora.ground.R;
import io.agora.ground.adapter.GroundAdapter;
import io.agora.ground.callbacks.OnItemClickListener;
import io.agora.ground.databinding.FragmentGroundBinding;
import io.agora.ground.model.GroundViewModel;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.databinding.DialogJoinServerBinding;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;

public class GroundFragment extends BaseInitFragment<FragmentGroundBinding> implements
        View.OnClickListener, OnItemClickListener<CircleServer>, GroundAdapter.OnSearchClickListener, OnRefreshLoadMoreListener {

    private GroundViewModel mViewModel;
    private GroundAdapter mAdapter;
    private ArrayList<CircleServer> datas = new ArrayList<>();


    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_ground;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(GroundViewModel.class);
        mViewModel.serverRecommendListLiveData.observeForever(response -> {
            parseResource(response, new OnResourceParseCallback<List<CircleServer>>() {
                @Override
                public void onSuccess(@Nullable List<CircleServer> data) {
                    if (mBinding.srlRefresh.isRefreshing() || mBinding.srlRefresh.getState() == None) {
                        mBinding.srlRefresh.finishRefresh();
                        datas.clear();
                        if (data != null) {
                            datas.addAll(data);
                            mAdapter.setData(datas);
                        }
                    }
                    if (mBinding.srlRefresh.isLoading()) {
                        mBinding.srlRefresh.finishLoadMore();
                        if (data != null) {
                            datas.addAll(data);
                            mAdapter.addData(data);
                        }
                    }
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                    Log.e("GroundFragment", "message=" + message);
                    ToastUtils.showShort(message);
                }
            });
        });
        mViewModel.joinServerLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<CircleServer>() {
                @Override
                public void onSuccess(@Nullable CircleServer circleServer) {
                    if (circleServer != null) {
                        ToastUtils.showShort(getString(io.agora.service.R.string.circle_join_in_server_success));
                        //发送广播
                        LiveEventBus.get(Constants.SERVER_UPDATED).post(circleServer);

                        //跳转到首页，显示社区详情
                        Postcard postcard = ARouter.getInstance().build("/app/MainActivity");
                        //直接跳转到首页,显示目标server详情
                        postcard.withSerializable(Constants.SHOW_MODE, ShowMode.NORMAL);
                        postcard.withInt(Constants.NAV_POSITION, 0);
                        postcard.withParcelable(Constants.SERVER, circleServer);
                        postcard.navigation();
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
        initListener();
    }


    @Override
    protected void initData() {
        initRv();
        getGroundList();
    }

    private void initRv() {
        mAdapter = new GroundAdapter(mContext, true);
        mAdapter.setOnItemClickListener(this);
        mAdapter.setOnSearchClickListener(this);

        GridLayoutManager layoutManager = new GridLayoutManager(mContext, 2, LinearLayoutManager.VERTICAL, false);
        mBinding.rvGround.setLayoutManager(layoutManager);
        mBinding.rvGround.setAdapter(mAdapter);
        mBinding.rvGround.addOnScrollListener(new RvScrollListener());
        layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                int viewType = mAdapter.getItemViewType(position);
                switch (viewType) {
                    case TYPE_TOP:
                        return 2;
                    case TYPE_NORMAL:
                        return 1;
                    case TYPE_EMPTY:
                        return 2;
                }
                return 2;
            }
        });
    }

    int scrollY = 0;

    @Override
    public void onSearchClick() {
        SearchGroundActivity.actionStart(mContext, datas);
    }

    @Override
    public void onRefresh(RefreshLayout refreshLayout) {
        getGroundList();
    }

    @Override
    public void onLoadMore(RefreshLayout refreshLayout) {
        getGroundList();
    }


    private class RvScrollListener extends RecyclerView.OnScrollListener {
        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            scrollY += dy;
            if (scrollY >= ConvertUtils.dp2px(90)) {
                mBinding.llSearch.setVisibility(View.VISIBLE);
            } else {
                mBinding.llSearch.setVisibility(View.INVISIBLE);
            }
        }
    }


    private void getGroundList() {
        mViewModel.getRecommandServerList();
    }

    protected void initListener() {
        mBinding.srlRefresh.setOnRefreshLoadMoreListener(this);
        mBinding.tvSearch.setOnClickListener(this);
        mBinding.srlRefresh.setEnableLoadMore(false);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.tv_search) {
            SearchGroundActivity.actionStart(mContext, datas);
        }
    }

    @Override
    public void onItemClick(CircleServer circleServer) {
        //判断是否在社区里
        Map<String, CircleServer> userJoinedSevers = AppUserInfoManager.getInstance().getUserJoinedSevers();
        if (!userJoinedSevers.containsKey(circleServer.serverId)) {
            //不在社区里则弹框
            showDialog(circleServer);
        } else {
            //跳转到首页，显示社区详情
            Postcard postcard = ARouter.getInstance().build("/app/MainActivity");
            //直接跳转到首页,显示目标server详情
            postcard.withSerializable(Constants.SHOW_MODE, ShowMode.NORMAL);
            postcard.withInt(Constants.NAV_POSITION, 0);
            postcard.withParcelable(Constants.SERVER, circleServer);
            postcard.navigation();
        }
    }

    private void showDialog(CircleServer circleServer) {
        DialogJoinServerBinding joinServerBinding = DialogJoinServerBinding.inflate(getLayoutInflater());
        AlertDialog dialog = new AlertDialog.Builder(mContext)
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
//                Postcard postcard = ARouter.getInstance().build("/app/MainActivity");
//                //直接跳转到首页,显示目标server详情
//                postcard.withSerializable(Constants.SHOW_MODE, ShowMode.SERVER_PREVIEW);
//                postcard.withInt(Constants.NAV_POSITION, 0);
//                postcard.withParcelable(Constants.SERVER, circleServer);
//                postcard.navigation();
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