package io.agora.service.bean;


public class UserAccountBean {
   private String userName;
   private String pwd;

   public UserAccountBean(String userName, String pwd) {
      this.userName = userName;
      this.pwd = pwd;
   }

   public String getUserName() {
      return userName;
   }

   public void setUserName(String userName) {
      this.userName = userName;
   }

   public String getPwd() {
      return pwd;
   }

   public void setPwd(String pwd) {
      this.pwd = pwd;
   }
}
