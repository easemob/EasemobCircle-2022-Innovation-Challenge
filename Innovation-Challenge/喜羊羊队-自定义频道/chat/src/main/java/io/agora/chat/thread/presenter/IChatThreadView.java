package io.agora.chat.thread.presenter;


import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.easeui.modules.ILoadDataView;

public interface IChatThreadView extends ILoadDataView {

    /**
     * Get thread info success
     * @param thread
     */
    void onGetThreadInfoSuccess(EMChatThread thread);

    /**
     * Get thread info failed
     * @param error
     * @param errorMsg
     */
    void onGetThreadInfoFail(int error, String errorMsg);

    /**
     * Join thread success or have joined
     * @param thread
     */
    void OnJoinThreadSuccess(EMChatThread thread);

    /**
     * Join thread failed
     * @param error
     * @param errorMsg
     */
    void OnJoinThreadFail(int error, String errorMsg);

    /**
     * Get group info success
     * @param group
     */
    void onGetGroupInfoSuccess(EMGroup group);

    /**
     * Get group info failed
     * @param error
     * @param errorMsg
     */
    void onGetGroupInfoFail(int error, String errorMsg);
}
