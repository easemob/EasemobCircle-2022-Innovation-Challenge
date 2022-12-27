// import WebIM from "./Easemob-chat";
import WebIM from "easemob-websdk";

WebIM.conn = new WebIM.connection({
  appKey: "1189210720051209#happy-circle",
  useOwnUploadFun: true
});

export default WebIM;
