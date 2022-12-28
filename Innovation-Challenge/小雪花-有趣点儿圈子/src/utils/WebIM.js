// import WebIM from "./Easemob-chat";
import WebIM from "easemob-websdk";

WebIM.conn = new WebIM.connection({
  appKey: "1117181125113804#circle",
  //appKey: "1173221224160726#demo",
  useOwnUploadFun: true
});

export default WebIM;
