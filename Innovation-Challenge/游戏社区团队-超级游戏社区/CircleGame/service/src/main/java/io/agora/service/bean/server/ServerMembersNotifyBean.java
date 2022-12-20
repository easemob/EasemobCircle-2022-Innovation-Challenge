package io.agora.service.bean.server;


import java.util.List;

public class ServerMembersNotifyBean {
   private String serverId;
   private List<String> ids;

   public ServerMembersNotifyBean(String serverId, List<String> ids) {
      this.serverId = serverId;
      this.ids = ids;
   }

   public String getServerId() {
      return serverId;
   }

   public void setServerId(String serverId) {
      this.serverId = serverId;
   }

   public List<String> getIds() {
      return ids;
   }

   public void setIds(List<String> ids) {
      this.ids = ids;
   }
}
