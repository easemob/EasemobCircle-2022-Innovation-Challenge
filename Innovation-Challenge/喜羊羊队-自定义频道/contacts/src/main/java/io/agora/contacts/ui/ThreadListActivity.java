package io.agora.contacts.ui;

import static com.hyphenate.easeui.constants.EaseConstant.CONVERSATION_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_ID;
import static com.hyphenate.easeui.constants.EaseConstant.PARENT_MSG_ID;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.alibaba.android.arouter.launcher.ARouter;
import com.hyphenate.chat.EMChatThread;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.List;

import io.agora.common.base.BaseAdapter;
import io.agora.contacts.R;
import io.agora.contacts.adapter.ThreadListAdapter;
import io.agora.contacts.databinding.ActivityThreadListBinding;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.bean.ThreadData;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;
import io.agora.service.model.ChannelViewModel;

/**
 * 子区列表页面
 */
public class ThreadListActivity extends BaseInitActivity<ActivityThreadListBinding> implements View.OnClickListener, BaseAdapter.ItemClickListener {

    private CircleChannel channel;
    private ChannelViewModel mViewModel;
    private ThreadListAdapter threadListAdapter;
    private List<ThreadData> mDatas;

    public static void actionStart(Context context, CircleChannel channel) {
        Intent intent = new Intent(context, ThreadListActivity.class);
        intent.putExtra(Constants.CHANNEL, (Parcelable) channel);
        context.startActivity(intent);
    }

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_thread_list;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        threadListAdapter = new ThreadListAdapter(this, R.layout.item_thread_list);
        threadListAdapter.setEmptyLayoutId(R.layout.circle_no_threadlist);
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false);
        mBinding.rvList.setLayoutManager(layoutManager);
        mBinding.rvList.setAdapter(threadListAdapter);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        channel = (CircleChannel) getIntent().getParcelableExtra(Constants.CHANNEL);
        mViewModel = new ViewModelProvider(this).get(ChannelViewModel.class);
        mViewModel.channelThreadListLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<EMChatThread>>() {
                @Override
                public void onSuccess(@Nullable List<EMChatThread> chatThreads) {
                    mViewModel.getThreadLastMessages(chatThreads);
                }
            });
        });
        mViewModel.getThreadLastMessagesLiveData.observe(this, response -> {
            parseResource(response, new OnResourceParseCallback<List<ThreadData>>() {
                @Override
                public void onSuccess(@Nullable List<ThreadData> datas) {
                    mDatas = datas;
                    threadListAdapter.refresh(datas);
                }

                @Override
                public void onError(int code, String message) {
                    super.onError(code, message);
                }
            });
        });

        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(this, new Observer<Object>() {
            @Override
            public void onChanged(Object o) {
                threadListAdapter.notifyDataSetChanged();
            }
        });
        mBinding.ivBack.setOnClickListener(this);
        threadListAdapter.setOnItemClickListener(this);
    }

    @Override
    protected void initData() {
        super.initData();
        mViewModel.getChannlThreadList(channel.channelId);
        mBinding.tvChannelName.setText("#" + channel.name);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_back) {
            finish();
        }
    }

    @Override
    public void onClick(View itemView, int positon) {
        if (mDatas != null && mDatas.size() > positon) {
            ThreadData threadData = mDatas.get(positon);
            //跳转到thread聊天页面
            ARouter.getInstance().build("/app/ChatThreadActivity")
                    .withString(CONVERSATION_ID, threadData.getThreadId())
                    .withString(PARENT_MSG_ID, threadData.getParentMsgId())
                    .withSerializable(PARENT_ID, threadData.getThreadPId())
                    .withString(Constants.THREAD_NAME, threadData.getThreadName())
                    .withString(Constants.CHANNEL_NAME, channel.name)
                    .navigation();
        }
    }
}