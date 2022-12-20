import WebIM from "./Easemob-chat";
// import WebIM from "easemob-websdk";

WebIM.conn = new WebIM.connection({
  appKey: '1111220807113509#discord',
  useOwnUploadFun: true
});

export default WebIM;
