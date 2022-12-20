import AgoraRTC from "agora-rtc-sdk-ng";
import React, { memo, useState, useEffect, useRef, useMemo } from "react";
import { createMsg, deliverMsg } from "@/utils/common";
import { CHAT_TYPE } from "@/consts";
import { Spin, FloatButton, message, Upload, Button } from "antd";
import { connect } from "react-redux";
import {
  CustomerServiceOutlined,
  DesktopOutlined,
  VideoCameraOutlined,
  VideoCameraAddOutlined,
  VideoCameraFilled,
  UploadOutlined,
} from "@ant-design/icons";
import * as wasm_emulator from "@/pkg";
import mario_url from "@/assets/mario.nes";

const options = {
  appId: "4c61de5fd1b94e2baa5affde8aa50c9f",
  channel: "test",
  token:
    "007eJxTYAhh7Kl6zN1bz7xI74hPp8e7749M5uuohMoxLFjwaP56y0YFBpNkM8OUVNO0FMMkS5NUo6TERNPEtLSUVAsgwyDZMo0tfGFyQyAjwyxBIUZGBggE8VkYSlKLSxgYAAUVHmk=",
  uid: "123xxx",
};

const CMD_START_STREAM = "start";
const CMD_END_STREAM = "end";

const StreamHandler = (props) => {
  const { userInfo, messageInfo, channelId, enableLocalVoice = false } = props;
  const localVideoEle = useRef(null);
  const canvasEle = useRef(null);
  const [rtcClient, setRtcClient] = useState(null);
  const [connectStatus, setConnectStatus] = useState(false);
  const [remoteUser, setRemoteUser] = useState(null);

  const [remoteVoices, setRemoteVoices] = useState([]);
  const [remoteVideo, setRemoteVideo] = useState(null);

  const [enableRemoteVoice, setEnableRemoteVoice] = useState(false);
  const [enableRemoteVideo, setEnableRemoteVideo] = useState(false);

  const firstMessage = useMemo(() => {
    return messageInfo?.list?.find(
      (item) => item.type === "custom" && item?.ext?.type === "stream"
    );
  }, [messageInfo]);

  const hasRemoteStream =
    firstMessage?.ext?.status === CMD_START_STREAM &&
    firstMessage?.ext?.user !== userInfo?.username;
  const [localStreaming, setLocalStreaming] = useState(
    firstMessage?.ext?.status === CMD_START_STREAM &&
      firstMessage?.ext?.user === userInfo?.username
  );

  // console.log("[Stream] localStreaming", localStreaming);

  // console.log("msg", messageInfo);
  // console.log("uinfo", userInfo);
  // console.log("first msg", firstMessage);
  // console.log("enable voice", enableLocalVoice);

  const sendStreamMessage = (content) => {
    let msg = createMsg({
      chatType: CHAT_TYPE.groupChat,
      type: "custom",
      to: channelId,
      ext: {
        type: "stream",
        ...content,
      },
    });
    deliverMsg(msg)
      .then(() => {
        console.log("发送成功");
      })
      .catch((e) => {
        console.log(e);
      });
  };

  useEffect(() => {
    AgoraRTC.setLogLevel(3);
    const client = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
    // TODO: use right channel
    // Use default uid.
    client
      .join(options.appId, options.channel, options.token, userInfo?.username)
      .then(() => {
        setConnectStatus(true);
        console.log("[Stream] join channel success");
      })
      .catch((e) => {
        console.log(e);
      });

    client.on("user-published", async (user, mediaType) => {
      // auto subscribe when users coming
      await client.subscribe(user, mediaType);
      console.log("[Stream] subscribe success on user ", user);
      if (mediaType === "video") {
        if (remoteUser && remoteUser.uid !== user.uid) {
          console.error(
            "already in a call, can not subscribe another user ",
            user
          );
          return;
        }
        const remoteVideoTrack = user.videoTrack;
        remoteVideoTrack.play(localVideoEle.current);
        setRemoteVideo(remoteVideoTrack);
        // can only have one remote video user
        setRemoteUser(user);
      }
      if (mediaType === "audio") {
        const remoteAudioTrack = user.audioTrack;
        if (remoteVoices.findIndex((item) => item.uid === user.uid) == -1) {
          if (enableRemoteVoice) {
            remoteAudioTrack.play();
          }
          setRemoteVoices([
            ...remoteVoices,
            { audio: remoteAudioTrack, uid: user.uid },
          ]);
        }
      }
    });

    client.on("user-unpublished", (user) => {
      console.log("[Stream] user-unpublished", user);
      removeUserStream(user);
    });
    setRtcClient(client);
  }, []);

  // Handle local voice stream.
  useEffect(() => {
    if (!enableLocalVoice || !rtcClient) {
      return;
    }
    let localAudioTrack = null;
    async function publishLocalStream() {
      localAudioTrack = await AgoraRTC.createMicrophoneAudioTrack();
      console.log("[Stream] publish local voice stream");
      await rtcClient.publish(localAudioTrack);
    }
    publishLocalStream();

    return () => {
      if (localAudioTrack) {
        console.log("[Stream] unpublish local voice stream");
        rtcClient.unpublish(localAudioTrack);
      }
    };
  }, [rtcClient, enableLocalVoice]);

  useEffect(() => {
    if (!localStreaming || !rtcClient) {
      return;
    }
    // debugger;
    let localVideoStream = AgoraRTC.createCustomVideoTrack({
      mediaStreamTrack: canvasEle.current.captureStream(30).getVideoTracks()[0],
    });
    rtcClient.publish(localVideoStream).then(() => {
      sendStreamMessage({
        user: userInfo?.username,
        status: CMD_START_STREAM,
      });
      // setLocalVideoStream(localVideoStream);
      message.success({
        content: "start streaming",
        style: { color: "black" },
      });
    });
    return () => {
      if (localVideoStream) {
        rtcClient.unpublish(localVideoStream);
        localVideoStream.stop();
        // setLocalVideoStream(null);
        sendStreamMessage({
          user: userInfo?.username,
          status: CMD_END_STREAM,
        });
        message.info({
          content: "stop streaming",
          style: { color: "black" },
        });
      }
    };
  }, [rtcClient, localStreaming]);

  const leaveChannel = () => {
    setLocalStreaming(false);
    rtcClient?.leave();
  };

  const toggleLocalGameStream = () => {
    if (hasRemoteStream) {
      return;
    }
    setLocalStreaming(!localStreaming);
  };

  const removeUserStream = (user) => {
    if (remoteUser && remoteUser.uid === user.uid) {
      setRemoteUser(null);
      setRemoteVideo(null);
    }
    setRemoteVoices(remoteVoices.filter((voice) => voice.uid !== user.uid));
  };

  const toggleRemoteVoice = () => {
    // 当前是关闭状态，需要打开
    if (enableRemoteVoice) {
      remoteVoices.forEach((voice) => {
        if (voice.audio.isPlaying) {
          voice.audio.stop();
        }
        voice.audio.setVolume(0);
      });
    } else {
      remoteVoices.forEach((voice) => {
        if (!voice.audio.isPlaying) {
          voice.audio.play();
        }
        voice.audio.setVolume(100);
      });
    }
    setEnableRemoteVoice(!enableRemoteVoice);
  };

  const toggleRemoteVideo = () => {
    if (!hasRemoteStream) {
      return;
    }
    console.log("[Stream] set remote video to ", !enableRemoteVideo);
    // 当前是关闭状态，需要打开
    if (enableRemoteVideo) {
      remoteVideo?.stop();
    } else {
      remoteVideo?.play(localVideoEle.current);
    }
    setEnableRemoteVideo(!enableRemoteVideo);
  };

  useEffect(() => {
    if (!canvasEle || hasRemoteStream) {
      return;
    }

    wasm_emulator.wasm_main();
    fetch(mario_url, {
      headers: { "Content-Type": "application/octet-stream" },
    })
      .then((response) => response.arrayBuffer())
      .then((data) => {
        let mario = new Uint8Array(data);
        wasm_emulator.start(mario, "canvas");
      });
  }, [canvasEle, hasRemoteStream]);

  const uploadRom = (file) => {
    new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsArrayBuffer(file);
      reader.onload = () => {
        let res = reader.result;
        let rom = new Uint8Array(res);
        wasm_emulator.start(rom, "canvas");
      };
    });
    // if (info.file.status === 'done') {
    //   debugger
    //   message.success({content: `${info.file.name} file uploaded successfully`,
    //   style: { color: "black"}});
    // } else if (info.file.status === 'error') {
    //   message.error({content: `${info.file.name} file upload failed.`, style: { color: "black"}});
    // }
  };

  useEffect(() => {
    return () => {
      leaveChannel();
    };
  }, []);

  const renderLocalStream = () => {
    return (
      <div style={{ height: "100%" }}>
        <canvas
          id="canvas"
          style={{ width: "100%", height: "90%" }}
          ref={canvasEle}
        />
        {/* <div id="game" width="100%" height="90%" ref={canvasEle}></div> */}
        <Upload beforeUpload={uploadRom} maxCount="1">
          <Button icon={<UploadOutlined />}>Click to choose rom</Button>
        </Upload>
      </div>
    );
  };
  const renderRemoteStream = () => {
    return (
      <div style={{ height: "100%" }}>
        <div
          id="remote-player"
          style={{
            width: "100%",
            height: "90%",
            border: "1px solid #fff",
          }}
          ref={localVideoEle}
        />
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            marginTop: "10px",
          }}
        >
          <span style={{ color: "#0ECD0A" }}>{firstMessage?.ext?.user}</span>
          &nbsp; is playing{" "}
        </div>
      </div>
    );
  };

  const renderFloatButton = () => {
    return (
      <FloatButton.Group
        icon={<DesktopOutlined />}
        trigger="click"
        style={{ left: "380px" }}
      >
        <FloatButton
          onClick={toggleRemoteVoice}
          icon={<CustomerServiceOutlined />}
          tooltip={<div>加入/退出语音频道</div>}
        />
        {hasRemoteStream && (
          <FloatButton
            onClick={toggleRemoteVideo}
            icon={<VideoCameraAddOutlined />}
            tooltip={<div>观看/停止观看直播</div>}
          />
        )}
        {!hasRemoteStream && (
          <FloatButton
            onClick={toggleLocalGameStream}
            icon={
              localStreaming ? <VideoCameraFilled /> : <VideoCameraOutlined />
            }
            tooltip={<div>{localStreaming ? "停止直播" : "开始直播"}</div>}
          />
        )}
      </FloatButton.Group>
    );
  };
  return (
    <>
      {!connectStatus && <Spin tip="Loading" size="large" />}
      <div style={{ height: "100%" }}>
        {renderFloatButton()}
        {hasRemoteStream ? renderRemoteStream() : renderLocalStream()}
      </div>
    </>
  );
};

const mapStateToProps = ({ app, thread }) => {
  return {
    userInfo: app.userInfo,
    currentThreadInfo: thread.currentThreadInfo,
  };
};
export default memo(connect(mapStateToProps)(StreamHandler));
