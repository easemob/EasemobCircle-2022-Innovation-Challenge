package com.hyphenate.easeui.modules.chat.interfaces;


import com.hyphenate.chat.EMMessage;

public interface OnRecallMessageResultListener {
    /**
     * Recall successful
     * @param originalMessage The message was unsent
     * @param notification  The notification message
     */
    void recallSuccess(EMMessage originalMessage, EMMessage notification);

    /**
     * Recall failed
     * @param code
     * @param errorMsg
     */
    void recallFail(int code, String errorMsg);
}
