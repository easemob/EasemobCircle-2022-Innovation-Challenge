package io.agora.service.bean.server;


public class ServerMemberNotifyBean {
   private String serverId;
   private String userId;

   public ServerMemberNotifyBean(String serverId, String userId) {
      this.serverId = serverId;
      this.userId = userId;
   }

   public String getServerId() {
      return serverId;
   }

   public void setServerId(String serverId) {
      this.serverId = serverId;
   }

   public String getUserId() {
      return userId;
   }

   public void setUserId(String userId) {
      this.userId = userId;
   }
}
