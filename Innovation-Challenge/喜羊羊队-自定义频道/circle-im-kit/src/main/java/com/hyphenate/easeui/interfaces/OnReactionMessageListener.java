package com.hyphenate.easeui.interfaces;


import com.hyphenate.chat.EMMessage;

public interface OnReactionMessageListener {

    /**
     * add reaction success
     *
     * @param message
     */
    void addReactionMessageSuccess(EMMessage message);

    /**
     * add reaction fail
     *
     * @param message
     * @param code
     * @param error
     */
    void addReactionMessageFail(EMMessage message, int code, String error);

    /**
     * remove reaction success
     *
     * @param message
     */
    void removeReactionMessageSuccess(EMMessage message);

    /**
     * remove reaction fail
     *
     * @param message
     * @param code
     * @param error
     */
    void removeReactionMessageFail(EMMessage message, int code, String error);

}
