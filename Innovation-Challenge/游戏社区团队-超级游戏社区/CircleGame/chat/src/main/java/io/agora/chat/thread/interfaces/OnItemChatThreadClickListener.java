package io.agora.chat.thread.interfaces;

import android.view.View;

import com.hyphenate.chat.EMChatThread;


/**
 * Thread item click listener
 */
public interface OnItemChatThreadClickListener {
    /**
     * Thread item click
     * @param view
     * @param thread
     * @param messageId
     */
    void onItemClick(View view, EMChatThread thread, String messageId);
}
