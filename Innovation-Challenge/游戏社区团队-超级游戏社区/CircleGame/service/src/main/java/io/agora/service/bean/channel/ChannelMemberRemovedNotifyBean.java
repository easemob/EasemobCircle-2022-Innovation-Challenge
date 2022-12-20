package io.agora.service.bean.channel;


public class ChannelMemberRemovedNotifyBean {
    private String serverId;
    private String channelId;
    private String initiator;
    private String member;

    public ChannelMemberRemovedNotifyBean(String serverId, String channelId, String initiator, String member) {
        this.serverId = serverId;
        this.channelId = channelId;
        this.initiator = initiator;
        this.member = member;
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

    public String getInitiator() {
        return initiator;
    }

    public void setInitiator(String initiator) {
        this.initiator = initiator;
    }

    public String getMember() {
        return member;
    }

    public void setMember(String member) {
        this.member = member;
    }
}
