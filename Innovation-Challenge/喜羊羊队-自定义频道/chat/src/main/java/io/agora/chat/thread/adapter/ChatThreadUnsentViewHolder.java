package io.agora.chat.thread.adapter;

import android.view.View;

import androidx.annotation.NonNull;

import com.hyphenate.easeui.interfaces.MessageListItemClickListener;
import com.hyphenate.easeui.viewholder.EaseChatRowViewHolder;


public class ChatThreadUnsentViewHolder extends EaseChatRowViewHolder {

    public ChatThreadUnsentViewHolder(@NonNull View itemView, MessageListItemClickListener itemClickListener) {
        super(itemView, itemClickListener);
    }

}
