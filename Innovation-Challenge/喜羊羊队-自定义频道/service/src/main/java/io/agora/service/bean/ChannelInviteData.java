package io.agora.service.bean;


public class ChannelInviteData {
    private String serverId;
    private String channelId;

    public ChannelInviteData(String serverId, String channelId) {
        this.serverId = serverId;
        this.channelId = channelId;
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
}
