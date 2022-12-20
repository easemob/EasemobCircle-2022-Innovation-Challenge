package io.agora.chat.thread.adapter;

import android.content.Context;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.easeui.widget.chatrow.EaseChatRowText;

import io.agora.chat.R;


/**
 * big emoji icons
 *
 */
public class ChatRowThreadUnsent extends EaseChatRowText {
    private TextView tv_chatcontent;

    public ChatRowThreadUnsent(Context context, boolean isSender) {
        super(context, isSender);
    }

    public ChatRowThreadUnsent(Context context, EMMessage message, int position, BaseAdapter adapter) {
        super(context, message, position, adapter);
    }

    @Override
    protected void onInflateView() {
        inflater.inflate(!showSenderType ? R.layout.chat_row_received_unsent
                : R.layout.chat_row_sent_unsent, this);
    }

    @Override
    protected void onFindViewById() {
        tv_chatcontent = (TextView) findViewById(R.id.tv_chatcontent);
    }

    @Override
    public void onSetUpView() {
        if(tv_chatcontent == null) {
            return;
        }
        EMTextMessageBody textBody = (EMTextMessageBody) message.getBody();
        String message = textBody.getMessage();
        tv_chatcontent.setText(message);
    }
}
