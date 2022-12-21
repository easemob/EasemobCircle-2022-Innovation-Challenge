package io.agora.chat.delegate;

import android.view.View;
import android.view.ViewGroup;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.delegate.EaseMessageAdapterDelegate;
import com.hyphenate.easeui.interfaces.MessageListItemClickListener;
import com.hyphenate.easeui.model.styles.EaseMessageListItemStyle;
import com.hyphenate.easeui.viewholder.EaseChatRowViewHolder;
import com.hyphenate.easeui.viewholder.EaseFileViewHolder;
import com.hyphenate.easeui.widget.chatrow.EaseChatRow;

import io.agora.chat.chatrow.CircleChatRowFile;
import io.agora.chat.viewholder.CircleFileViewHolder;

/**
 * 文件代理类
 */
public class CircleFileAdapterDelegate extends EaseMessageAdapterDelegate<EMMessage, EaseChatRowViewHolder> {

    public CircleFileAdapterDelegate() {
    }

    public CircleFileAdapterDelegate(MessageListItemClickListener itemClickListener, EaseMessageListItemStyle itemStyle) {
        super(itemClickListener, itemStyle);
    }

    @Override
    public boolean isForViewType(EMMessage item, int position) {
        return item.getType() == EMMessage.Type.FILE;
    }

    @Override
    protected EaseChatRow getEaseChatRow(ViewGroup parent, boolean isSender) {
        return new CircleChatRowFile(parent.getContext(), isSender);
    }

    @Override
    protected EaseChatRowViewHolder createViewHolder(View view, MessageListItemClickListener itemClickListener) {
        return new CircleFileViewHolder(view, itemClickListener);
    }
}
