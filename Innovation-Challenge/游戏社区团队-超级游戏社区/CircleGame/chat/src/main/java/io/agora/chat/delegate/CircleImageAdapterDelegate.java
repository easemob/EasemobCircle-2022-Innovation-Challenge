package io.agora.chat.delegate;

import android.view.View;
import android.view.ViewGroup;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.delegate.EaseMessageAdapterDelegate;
import com.hyphenate.easeui.interfaces.MessageListItemClickListener;
import com.hyphenate.easeui.model.styles.EaseMessageListItemStyle;
import com.hyphenate.easeui.viewholder.EaseChatRowViewHolder;
import com.hyphenate.easeui.viewholder.EaseImageViewHolder;
import com.hyphenate.easeui.widget.chatrow.EaseChatRow;
import com.hyphenate.easeui.widget.chatrow.EaseChatRowImage;

import io.agora.chat.chatrow.CircleChatRowImage;
import io.agora.chat.viewholder.CircleImageViewHolder;

/**
 * 图片代理类
 */
public class CircleImageAdapterDelegate extends EaseMessageAdapterDelegate<EMMessage, EaseChatRowViewHolder> {

    public CircleImageAdapterDelegate() {
    }

    public CircleImageAdapterDelegate(MessageListItemClickListener itemClickListener, EaseMessageListItemStyle itemStyle) {
        super(itemClickListener, itemStyle);
    }

    @Override
    public boolean isForViewType(EMMessage item, int position) {
        return item.getType() == EMMessage.Type.IMAGE;
    }

    @Override
    protected EaseChatRow getEaseChatRow(ViewGroup parent, boolean isSender) {
        return new CircleChatRowImage(parent.getContext(), isSender);
    }

    @Override
    protected EaseChatRowViewHolder createViewHolder(View view, MessageListItemClickListener itemClickListener) {
        return new CircleImageViewHolder(view, itemClickListener);
    }
}
