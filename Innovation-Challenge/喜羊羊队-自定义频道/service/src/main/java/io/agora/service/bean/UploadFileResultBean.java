package io.agora.service.bean;


import java.util.List;

public class UploadFileResultBean {

   private String path;
   private String uri;
   private Long timestamp;
   private String organization;
   private String application;
   private List<Entities> entities;
   private String action;
   private Integer duration;
   private String applicationName;

   public String getPath() {
      return path;
   }

   public void setPath(String path) {
      this.path = path;
   }

   public String getUri() {
      return uri;
   }

   public void setUri(String uri) {
      this.uri = uri;
   }

   public Long getTimestamp() {
      return timestamp;
   }

   public void setTimestamp(Long timestamp) {
      this.timestamp = timestamp;
   }

   public String getOrganization() {
      return organization;
   }

   public void setOrganization(String organization) {
      this.organization = organization;
   }

   public String getApplication() {
      return application;
   }

   public void setApplication(String application) {
      this.application = application;
   }

   public List<Entities> getEntities() {
      return entities;
   }

   public void setEntities(List<Entities> entities) {
      this.entities = entities;
   }

   public String getAction() {
      return action;
   }

   public void setAction(String action) {
      this.action = action;
   }

   public Integer getDuration() {
      return duration;
   }

   public void setDuration(Integer duration) {
      this.duration = duration;
   }

   public String getApplicationName() {
      return applicationName;
   }

   public void setApplicationName(String applicationName) {
      this.applicationName = applicationName;
   }

   public static class Entities {
      private String uuid;
      private String type;

      public String getUuid() {
         return uuid;
      }

      public void setUuid(String uuid) {
         this.uuid = uuid;
      }

      public String getType() {
         return type;
      }

      public void setType(String type) {
         this.type = type;
      }
   }
}
