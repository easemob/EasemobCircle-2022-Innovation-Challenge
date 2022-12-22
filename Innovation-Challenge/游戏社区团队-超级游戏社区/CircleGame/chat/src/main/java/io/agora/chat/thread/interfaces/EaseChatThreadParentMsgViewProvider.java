package io.agora.chat.thread.interfaces;

import android.view.View;

import com.hyphenate.chat.EMMessage;

public interface EaseChatThreadParentMsgViewProvider {
    /**
     * Get thread parent msg view
     * @param message
     * @return
     */
    View parentMsgView(EMMessage message);
}
