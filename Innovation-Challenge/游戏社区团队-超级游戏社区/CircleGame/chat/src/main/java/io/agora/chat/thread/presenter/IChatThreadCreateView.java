package io.agora.chat.thread.presenter;


import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.modules.ILoadDataView;

public interface IChatThreadCreateView extends ILoadDataView {

    /**
     * Failed to send message
     * @param message
     */
    void sendMessageFail(String message);

    /**
     * Before sending a message, add message attributes, such as setting ext, etc.
     * @param message
     */
    void addMsgAttrBeforeSend(EMMessage message);

    /**
     * message send success
     * @param message
     */
    void onPresenterMessageSuccess(EMMessage message);

    /**
     * message send fail
     * @param message
     * @param code
     * @param error
     */
    void onPresenterMessageError(EMMessage message, int code, String error);

    /**
     * message in sending progress
     * @param message
     * @param progress
     */
    void onPresenterMessageInProgress(EMMessage message, int progress);

    /**
     * Complete the message sending action
     * @param message
     */
    void sendMessageFinish(EMMessage message);

    /**
     * Create thread success
     * @param thread
     * @param message
     */
    void onCreateThreadSuccess(EMChatThread thread, EMMessage message);

    /**
     * Create thread failed
     * @param errorCode
     * @param message
     */
    void onCreateThreadFail(int errorCode, String message);
}
