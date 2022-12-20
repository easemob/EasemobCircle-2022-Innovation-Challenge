// import WebIM from "./Easemob-chat";
import WebIM from "easemob-websdk";

WebIM.conn = new WebIM.connection({
  appKey: "1162221218164444#demo",
  useOwnUploadFun: true
});

export default WebIM;
