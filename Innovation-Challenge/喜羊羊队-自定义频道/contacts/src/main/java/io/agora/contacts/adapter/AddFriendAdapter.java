package io.agora.contacts.adapter;


import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.bumptech.glide.Glide;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.widget.EaseImageView;

import java.util.List;

import io.agora.common.base.BaseAdapter;
import io.agora.contacts.R;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.utils.EasePresenceUtil;

public class AddFriendAdapter extends BaseAdapter<CircleUser> {


    public AddFriendAdapter(Context context, int layoutId) {
        super(context, layoutId);
    }

    @Override
    public void convert(ViewHolder holder, List<CircleUser> datas, int position) {
        EaseImageView ivAvatar = holder.getView(R.id.iv_user_avatar);
        TextView tvName = holder.getView(R.id.tv_name);
        TextView tvUserId = holder.getView(R.id.tv_user_id);
        EaseImageView ivPresence = holder.getView(R.id.iv_presence);
        Button btnAddFriend = holder.getView(R.id.btn_add_friend);
        CircleUser user = datas.get(position);
        if (user != null) {
            EMPresence presence = AppUserInfoManager.getInstance().getPresences().get(user.getUsername());
            Glide.with(mContext).load(user.getAvatar()).placeholder(io.agora.service.R.drawable.circle_default_avatar).into(ivAvatar);
            tvName.setText(TextUtils.isEmpty(user.getNickname()) ? user.getUsername() : user.getNickname());
            tvUserId.setText(user.getUsername());
            int presenceIcon = EasePresenceUtil.getPresenceIcon(mContext, presence);
            Glide.with(mContext).load(presenceIcon).into(ivPresence);

            if (user.getContact() == 0 || user.getContact() == 1) {//好友=可见联系人+黑名单
                btnAddFriend.setText(mContext.getString(R.string.circle_added));
                btnAddFriend.setEnabled(false);
                btnAddFriend.setTextColor(ContextCompat.getColor(mContext, R.color.color_gray_40f2f2f2));
            } else {
                btnAddFriend.setText(mContext.getString(R.string.circle_add));
                btnAddFriend.setEnabled(true);
                btnAddFriend.setTextColor(Color.WHITE);
            }

            btnAddFriend.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (subViewClickListener != null) {
                        subViewClickListener.onSubViewClick(btnAddFriend, position);
                    }
                }
            });
        }
    }
}
