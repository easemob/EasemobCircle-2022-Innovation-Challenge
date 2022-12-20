package io.agora.service.bean.channel;


import com.hyphenate.chat.EMCircleChannelInviteInfo;

public class ChannelInvitationNotifyBean {
    private EMCircleChannelInviteInfo inviteInfo;
    private String inviter;

    public ChannelInvitationNotifyBean(EMCircleChannelInviteInfo inviteInfo, String inviter) {
        this.inviteInfo = inviteInfo;
        this.inviter = inviter;
    }

    public EMCircleChannelInviteInfo getInviteInfo() {
        return inviteInfo;
    }

    public void setInviteInfo(EMCircleChannelInviteInfo inviteInfo) {
        this.inviteInfo = inviteInfo;
    }

    public String getInviter() {
        return inviter;
    }

    public void setInviter(String inviter) {
        this.inviter = inviter;
    }
}
