package io.agora.service.bean;


import com.hyphenate.chat.EMMessage;

import java.io.Serializable;

public class ThreadData implements Serializable {

    private String threadName;
    private String threadId;
    private String threadPId;
    private EMMessage latestMessage;
    private String parentMsgId;
    private String serverId;

    public ThreadData(String threadName, String threadId, String threadPId) {
        this.threadName = threadName;
        this.threadId = threadId;
        this.threadPId = threadPId;
    }
    public ThreadData(String threadName, String threadId, String threadPId, EMMessage latestMessage,String parentMsgId) {
        this.threadName = threadName;
        this.threadId = threadId;
        this.threadPId = threadPId;
        this.latestMessage = latestMessage;
        this.parentMsgId=parentMsgId;
    }
    public ThreadData(String threadName, String threadId, String threadPId, EMMessage latestMessage,String parentMsgId,String serverId) {
        this.threadName = threadName;
        this.threadId = threadId;
        this.threadPId = threadPId;
        this.latestMessage = latestMessage;
        this.parentMsgId=parentMsgId;
        this.serverId=serverId;
    }

    public String getThreadName() {
        return threadName;
    }

    public void setThreadName(String threadName) {
        this.threadName = threadName;
    }

    public String getThreadId() {
        return threadId;
    }

    public void setThreadId(String threadId) {
        this.threadId = threadId;
    }

    public String getThreadPId() {
        return threadPId;
    }

    public void setThreadPId(String threadPId) {
        this.threadPId = threadPId;
    }

    public EMMessage getLatestMessage() {
        return latestMessage;
    }

    public void setLatestMessage(EMMessage latestMessage) {
        this.latestMessage = latestMessage;
    }

    public String getParentMsgId() {
        return parentMsgId;
    }

    public void setParentMsgId(String parentMsgId) {
        this.parentMsgId = parentMsgId;
    }

    public String getServerId() {
        return serverId;
    }

    public void setServerId(String serverId) {
        this.serverId = serverId;
    }
}
