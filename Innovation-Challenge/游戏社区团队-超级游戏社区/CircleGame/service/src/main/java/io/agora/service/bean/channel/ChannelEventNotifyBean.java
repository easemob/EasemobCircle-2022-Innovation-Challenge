package io.agora.service.bean.channel;


public class ChannelEventNotifyBean {
   private String serverId;
   private String channelId;
   private String userId;

    public ChannelEventNotifyBean(String serverId, String channelId, String userId) {
        this.serverId = serverId;
        this.channelId = channelId;
        this.userId = userId;
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
}
