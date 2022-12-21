package com.hyphenate.easeui.modules.chat.interfaces;


import com.hyphenate.easeui.modules.chat.EaseChatLayout;

public interface OnChatLayoutFinishInflateListener extends OnTitleBarFinishInflateListener {

    /**
     * Callback method after EaseChatLayout initialization
     * @param chatLayout
     */
    default void onChatListFinishInflate(EaseChatLayout chatLayout) {}
}
