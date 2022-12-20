package io.agora.service.bean.channel;


public class ChannelUpdateNotifyBean {
    private String serverId;
    private String channelId;
    private String userId;
    private String channelName;
    private String channelDesc;

    public ChannelUpdateNotifyBean(String serverId, String channelId, String userId, String channelName, String channelDesc) {
        this.serverId = serverId;
        this.channelId = channelId;
        this.userId = userId;
        this.channelName = channelName;
        this.channelDesc = channelDesc;
    }

    public String getServerId() {
        return serverId;
    }

    public void setServerId(String serverId) {
        this.serverId = serverId;
    }

    public String getChannelId() {
        return channelId;
    }

    public void setChannelId(String channelId) {
        this.channelId = channelId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }

    public String getChannelDesc() {
        return channelDesc;
    }

    public void setChannelDesc(String channelDesc) {
        this.channelDesc = channelDesc;
    }
}
