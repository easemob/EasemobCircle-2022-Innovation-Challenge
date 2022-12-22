package io.agora.home.adapter;


import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.alibaba.android.arouter.utils.TextUtils;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.widget.EaseImageView;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.common.base.BaseAdapter;
import io.agora.home.R;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.widget.EasePresenceView;

public class ConversationListAdapter extends BaseAdapter<EMConversation> {

    private ConcurrentHashMap<String, EMPresence> presences;

    public ConversationListAdapter(Context context) {
        super(context, R.layout.item_conversation);
    }

    @Override
    public void convert(ViewHolder holder, List<EMConversation> datas, int position) {
        TextView tvUnread = holder.getView(R.id.tv_unread);
        EasePresenceView presenceView = holder.getView(R.id.pv_conversation);
        EaseImageView ivMute = holder.getView(R.id.iv_mute);
        EMConversation conversation = datas.get(position);
        int unreadMsgCount = conversation.getUnreadMsgCount();
        if (unreadMsgCount > 0) {
            tvUnread.setText(EaseCommonUtils.handleBigNum(unreadMsgCount));
            tvUnread.setVisibility(View.VISIBLE);
        } else {
            tvUnread.setVisibility(View.GONE);
        }
        if (conversation.getType() == EMConversation.EMConversationType.Chat) {
            CircleUser circleUser = AppUserInfoManager.getInstance().getUserInfobyId(conversation.conversationId());
            if (circleUser != null && !TextUtils.isEmpty(circleUser.getUsername())) {
                EMPresence presence = AppUserInfoManager.getInstance().getPresences().get(circleUser.getUsername());
                if (presence != null) {
                    presenceView.setPresenceData(circleUser.getAvatar(), presence);
                } else {
                    userPresenceListener.subscribe(circleUser.getUsername(), Constants.PRESENCE_SUBSCRIBE_EXPIRY);
                }
            }
        }
    }

    @Override
    public int getEmptyLayoutId() {
        return io.agora.service.R.layout.layout_empty;
    }

    public void setPresenceData(ConcurrentHashMap<String, EMPresence> presences) {
        this.presences = presences;
    }
}
