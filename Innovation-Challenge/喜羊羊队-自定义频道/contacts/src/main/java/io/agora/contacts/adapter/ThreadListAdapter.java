package io.agora.contacts.adapter;

import android.content.Context;
import android.text.Spannable;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseDateUtils;
import com.hyphenate.easeui.utils.EaseSmileUtils;
import com.hyphenate.easeui.widget.EaseImageView;

import java.util.List;

import io.agora.common.base.BaseAdapter;
import io.agora.contacts.R;
import io.agora.service.bean.ThreadData;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;


public class ThreadListAdapter extends BaseAdapter<ThreadData> {
    public ThreadListAdapter(Context context, int layoutId) {
        super(context, layoutId);
    }

    @Override
    public void convert(ViewHolder holder, List<ThreadData> datas, int position) {
        TextView tvChannelName = holder.getView(R.id.tv_channel_name);
        TextView tvUserName = holder.getView(R.id.tv_user_name);
        TextView tvLastMessage = holder.getView(R.id.tv_last_message);
        EaseImageView ivUser = holder.getView(R.id.iv_user);
        TextView tvTime = holder.getView(R.id.tv_time);

        ThreadData threadData = datas.get(position);
        tvChannelName.setText(threadData.getThreadName());

        EMMessage latestMessage = threadData.getLatestMessage();
        if(latestMessage!=null) {
            String from = latestMessage.getFrom();
            tvUserName.setText(from);

            CircleUser user = AppUserInfoManager.getInstance().getUserInfobyId(from);
            if (user != null) {
                Glide.with(mContext).load(user.getAvatar()).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(ivUser);
            }
            Spannable span = EaseSmileUtils.getSmiledText(mContext, EaseCommonUtils.getMessageDigest(latestMessage, mContext));
            tvLastMessage.setText(span, TextView.BufferType.SPANNABLE);
            long msgTime = latestMessage.getMsgTime();
            tvTime.setText(EaseDateUtils.getTimestampSimpleString(mContext,msgTime ));
        }
    }
}
