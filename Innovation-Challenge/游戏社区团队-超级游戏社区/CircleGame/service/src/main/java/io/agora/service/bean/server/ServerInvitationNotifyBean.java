package io.agora.service.bean.server;


import com.hyphenate.chat.EMCircleServerEvent;

public class ServerInvitationNotifyBean {
   private EMCircleServerEvent event;
   private String inviter;

   public ServerInvitationNotifyBean(EMCircleServerEvent event, String inviter) {
      this.event = event;
      this.inviter = inviter;
   }

   public EMCircleServerEvent getEvent() {
      return event;
   }

   public void setEvent(EMCircleServerEvent event) {
      this.event = event;
   }

   public String getInviter() {
      return inviter;
   }

   public void setInviter(String inviter) {
      this.inviter = inviter;
   }
}
