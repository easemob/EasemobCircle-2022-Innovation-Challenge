package io.agora.chat.thread.adapter;

import android.view.View;
import android.view.ViewGroup;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.delegate.EaseMessageAdapterDelegate;
import com.hyphenate.easeui.interfaces.MessageListItemClickListener;
import com.hyphenate.easeui.viewholder.EaseChatRowViewHolder;
import com.hyphenate.easeui.widget.chatrow.EaseChatRow;


public class ChatThreadCustomMessageAdapterDelegate extends EaseMessageAdapterDelegate<EMMessage, EaseChatRowViewHolder> {

    @Override
    public boolean isForViewType(EMMessage message, int position) {
        return message.getBooleanAttribute(EaseConstant.MESSAGE_TYPE_RECALL, false);
    }

    @Override
    protected EaseChatRow getEaseChatRow(ViewGroup parent, boolean isSender) {
        return new ChatRowThreadUnsent(parent.getContext(), isSender);
    }

    @Override
    protected EaseChatRowViewHolder createViewHolder(View view, MessageListItemClickListener itemClickListener) {
        return new ChatThreadUnsentViewHolder(view, itemClickListener);
    }
}
