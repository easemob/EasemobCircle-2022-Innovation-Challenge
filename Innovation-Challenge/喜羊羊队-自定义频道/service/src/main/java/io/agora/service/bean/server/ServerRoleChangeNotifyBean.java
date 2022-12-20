package io.agora.service.bean.server;


import com.hyphenate.chat.EMCircleUserRole;

public class ServerRoleChangeNotifyBean {
   private String serverId;
   private String member;
   private EMCircleUserRole role;

   public ServerRoleChangeNotifyBean(String serverId, String member, EMCircleUserRole role) {
      this.serverId = serverId;
      this.member = member;
      this.role = role;
   }

   public String getServerId() {
      return serverId;
   }

   public void setServerId(String serverId) {
      this.serverId = serverId;
   }

   public String getMember() {
      return member;
   }

   public void setMember(String member) {
      this.member = member;
   }

   public EMCircleUserRole getRole() {
      return role;
   }

   public void setRole(EMCircleUserRole role) {
      this.role = role;
   }
}
