package io.agora.service.bean.channel;


import java.util.List;

public class ChannelMuteNotifyBean {

    private String serverId;
    private String channelId;
    private boolean isMuted;
    List<String> muteMembers;

    public ChannelMuteNotifyBean(String serverId, String channelId, boolean isMuted, List<String> muteMembers) {
        this.serverId = serverId;
        this.channelId = channelId;
        this.isMuted = isMuted;
        this.muteMembers = muteMembers;
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

    public boolean isMuted() {
        return isMuted;
    }

    public void setMuted(boolean muted) {
        isMuted = muted;
    }

    public List<String> getMuteMembers() {
        return muteMembers;
    }

    public void setMuteMembers(List<String> muteMembers) {
        this.muteMembers = muteMembers;
    }
}
