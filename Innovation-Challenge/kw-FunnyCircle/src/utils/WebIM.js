// import WebIM from "./Easemob-chat";
import WebIM from "easemob-websdk";

WebIM.conn = new WebIM.connection({
  appKey: "1139221107140394#sportinghome",
  useOwnUploadFun: true
});

export default WebIM;
