package io.agora.chat.thread.presenter;


import com.hyphenate.easeui.modules.EaseBasePresenter;
import com.hyphenate.easeui.modules.ILoadDataView;

public abstract class EaseChatThreadPresenter extends EaseBasePresenter {
    protected IChatThreadView mView;

    @Override
    public void attachView(ILoadDataView view) {
        mView = (IChatThreadView) view;
    }

    @Override
    public void detachView() {
        mView = null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        detachView();
    }

    /**
     * Get thread info
     * @param threadId
     */
    public abstract void getThreadInfo(String threadId);

    /**
     * Join thread
     * @param threadId
     */
    public abstract void joinThread(String threadId);

    /**
     * Get group Info
     * @param groupId
     */
    public abstract void getGroupInfo(String groupId);
}
