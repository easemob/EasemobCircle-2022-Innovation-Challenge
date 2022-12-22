package io.agora.chat.thread.presenter;

import android.text.TextUtils;

import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMGroup;


public class EaseChatThreadPresenterImpl extends EaseChatThreadPresenter {

    @Override
    public void getThreadInfo(String threadId) {
        EMClient.getInstance().chatThreadManager().getChatThreadFromServer(threadId, new EMValueCallBack<EMChatThread>() {
            @Override
            public void onSuccess(EMChatThread value) {
                if(isActive()) {
                    runOnUI(()->mView.onGetThreadInfoSuccess(value));
                }
            }

            @Override
            public void onError(int error, String errorMsg) {
                if(isActive()) {
                    runOnUI(()->mView.onGetThreadInfoFail(error, errorMsg));
                }
            }
        });
    }

    @Override
    public void joinThread(String threadId) {
        EMClient.getInstance().chatThreadManager().joinChatThread(threadId, new EMValueCallBack<EMChatThread>() {
            @Override
            public void onSuccess(EMChatThread thread) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()->mView.OnJoinThreadSuccess(thread));
            }

            @Override
            public void onError(int code, String error) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()->mView.OnJoinThreadFail(code, error));
            }
        });
    }

    @Override
    public void getGroupInfo(String groupId) {
        EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
        if(group != null && !TextUtils.isEmpty(group.getGroupName())) {
            if(isDestroy()) {
                return;
            }
            runOnUI(()->mView.onGetGroupInfoSuccess(group));
            return;
        }
        EMClient.getInstance().groupManager().asyncGetGroupFromServer(groupId, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()->mView.onGetGroupInfoSuccess(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()->mView.onGetGroupInfoFail(error, errorMsg));
            }
        });
    }
}
