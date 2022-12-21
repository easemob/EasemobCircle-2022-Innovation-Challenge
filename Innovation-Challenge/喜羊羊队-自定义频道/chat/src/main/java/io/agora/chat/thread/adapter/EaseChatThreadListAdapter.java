package io.agora.chat.thread.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;
import com.hyphenate.easeui.domain.EaseUser;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseDateUtils;
import com.hyphenate.easeui.utils.EaseSmileUtils;
import com.hyphenate.easeui.utils.EaseUserUtils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import io.agora.chat.databinding.EaseItemRowThreadListBinding;


public class EaseChatThreadListAdapter extends EaseBaseRecyclerViewAdapter<EMChatThread> {
    private Map<String, EMMessage> messageMap = new HashMap<>();
    @Override
    public ViewHolder<EMChatThread> getViewHolder(ViewGroup parent, int viewType) {
        EaseItemRowThreadListBinding binding = EaseItemRowThreadListBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new ThreadListViewHolder(binding);
    }
    
    private class ThreadListViewHolder extends ViewHolder<EMChatThread> {
        private EaseItemRowThreadListBinding binding;

        public ThreadListViewHolder(@NonNull EaseItemRowThreadListBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
            EaseUserUtils.setUserAvatarStyle(binding.avatar);
        }

        @Override
        public void setData(EMChatThread item, int position) {
            String threadId = item.getChatThreadId();
            binding.name.setText(item.getChatThreadName());
            EMMessage message;
            // Prioritize the use of data obtained from the server
            if(messageMap != null &&
                    messageMap.containsKey(threadId) &&
                    messageMap.get(threadId) != null) {
                message = messageMap.get(threadId);
            }else {
                EMConversation conversation = EMClient.getInstance().chatManager().getConversation(threadId,
                        EMConversation.EMConversationType.GroupChat,
                        true, true);
                message = conversation.getLastMessage();
            }

            if(message != null && message.isChatThreadMessage()) {
                binding.groupUser.setVisibility(View.VISIBLE);
                binding.tvNoMsg.setVisibility(View.GONE);
                EaseUser userInfo = EaseUserUtils.getUserInfo(message.getFrom());
                String username;
                if(userInfo == null) {
                    username = message.getFrom();
                }else {
                    username = userInfo.getNickname();
                }
                binding.username.setText(username);
                EaseUserUtils.setUserAvatar(mContext, message.getFrom(), binding.avatar);
                binding.message.setText(EaseSmileUtils.getSmiledText(mContext, EaseCommonUtils.getMessageDigest(message, mContext)));
                binding.time.setText(EaseDateUtils.getTimestampString(mContext, new Date(message.getMsgTime())));
            }else {
                binding.groupUser.setVisibility(View.GONE);
                binding.tvNoMsg.setVisibility(View.VISIBLE);
            }

        }
    }

    /**
     * Set thread latest messages
     * @param messageMap
     */
    public void setLatestMessages(Map<String, EMMessage> messageMap) {
        if(messageMap != null && !messageMap.isEmpty()) {
            this.messageMap.putAll(messageMap);
        }
        notifyDataSetChanged();
    }

    /**
     * Get thread latest message map
     * @return
     */
    public Map<String, EMMessage> getLatestMessages() {
        return this.messageMap;
    }
}
