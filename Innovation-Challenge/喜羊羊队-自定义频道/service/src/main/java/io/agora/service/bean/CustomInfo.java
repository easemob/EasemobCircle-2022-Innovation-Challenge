package io.agora.service.bean;


public class CustomInfo {
    private String serverId;
    private String serverName;
    private String serverIcon;
    private String serverDesc;
    private String channelId;
    private String channelName;
    private String channelDesc;

    private boolean isIn;
    private String inviter;//邀请者

    public CustomInfo() {
    }

    public CustomInfo(String serverId, String channelId, boolean isIn) {
        this.serverId = serverId;
        this.channelId = channelId;
        this.isIn = isIn;
    }


    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getServerIcon() {
        return serverIcon;
    }


    public void setServerIcon(String serverIcon) {
        this.serverIcon = serverIcon;
    }

    public String getServerDesc() {
        return serverDesc;
    }

    public void setServerDesc(String serverDesc) {
        this.serverDesc = serverDesc;
    }

    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
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

    public String getChannelDesc() {
        return channelDesc;
    }

    public void setChannelDesc(String channelDesc) {
        this.channelDesc = channelDesc;
    }

    public boolean isIn() {
        return isIn;
    }

    public void setIn(boolean in) {
        isIn = in;
    }

    public String getInviter() {
        return inviter;
    }

    public void setInviter(String inviter) {
        this.inviter = inviter;
    }
}
