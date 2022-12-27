import React, { useRef, useState, memo, useEffect, useCallback } from "react";
import ContentEditable from "react-contenteditable";
import s from "./index.module.less";
import { Dropdown, Menu, Upload, message } from "antd";
import {
  scrollToBottom,
  convertToMessage,
  renderHtml,
  getEmojiHtml
} from "@/utils/common";
import { SCROLL_WARP_ID,CHAT_TYPE, INVITE_TYPE, ACCEPT_INVITE_TYPE  } from "@/consts";
import {
  createMsg,
  deliverMsg,
  pasteHtmlAtCaret,
  formatImFile
} from "@/utils/common";
import { connect } from "react-redux";
import Icon from "../Icon";
import EmojiPicker from "../Emoji";
import WebIM from "@/utils/WebIM";
import {get, post} from "@/utils/axios";

const EnterKeyCode = 13;

const scrollBottom = () => {
  setTimeout(() => {
    scrollToBottom(document.getElementById(SCROLL_WARP_ID));
  }, 300);
};

function getMsgConvert(msg) {

}

const Input = (props) => {
  const {
    insertChatMessage,
    fromId,
    chatType,
    isThread,
    isCreatingThread,
    threadName,
    currentThreadInfo,
    setThreadMessage,
    userInfo,
    channelInfo
  } = props;
  const [text, setText] = useState("");
  const ref = useRef("");
  // 定义光标对象
  const lastEditRangeRef = useRef();

  const idRef = useRef(fromId);
  const setLastRange = () => {
    // 获取选定对象
    let selection = getSelection();
    // 设置最后光标对象
    lastEditRangeRef.current = selection.getRangeAt(0);
  };

  const onChange = (e) => {
    console.log("onChange  %o ",e.target.value)
    setText(e.target.value);
  };

  const beforeUploadImg = async (file) => {
    let resFile = file;
    const getImgMsg = (target) => {
      return createMsg({
        chatType: chatType,
        type: "img",
        to: target,
        isChatThread: props.isThread,
        file: formatImFile(resFile),
        onFileUploadError: function () {
          // 消息上传失败
          console.log("onFileUploadError");
        },
        onFileUploadProgress: function (progress) {
          // 上传进度的回调
          console.log(progress);
        },
        onFileUploadComplete: function () {
          // 消息上传成功
          console.log("onFileUploadComplete");
        }
      });
    };
    getTarget().then((target) => {
      const imgMsg = getImgMsg(target);
      // 发送图片消息
      deliverMsg(imgMsg).then((res) => {
        if (imgMsg.isChatThread) {
          setThreadMessage({
            message: { ...imgMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: { list: [{ ...imgMsg, from: WebIM.conn.user }] }
          });
          scrollBottom();
        }
      });
    });
  };

  const beforeUploadFile = (file) => {
    const getFileMsg = (target) => {
      return createMsg({
        chatType: chatType,
        type: "file",
        to: target,
        isChatThread: props.isThread,
        file: formatImFile(file),
        filename: file.name,
        ext: {
          file_length: file.size,
          file_type: file.type
        },
        onFileUploadError: function () {
          // 消息上传失败
          console.log("onFileUploadError");
        },
        onFileUploadProgress: function (progress) {
          // 上传进度的回调
          console.log(progress);
        },
        onFileUploadComplete: function () {
          // 消息上传成功
          console.log("onFileUploadComplete");
        }
      });
    };
    getTarget().then((target) => {
      const fileMsg = getFileMsg(target);
      deliverMsg(fileMsg).then(() => {
        if (fileMsg.isChatThread) {
          setThreadMessage({
            message: { ...fileMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...fileMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  };

  function sendTestExt() {
    console.log("testExt")
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    getTarget().then((target) => {
      //发送消息
      const extMsg = createMsg({
        chatType: chatType,
        type: "custom",
        to: target,
        isChatThread: props.isThread,
        customEvent: "testExt",
        customExts: {
          //server_name: message.customExts?.server_name,
          //channel_name: message.customExts?.channel_name
          v:1,
          type:"testExt",
        },
        ext,
      });
      console.log("extMsg =%o",extMsg)
      deliverMsg(extMsg).then(() => {
        if (extMsg.isChatThread) {
          setThreadMessage({
            message: { ...extMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...extMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
    console.log("testExt")
  }

  function openMyExtModel() {
    sendTestExt()
  }

  function sendRedPacketMsg(){
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    getTarget().then((target) => {
      //发送消息
      const extMsg = createMsg({
        chatType: chatType,
        type: "custom",
        to: target,
        isChatThread: props.isThread,
        customEvent: "RedPacketMsg",
        customExts: {
          //server_name: message.customExts?.server_name,
          //channel_name: message.customExts?.channel_name
          v:1,
          type:"RedPacketMsg",
        },
        ext,
      });
      console.log("extMsg =%o",extMsg)
      deliverMsg(extMsg).then(() => {
        if (extMsg.isChatThread) {
          setThreadMessage({
            message: { ...extMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...extMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  }

  function sendGameMsg() {
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    let randNum =  Math.floor(Math.random() * 3) + 1;
    getTarget().then((target) => {
      //发送消息
      const extMsg = createMsg({
        chatType: chatType,
        type: "custom",
        to: target,
        isChatThread: props.isThread,
        customEvent: "GameMsg",
        customExts: {
          //server_name: message.customExts?.server_name,
          //channel_name: message.customExts?.channel_name
          v:1,
          type:"GameMsg",
          gameInfo:randNum
        },
        ext,
      });
      console.log("extMsg =%o",extMsg)
      deliverMsg(extMsg).then(() => {
        if (extMsg.isChatThread) {
          setThreadMessage({
            message: { ...extMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...extMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  }

  function sendDiceGameMsg() {
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let randNum =  Math.floor(Math.random() * 6) + 1;
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    getTarget().then((target) => {
      //发送消息
      const extMsg = createMsg({
        chatType: chatType,
        type: "custom",
        to: target,
        isChatThread: props.isThread,
        customEvent: "DiceGameMsg",
        customExts: {
          //server_name: message.customExts?.server_name,
          //channel_name: message.customExts?.channel_name
          v:1,
          type:"DiceGameMsg",
          gameInfo:randNum
        },
        ext,
      });
      console.log("extMsg =%o",extMsg)
      deliverMsg(extMsg).then(() => {
        if (extMsg.isChatThread) {
          setThreadMessage({
            message: { ...extMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...extMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  }
  function sendPunchCardMsgMsg() {
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let randNum =  Math.floor(Math.random() * 4) + 1;
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    getTarget().then((target) => {
      //发送消息
      const extMsg = createMsg({
        chatType: chatType,
        type: "custom",
        to: target,
        isChatThread: props.isThread,
        customEvent: "PunchCardMsg",
        customExts: {
          //server_name: message.customExts?.server_name,
          //channel_name: message.customExts?.channel_name
          v:1,
          type:"PunchCardMsg",
          uId:userInfo.nickname || userInfo.username,
          uName:userInfo.nickname || userInfo.username,
          uCardId:randNum,
          uType:randNum,
          uInfo:"",
        },
        ext,
      });
      console.log("extMsg =%o",extMsg)
      deliverMsg(extMsg).then(() => {
        if (extMsg.isChatThread) {
          setThreadMessage({
            message: { ...extMsg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...extMsg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  }

  const menu = (
    <Menu
      items={[
        {
          key: "img",
          label: (
            <Upload
              beforeUpload={beforeUploadImg}
              accept="image/*"
              maxCount={1}
              showUploadList={false}
              className={s.upload}
            >
              <div className="circleDropItem">
                <Icon name="img" size="24px" iconClass="circleDropMenuIcon" />
                <span className="circleDropMenuOp">发送图片</span>
              </div>
            </Upload>
          )
        },
        {
          key: "file",
          label: (
            <Upload
              beforeUpload={beforeUploadFile}
              accept="*"
              maxCount={1}
              showUploadList={false}
              className={s.upload}
            >
              <div className="circleDropItem">
                <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                <span className="circleDropMenuOp">发送附件</span>
              </div>
            </Upload>
          )
        },
        {
          key: "testExt",
          label: (
              <div
                  onClick={openMyExtModel}
                  className={s.upload}
              >
                <div className="circleDropItem">
                  <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                  <span className="circleDropMenuOp">发送testExt</span>
                </div>
              </div>
          )
        }
        ,
        {
          key: "PunchCardMsg",
          label: (
              <div
                  onClick={sendPunchCardMsgMsg}
              >
                <div className="circleDropItem">
                  <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                  <span className="circleDropMenuOp">随机打卡</span>
                </div>
              </div>
          )
        }
        ,
        {
          key: "sendRedPacketMsg",
          label: (
              <div
                  onClick={sendRedPacketMsg}
                  className={s.upload}
              >
                <div className="circleDropItem">
                  <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                  <span className="circleDropMenuOp">红包</span>
                </div>
              </div>
          )
        },
        {
          key: "gameMsg",
          label: (
              <div
                  onClick={sendGameMsg}
              >
                <div className="circleDropItem">
                  <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                  <span className="circleDropMenuOp">石头剪刀布</span>
                </div>
              </div>
          )
        },
        {
          key: "DiceGameMsg",
          label: (
              <div
                  onClick={sendDiceGameMsg}
              >
                <div className="circleDropItem">
                  <Icon name="clip" size="24px" iconClass="circleDropMenuIcon" />
                  <span className="circleDropMenuOp">扔骰子</span>
                </div>
              </div>
          )
        }
      ]}
    />
  );

  //创建thread，返回target
  const getTarget = useCallback(() => {
    return new Promise((resolve, reject) => {
      if (isCreatingThread && isThread) {
        //创建thread
        if (!threadName) {
          message.warn({ content: "子区名称不能为空！" });
          return;
        }
        const options = {
          name: threadName.replace(/(^\s*)|(\s*$)/g, ""),
          messageId: currentThreadInfo.parentMessage.id,
          parentId: idRef.current
        };
        WebIM.conn.createChatThread(options).then((res) => {
          const threadId = res.data?.chatThreadId;
          resolve(threadId);
        });
      } else if (isThread) {
        //发送thread消息
        resolve(currentThreadInfo.id);
      } else {
        //发送非thread消息
        resolve(idRef.current);
      }
    });
  }, [
    currentThreadInfo?.id,
    currentThreadInfo?.parentMessage?.id,
    isCreatingThread,
    isThread,
    threadName
  ]);

  function sendMsgToServerConvert(msg) {
    console.log("sendMsgToServerConvert",msg)
    let fdStart = msg.msg.indexOf("#");
    if(fdStart === 0){
      //表示strCode是以#开头；
      // post("http://127.0.0.1:8081/app/msg",{
      //   msg,
      //   channelInfo,
      //   userName:userInfo.nickname || userInfo.username,
      // });
      post("http://121.37.25.228:8081/app/msg",{
        userMsg:msg,
        channelInfo,
        userName:userInfo.nickname || userInfo.username,
      });
    }else if(fdStart === -1){
      //表示strCode不是以#开头
    }

  }

  //发消息
  const sendMessage = useCallback(() => {
    if (!text) return;
    let myExt = userInfo.ext?JSON.parse(userInfo.ext):"";
    let ext = userInfo.ext? {
      rankValue: myExt?.rankValue,
      vipValue: myExt?.vipValue
    }: null;
    getTarget().then((target) => {
      let myMsg = convertToMessage(ref.current.innerHTML);
      let msg = createMsg({
        chatType,
        type: "txt",
        to: target,
        msg: myMsg,
        ext,
        //msgConfig:{ allowGroupAck : true},
        isChatThread: props.isThread
      });
      //拦截发送消息
      console.log("sendMessage %o",ref)
      console.log("msg %o",msg)
      sendMsgToServerConvert(msg);
      setText("");
      deliverMsg(msg).then(() => {
        if (msg.isChatThread) {
          setThreadMessage({
            message: { ...msg, from: WebIM.conn.user },
            fromId: target
          });
        } else {
          insertChatMessage({
            chatType,
            fromId: target,
            messageInfo: {
              list: [{ ...msg, from: WebIM.conn.user }]
            }
          });
          scrollBottom();
        }
      });
    });
  }, [text, props, getTarget, chatType, setThreadMessage, insertChatMessage]);

  //键盘enter事件
  const onKeyDown = useCallback(
    (e) => {
      if (e.keyCode === EnterKeyCode) {
        e.preventDefault();
        sendMessage();
      }
    },
    [sendMessage]
  );

  const insertNode = (e) => {
    pasteHtmlAtCaret(e, lastEditRangeRef?.current);
  };

  const onEmojiSelect = (e) => {
    ref.current.focus();
    let img = document.createElement("img");
    img.src = e.src;
    insertNode(
      getEmojiHtml({
        src: e.src,
        dataKey: e.id,
        alt: e.id,
        className: s.emojiMsg
      })
    );
    setLastRange();
    setText(ref.current.innerHTML);
  };

  const onPaste = useCallback((event) => {
    let paste = (event.clipboardData || window.clipboardData).getData(
      "text/plain"
    );
    ref.current.focus();
    let html = renderHtml(paste);
    insertNode(html);
    setLastRange();
    setText(ref.current.innerHTML);
    event.preventDefault();
  }, []);

  //事件绑定
  useEffect(() => {
    ref.current.addEventListener("keydown", onKeyDown);
    return function cleanup() {
      let _inputRef = ref;
      _inputRef &&
        _inputRef?.current?.removeEventListener("keydown", onKeyDown);
    };
  }, [onKeyDown]);

  useEffect(() => {
    idRef.current = fromId;
  }, [fromId]);

  useEffect(() => {
    let dom = ref?.current;
    ref?.current.addEventListener("paste", onPaste);
    return () => {
      dom.removeEventListener("paste", onPaste);
    };
  }, [onPaste]);

  return (
    <div className={`${s.controlWrap} ${threadName === "" && isCreatingThread ? s.cannotSend : null} `}>
      <div className={s.editableContainer}>
        <div>
          提示:输入#触发自动机器人功能.
        </div>
        <ContentEditable
          innerRef={ref}
          className={s.inputWrap}
          html={text}
          disabled={threadName === "" && isCreatingThread}
          onDrop={(e) => {
            e.preventDefault();
          }}
          onClick={() => {
            setLastRange();
          }}
          onKeyUp={() => {
            setLastRange();
          }}
          placeholder="发送消息"
          contentEditable="true"
          onChange={onChange}
        />
      </div>
      <div className={s.optWrap}>
        <EmojiPicker onEmojiSelect={onEmojiSelect} emojiIcon={"emoji"} disabled={threadName === "" && isCreatingThread} />
        <Dropdown
          overlay={menu}
          placement="top"
          overlayClassName="circleDropDown"
          trigger="click"
          disabled={threadName === "" && isCreatingThread}
        >
          <div className={s.IconCon}>
            <Icon iconClass={s.icon} name="add_in_circle" />
          </div>
        </Dropdown>
      </div>
    </div>
  );
};

const mapStateToProps = ({ channel, thread,app }) => {
  return {
    currentThreadInfo: thread.currentThreadInfo,
    isCreatingThread: thread.isCreatingThread,
    userInfo: app.userInfo,
    channelInfo: app.currentChannelInfo,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    insertChatMessage: (params) => {
      return dispatch({
        type: "app/insertChatMessage",
        payload: params
      });
    },
    setThreadMessage: (params) => {
      return dispatch({
        type: "thread/setThreadMessage",
        payload: params
      });
    }
  };
};

export default memo(connect(mapStateToProps, mapDispatchToProps)(Input));
