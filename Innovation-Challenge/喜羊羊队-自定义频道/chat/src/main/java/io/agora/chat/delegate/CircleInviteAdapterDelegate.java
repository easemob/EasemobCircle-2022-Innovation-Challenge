package io.agora.chat.delegate;

import android.view.View;
import android.view.ViewGroup;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.delegate.EaseMessageAdapterDelegate;
import com.hyphenate.easeui.interfaces.MessageListItemClickListener;
import com.hyphenate.easeui.model.styles.EaseMessageListItemStyle;
import com.hyphenate.easeui.viewholder.EaseChatRowViewHolder;
import com.hyphenate.easeui.widget.chatrow.EaseChatRow;

import io.agora.chat.chatrow.CircleChatRowInvite;
import io.agora.chat.chatrow.CircleChatRowText;
import io.agora.chat.viewholder.CircleInviteViewHolder;
import io.agora.chat.viewholder.CircleTextViewHolder;

/**
 * 文本代理类
 */
public class CircleInviteAdapterDelegate extends EaseMessageAdapterDelegate<EMMessage, EaseChatRowViewHolder> {

    public CircleInviteAdapterDelegate() {
    }

    public CircleInviteAdapterDelegate(MessageListItemClickListener itemClickListener, EaseMessageListItemStyle itemStyle) {
        super(itemClickListener, itemStyle);
    }

    @Override
    public boolean isForViewType(EMMessage item, int position) {
        return item.getType() == EMMessage.Type.CUSTOM;
    }

    @Override
    protected EaseChatRow getEaseChatRow(ViewGroup parent, boolean isSender) {
        return new CircleChatRowInvite(parent.getContext(), isSender);
    }

    @Override
    public EaseChatRowViewHolder createViewHolder(View view, MessageListItemClickListener itemClickListener) {
        return new CircleInviteViewHolder(view, itemClickListener);
    }

}
