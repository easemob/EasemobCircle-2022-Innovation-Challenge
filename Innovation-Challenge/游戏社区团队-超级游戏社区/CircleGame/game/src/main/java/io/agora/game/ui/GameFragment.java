package io.agora.game.ui;

import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;


import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.easeui.interfaces.OnItemClickListener;

import java.util.ArrayList;
import java.util.List;

import io.agora.common.base.BaseActivity;
import io.agora.game.R;
import io.agora.game.adapter.GameAdapter;
import io.agora.game.app.GameInit;

import io.agora.game.bean.ChildElements;
import io.agora.game.bean.ListElementsBean;
import io.agora.game.databinding.FragmentGameBinding;
import io.agora.game.net.QObserver;
import io.agora.game.utils.BannerRuleUtil;
import io.agora.service.base.BaseInitFragment;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class GameFragment extends BaseInitFragment<FragmentGameBinding> {

    GameAdapter mAdapter;
    List<ListElementsBean> mElementsBeans;
    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_game;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        TextView leftTitle = mBinding.toolbarGame.getLeftTitle();
        leftTitle.setText(getString(R.string.game_information));
        leftTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        leftTitle.setVisibility(View.VISIBLE);

        initRv();
    }


    @Override
    protected void initData() {
        mElementsBeans = new ArrayList<>();
        GameInit.getGameInit().getApi().getListElements().subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new QObserver<List<ListElementsBean>>((BaseActivity) mContext, false) {

                    @Override
                    public void next(List<ListElementsBean> beanList) {
                        if (beanList != null && !beanList.isEmpty()) {
                            setBannerData(beanList.get(0).getChildElements());
                           beanList.remove(0);
                            mElementsBeans.addAll(beanList);
                            mAdapter.setData(beanList);
                        }
                    }
                });
    }

    private void setBannerData(List<ChildElements> childElements){
        BannerRuleUtil.initXBannerAspectRatio(mContext, mBinding.banner.cardview, 139, 70);
        ArrayList<ChildElements> bannerList = new ArrayList<>();
        for (ChildElements e: childElements) {
            bannerList.add(e);
        }
        mBinding.banner.bannerStudy.setBannerData(bannerList);
        BannerRuleUtil.initXBanner(mContext, mBinding.banner.bannerStudy, bannerList, true, "HydtListActivity");
    }

    private void initRv() {
        mAdapter = new GameAdapter(mContext);
        mBinding.rvGame.setLayoutManager(new LinearLayoutManager(mContext));
        mBinding.rvGame.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.VERTICAL));
        mBinding.rvGame.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                ListElementsBean listElementsBean = mElementsBeans.get(position);
                GameContentActivity.actionStart(mContext,listElementsBean.getContentUrl());
            }
        });
    }
}