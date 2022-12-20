package io.agora.contacts.notification;


import static io.agora.service.global.Constants.SYSTEM_MESSAGE_FROM;
import static io.agora.service.utils.CircleUtils.filterInviteNotification;
import static io.agora.service.utils.InviteMessageStatus.BEINVITEED;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;

import java.util.List;

import io.agora.contacts.databinding.ItemNotificationMsgBinding;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.utils.InviteMessageStatus;


class NotificationMsgAdapter extends EaseBaseRecyclerViewAdapter<EMMessage> {

    @Override
    public ViewHolder<EMMessage> getViewHolder(ViewGroup parent, int viewType) {
        return new MsgViewHolder(ItemNotificationMsgBinding.inflate(LayoutInflater.from(mContext), parent, false));
    }

    @Override
    public synchronized void setData(List<EMMessage> datas) {
        this.mData = filterInviteNotification(datas);
        notifyDataSetChanged();
    }

    class MsgViewHolder extends ViewHolder<EMMessage> {


        private final ItemNotificationMsgBinding itemBinding;

        public MsgViewHolder(@NonNull ItemNotificationMsgBinding itemBinding) {
            super(itemBinding.getRoot());
            this.itemBinding = itemBinding;
        }

        @Override
        public void setData(EMMessage msg, int position) {

            try {
                String statusParams = msg.getStringAttribute(Constants.SYSTEM_MESSAGE_STATUS);
                InviteMessageStatus status = InviteMessageStatus.valueOf(statusParams);

                if (status == BEINVITEED) {
                    String from = msg.getStringAttribute(SYSTEM_MESSAGE_FROM);
                    EMPresence presence = AppUserInfoManager.getInstance().getPresences().get(from);
                    if (presence == null) {//没有就通知activity订阅
                        mUserPresenceListener.subscribe(from, Constants.PRESENCE_SUBSCRIBE_EXPIRY);
                    } else {
                        CircleUser circleUser = AppUserInfoManager.getInstance().getUserInfobyId(from);
                        if (circleUser != null) {
                            itemBinding.presenceView.setPresenceData(circleUser.getAvatar(), presence);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            itemBinding.btnAccept.setOnClickListener(v -> {
                mItemSubViewListener.onItemSubViewClick(v, position);
            });
            itemBinding.btnRefuse.setOnClickListener(v -> {
                mItemSubViewListener.onItemSubViewClick(v, position);
            });
        }
    }
}
