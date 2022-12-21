package io.agora.chat.thread.presenter;

import android.text.TextUtils;

import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMMessage;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;


public class EaseChatThreadListPresenterImpl extends EaseChatThreadListPresenter {
    @Override
    public void getJoinedThreadList(String parentId, int limit, String cursor) {
        EMClient.getInstance().chatThreadManager().getJoinedChatThreadsFromServer(parentId, limit, cursor,
                new EMValueCallBack<EMCursorResult<EMChatThread>>() {
            @Override
            public void onSuccess(EMCursorResult<EMChatThread> value) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(() -> {
                    if(value == null) {
                        mView.getNoJoinedThreadListData();
                        return;
                    }
                    mView.getJoinedThreadListSuccess(value);
                    getThreadIdList(value.getData());
                });
            }

            @Override
            public void onError(int error, String errorMsg) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()-> {
                    mView.getJoinedThreadListFail(error, errorMsg);
                });
            }
        });
    }

    @Override
    public void getMoreJoinedThreadList(String parentId, int limit, String cursor) {
        EMClient.getInstance().chatThreadManager().getJoinedChatThreadsFromServer(parentId, limit, cursor,
                new EMValueCallBack<EMCursorResult<EMChatThread>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMChatThread> value) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            if(value == null) {
                                mView.getNoMoreJoinedThreadList();
                                return;
                            }
                            List<EMChatThread> data = value.getData();
                            if(data == null || data.size() == 0) {
                                mView.getNoMoreJoinedThreadList();
                                return;
                            }
                            mView.getMoreJoinedThreadListSuccess(value);
                            if(data.size() < limit) {
                                mView.getNoMoreJoinedThreadList();
                            }
                            getThreadIdList(data);
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            mView.getJoinedThreadListFail(error, errorMsg);
                        });
                    }
                });
    }

    @Override
    public void getThreadList(String parentId, int limit, String cursor) {
        EMClient.getInstance().chatThreadManager().getChatThreadsFromServer(parentId, limit, cursor,
                new EMValueCallBack<EMCursorResult<EMChatThread>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMChatThread> value) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            if(value == null) {
                                mView.getNoThreadListData();
                                return;
                            }
                            List<EMChatThread> data = value.getData();
                            if(data == null || data.size() == 0) {
                                mView.getNoThreadListData();
                                return;
                            }
                            mView.getThreadListSuccess(value);
                            getThreadIdList(data);
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            mView.getThreadListFail(error, errorMsg);
                        });
                    }
                });
    }

    @Override
    public void getMoreThreadList(String parentId, int limit, String cursor) {
        EMClient.getInstance().chatThreadManager().getChatThreadsFromServer(parentId, limit, cursor,
                new EMValueCallBack<EMCursorResult<EMChatThread>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMChatThread> value) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            if(value == null) {
                                mView.getNoMoreThreadList();
                                return;
                            }
                            List<EMChatThread> data = value.getData();
                            if(data == null || data.size() == 0) {
                                mView.getNoMoreThreadList();
                                return;
                            }
                            mView.getMoreThreadListSuccess(value);
                            if(data.size() < limit) {
                                mView.getNoMoreThreadList();
                            }
                            getThreadIdList(data);
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        if(isDestroy()) {
                            return;
                        }
                        runOnUI(()-> {
                            mView.getThreadListFail(error, errorMsg);
                        });
                    }
                });
    }

    @Override
    public void getThreadLatestMessages(List<String> threadIds) {
        EMClient.getInstance().chatThreadManager().getChatThreadLatestMessage(threadIds, new EMValueCallBack<Map<String, EMMessage>>() {
            @Override
            public void onSuccess(Map<String, EMMessage> value) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()-> {
                    if(value == null || value.isEmpty()) {
                        mView.getNoDataLatestThreadMessages();
                        return;
                    }
                    mView.getLatestThreadMessagesSuccess(value);
                });
            }

            @Override
            public void onError(int error, String errorMsg) {
                if(isDestroy()) {
                    return;
                }
                runOnUI(()-> {
                    mView.getLatestThreadMessagesFail(error, errorMsg);
                });
            }
        });
    }

    @Override
    public void getThreadParent(String parentId) {
        EMGroup group = EMClient.getInstance().groupManager().getGroup(parentId);
        if(group == null || TextUtils.isEmpty(group.getGroupName())) {
            EMClient.getInstance().groupManager().asyncGetGroupFromServer(parentId, new EMValueCallBack<EMGroup>() {
                @Override
                public void onSuccess(EMGroup value) {
                    if(isDestroy()) {
                        return;
                    }
                    runOnUI(()-> {
                        mView.getThreadParentInfoSuccess(value);
                    });
                }

                @Override
                public void onError(int error, String errorMsg) {
                    if(isDestroy()) {
                        return;
                    }
                    runOnUI(()-> {
                        mView.getThreadParentInfoFail(error, errorMsg);
                    });
                }
            });
        }else {
            if(isDestroy()) {
                return;
            }
            runOnUI(()-> {
                mView.getThreadParentInfoSuccess(group);
            });
        }
    }

    private void getThreadIdList(List<EMChatThread> data) {
        if(data == null || data.size() <= 0) {
            return;
        }
        List<String> threadIds = new ArrayList<>();
        for(int i = 0; i < data.size(); i++) {
            threadIds.add(data.get(i).getChatThreadId());
        }
        if(isDestroy()) {
            return;
        }
        mView.getThreadIdList(threadIds);
    }
}
