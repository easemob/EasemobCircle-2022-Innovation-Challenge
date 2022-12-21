package com.hyphenate.easeui.modules.chat.interfaces;


import com.hyphenate.easeui.widget.EaseTitleBar;

public interface OnTitleBarFinishInflateListener {
    /**
     * Callback method after TitleBar initialization
     * @param titleBar
     */
    default void onTitleBarFinishInflate(EaseTitleBar titleBar) {}
}
