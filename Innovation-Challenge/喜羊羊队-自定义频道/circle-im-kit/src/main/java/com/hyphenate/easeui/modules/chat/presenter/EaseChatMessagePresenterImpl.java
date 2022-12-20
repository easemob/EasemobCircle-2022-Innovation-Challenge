package com.hyphenate.easeui.modules.chat.presenter;

import android.text.TextUtils;

import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;

import java.util.List;

public class EaseChatMessagePresenterImpl extends EaseChatMessagePresenter {
    protected EMMessage reachFlagMessage;
    /**
     * The flag whether the current conversation is reach the first flag message
     */
    protected boolean isReachFirstFlagMessage = false;

    @Override
    public void joinChatRoom(String username) {
        EMClient.getInstance().chatroomManager().joinChatRoom(username, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {
                runOnUI(() -> {
                    if (isActive()&&mView!=null) {
                        mView.joinChatRoomSuccess(value);
                    }
                });
            }

            @Override
            public void onError(int error, String errorMsg) {
                runOnUI(() -> {
                    if (isActive()&&mView!=null) {
                        mView.joinChatRoomFail(error, errorMsg);
                    }
                });
            }
        });
    }

    @Override
    public void loadLocalMessages(int pageSize) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        List<EMMessage> messages = null;
        try {
            messages = conversation.loadMoreMsgFromDB(null, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (messages == null || messages.isEmpty()) {
            if (isActive()&&mView!=null) {
                runOnUI(() -> mView.loadNoLocalMsg());
            }
            return;
        }
        if (isActive()&&mView!=null) {
            checkMessageStatus(messages);
            List<EMMessage> finalMessages = messages;
            runOnUI(() -> mView.loadLocalMsgSuccess(finalMessages));
        }
    }

    @Override
    public void loadMoreLocalMessages(String msgId, int pageSize) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        if (!isMessageId(msgId)) {
            throw new IllegalArgumentException("please check if set correct msg id");
        }
        List<EMMessage> moreMsgs = null;
        try {
            moreMsgs = conversation.loadMoreMsgFromDB(msgId, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (moreMsgs == null || moreMsgs.isEmpty()) {
            if (isActive()&&mView!=null) {
                runOnUI(() -> mView.loadNoMoreLocalMsg());
            }
            return;
        }
        if (isActive()&&mView!=null) {
            checkMessageStatus(moreMsgs);
            List<EMMessage> finalMoreMsgs = moreMsgs;
            runOnUI(() -> mView.loadMoreLocalMsgSuccess(finalMoreMsgs));
        }
    }

    @Override
    public void loadMoreLocalHistoryMessages(String msgId, int pageSize, EMConversation.EMSearchDirection direction) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        if (!isMessageId(msgId)) {
            throw new IllegalArgumentException("please check if set correct msg id");
        }
        EMMessage message = conversation.getMessage(msgId, true);
        List<EMMessage> messages = conversation.searchMsgFromDB(message.getMsgTime() - 1,
                pageSize, direction);
        if (isActive()&&mView!=null) {
            runOnUI(() -> {
                if (messages == null || messages.isEmpty()) {
                    mView.loadNoMoreLocalHistoryMsg();
                } else {
                    mView.loadMoreLocalHistoryMsgSuccess(messages, direction);
                }
            });

        }
    }

    @Override
    public void loadServerMessages(int pageSize) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        EMClient.getInstance().chatManager().asyncFetchHistoryMessage(conversation.conversationId(),
                conversation.getType(), pageSize, "",
                new EMValueCallBack<EMCursorResult<EMMessage>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMMessage> value) {
                        //需要从数据将下载的数据放到缓存中
                        conversation.loadMoreMsgFromDB("", pageSize);
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadServerMsgSuccess(value.getData(), value.getCursor());
                            }
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadMsgFail(error, errorMsg);
                                loadLocalMessages(pageSize);
                            }
                        });
                    }
                });
    }

    @Override
    public void loadServerMessages(int pageSize, EMConversation.EMSearchDirection direction) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        EMClient.getInstance().chatManager().asyncFetchHistoryMessage(conversation.conversationId(),
                conversation.getType(), pageSize, "", direction,
                new EMValueCallBack<EMCursorResult<EMMessage>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMMessage> value) {
                        conversation.loadMoreMsgFromDB("", pageSize, direction);
                        if (conversation.isChatThread()) {
                            checkIfReachFirstSendMessage(value);
                        }
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadServerMsgSuccess(value.getData(), value.getCursor());
                            }
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadMsgFail(error, errorMsg);
                                loadLocalMessages(pageSize);
                            }
                        });
                    }
                });
    }

    private void checkIfReachFirstSendMessage(EMCursorResult<EMMessage> cursorResult) {
        if (cursorResult == null || isReachFirstFlagMessage) {
            return;
        }
        // if not more data, make isReachFirstFlagMessage to ture
        if (TextUtils.isEmpty(cursorResult.getCursor())) {
            isReachFirstFlagMessage = true;
            isReachFirstFlagMessage();
            return;
        }
        List<EMMessage> data = cursorResult.getData();
        if (data == null || data.isEmpty() || reachFlagMessage == null) {
            return;
        }
        for (EMMessage message : data) {
            String msgId = message.getMsgId();
            String firstSendMessageMsgId = reachFlagMessage.getMsgId();
            if (TextUtils.equals(msgId, firstSendMessageMsgId)) {
                isReachFirstFlagMessage = true;
                isReachFirstFlagMessage();
                break;
            }
        }
    }

    private void isReachFirstFlagMessage() {
        runOnUI(() -> {
            if (isActive()&&mView!=null) {
                mView.reachedLatestThreadMessage();
            }
        });
    }

    @Override
    public void loadMoreServerMessages(String msgId, int pageSize) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        if (!isMessageId(msgId)) {
            throw new IllegalArgumentException("please check if set correct msg id");
        }
        EMClient.getInstance().chatManager().asyncFetchHistoryMessage(conversation.conversationId(),
                conversation.getType(), pageSize, msgId,
                new EMValueCallBack<EMCursorResult<EMMessage>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMMessage> value) {
                        //需要从数据将下载的数据放到缓存中
//                        List<EMMessage> messages = value.getData();
//                        if(messages!=null&&messages.size()>0) {
//                            for (int i = 0; i < messages.size(); i++) {
//                                EMMessage message = messages.get(i);
//                                conversation.insertMessage(message);
//                            }
//                        }
                        conversation.loadMoreMsgFromDB(msgId, pageSize);
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadMoreServerMsgSuccess(value.getData(), value.getCursor());
                            }
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        runOnUI(() -> {
                            if (isActive()&&mView!=null) {
                                mView.loadMsgFail(error, errorMsg);
                                loadMoreLocalMessages(msgId, pageSize);
                            }
                        });
                    }
                });
    }

    @Override
    public void loadMoreServerMessages(String msgId, int pageSize, EMConversation.EMSearchDirection direction) {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        if (!isMessageId(msgId)) {
            throw new IllegalArgumentException("please check if set correct msg id");
        }
        EMClient.getInstance().chatManager().asyncFetchHistoryMessage(conversation.conversationId(),
                conversation.getType(), pageSize, msgId, direction,
                new EMValueCallBack<EMCursorResult<EMMessage>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMMessage> value) {
                        conversation.loadMoreMsgFromDB(msgId, pageSize, direction);
                        if (conversation.isChatThread()) {
                            checkIfReachFirstSendMessage(value);
                        }
                        runOnUI(() -> {
                            if (isActive() && mView != null) {
                                mView.loadMoreServerMsgSuccess(value.getData(), value.getCursor());
                            }
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        runOnUI(() -> {
                            if (isActive() && mView != null) {
                                mView.loadMsgFail(error, errorMsg);
                                loadMoreLocalMessages(msgId, pageSize);
                            }
                        });
                    }
                });
    }

    @Override
    public void refreshCurrentConversation() {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        conversation.markAllMessagesAsRead();
        List<EMMessage> allMessages = conversation.getAllMessages();
        if (isActive()) {
            runOnUI(() -> {
                if (mView != null) {
                    mView.refreshCurrentConSuccess(allMessages, false);
                }
            });
        }
    }

    @Override
    public void refreshToLatest() {
        if (conversation == null) {
            throw new NullPointerException("should first set up with conversation");
        }
        conversation.markAllMessagesAsRead();
        List<EMMessage> allMessages = conversation.getAllMessages();
        if (isActive()) {
            runOnUI(() -> {
                if (mView != null) {
                    mView.refreshCurrentConSuccess(allMessages, true);
                }
            });
        }
    }

    /**
     * 判断是否是消息id
     *
     * @param msgId
     * @return
     */
    public boolean isMessageId(String msgId) {
        if (TextUtils.isEmpty(msgId)) {
            //可以允许消息id为空
            return true;
        }
        EMMessage message = conversation.getMessage(msgId, true);
        return message != null;
    }

    /**
     * Check message's status, if is not success or fail, set to {@link com.hyphenate.chat.EMMessage.Status#FAIL}
     *
     * @param messages
     */
    private void checkMessageStatus(List<EMMessage> messages) {
        if (messages == null || messages.isEmpty()) {
            return;
        }
        for (EMMessage message : messages) {
            if (message.status() != EMMessage.Status.SUCCESS && message.status() != EMMessage.Status.FAIL) {
                message.setStatus(EMMessage.Status.FAIL);
            }
        }
    }
}

