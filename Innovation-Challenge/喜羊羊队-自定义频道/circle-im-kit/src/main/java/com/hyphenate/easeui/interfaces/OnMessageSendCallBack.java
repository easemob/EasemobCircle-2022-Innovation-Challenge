package com.hyphenate.easeui.interfaces;

import com.hyphenate.chat.EMMessage;

public interface OnMessageSendCallBack {
    /**
     * Callback after the message is sent successfully
     * @param message
     */
    default void onSuccess(EMMessage message){}

    /**
     * Wrong message in chat
     * @param code
     * @param errorMsg
     */
    void onError(int code, String errorMsg);
}
