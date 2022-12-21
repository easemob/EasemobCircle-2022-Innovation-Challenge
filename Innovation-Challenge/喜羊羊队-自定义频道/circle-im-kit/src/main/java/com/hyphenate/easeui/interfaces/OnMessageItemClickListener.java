package com.hyphenate.easeui.interfaces;

import android.view.View;

import com.hyphenate.chat.EMMessage;


public interface OnMessageItemClickListener {
    /**
     * Click on the message bubble area
     * @param message
     * @return
     */
    boolean onBubbleClick(EMMessage message);

    /**
     * Long press the message bubble area
     * @param v
     * @param message
     * @return
     */
    boolean onBubbleLongClick(View v, EMMessage message);

    /**
     * Click on the avatar
     * @param username
     */
    void onUserAvatarClick(String username);

    /**
     * Long press on the avatar
     * @param username
     */
    void onUserAvatarLongClick(String username);

    /**
     * Click on thread region
     * @param messageId
     * @param threadId
     * @return
     */
    default boolean onThreadClick(String messageId, String threadId) {
        return false;
    }

    /**
     * Long press on thread region
     * @param v
     * @param messageId
     * @param threadId
     * @return
     */
    default boolean onThreadLongClick(View v, String messageId, String threadId) {
        return false;
    }
}
