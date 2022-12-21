package io.agora.chat.thread.widget;

import android.content.Context;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
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
public class EaseChatRowThreadNotify extends EaseChatRowText {
    private TextView tv_thread_notify;

    public EaseChatRowThreadNotify(Context context, boolean isSender) {
        super(context, isSender);
    }

    public EaseChatRowThreadNotify(Context context, EMMessage message, int position, BaseAdapter adapter) {
        super(context, message, position, adapter);
    }

    @Override
    protected void onInflateView() {
        inflater.inflate(R.layout.ease_layout_row_thread_notify, this);
    }

    @Override
    protected void onFindViewById() {
        tv_thread_notify = (TextView) findViewById(R.id.tv_thread_notify);
    }

    @Override
    public void onSetUpView() {
        if(tv_thread_notify == null) {
            return;
        }
        EMTextMessageBody textBody = (EMTextMessageBody) message.getBody();
        String message = textBody.getMessage();
        SpannableStringBuilder builder = new SpannableStringBuilder(message);
        int length = context.getString(R.string.circle_join_the_thread).length();
        builder.setSpan(new ForegroundColorSpan(this.getResources().getColor(R.color.ease_color_brand)), message.length() - length, message.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_thread_notify.setText(builder);
    }
}
