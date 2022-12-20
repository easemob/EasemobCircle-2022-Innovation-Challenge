import React, { memo, useEffect, useMemo, useCallback, useRef, useState } from "react";
import s from "./index.module.less";
import Header from "./components/Header";
import { connect } from "react-redux";
import MemberModal from "./components/MemberModal";
import { useParams } from "react-router-dom";
import MessageLeft from "@/components/MessageLeft";
import Input from "@/components/Input";
import {
  CHAT_TYPE,
  MESSAGE_ITEM_SOURCE,
  INVITE_TYPE,
  SCROLL_WARP_ID,
  ACCEPT_INVITE_TYPE,
  THREAD_PAGE_SIZE
} from "@/consts";
import Thread from "../Thread";
import WebIM from "@/utils/WebIM";
import { message, Row, Col } from "antd";
import {
  getThreadParentMsg,
  recallMessage,
  createMsg,
  deliverMsg
} from "@/utils/common";
import ChannelMember from "./components/ChannelMember";
import Icon from "@/components/Icon";
import InfiniteScroll from "react-infinite-scroll-component";
import StreamHandler from "./components/StreamHandler";
import MessageList from "./MessageList";

const PAGE_SIZE = 20;

const ChannelMemberHeader = ({ onClose = () => { }, onInvite, channelInfo }) => {
  return (
    <div className={s.drawerHeader}>
      <span className={s.channelMember}>频道成员</span>
      <div className={s.iconCon}>
        {/* 公开频道不显示邀请入口 */}
        {!channelInfo?.defaultChannel && (
          <span className={s.invite}><Icon
            iconClass={s.icon}
            onClick={() => {
              onInvite(INVITE_TYPE.inviteChannel);
            }}
            name={"person_plus"}
            size="24px"
          /></span>
        )}
        <span className={s.close}>
          <Icon iconClass={s.icon} onClick={onClose} name={"xmark"} size="18px" />
        </span>
      </div>
    </div>
  );
};

const getServerInfoById = ({ serverId = "", serverList = [] }) => {
  let ls = serverList.filter((item) => {
    return item.id === serverId;
  });

  if (ls.length) {
    return ls[0];
  } else {
    return {};
  }
};

const Channel = (props) => {
  const {
    setVisible,
    chatMap,
    showThreadPanel,
    pushChatMessage,
    handleThreadPanel,
    setIsCreatingThread,
    channelMemberVisible,
    setChannelMemberVisible,
    currentChannelInfo,
    setThreadInfo,
    setMsgReaction,
    setThreadHasHistory,
    setChannelFormVisible,
    setInviteVisible,
    insertChatMessage,
    joinedServerInfo,
    currentThreadInfo,
    setThreadMap
  } = props;

  const { serverId, channelId } = useParams();

  const ref = useRef();

  const messageInfo = useMemo(() => {
    return chatMap[CHAT_TYPE.groupChat].get(channelId) || {};
  }, [channelId, chatMap]);

  const getChannelThread = useCallback(
    async ({ channelId, cursor = "" }) => {
      try {
        let res = await WebIM.conn.getChatThreads({
          parentId: channelId,
          pageSize: THREAD_PAGE_SIZE,
          cursor
        });
        setThreadMap({
          channelId,
          threadInfo: {
            list: res.entities,
            cursor: res.properties.cursor,
            loadCount: res.entities.length
          }
        });
      } catch (error) {
        console.log(error);
      }
    },
    [setThreadMap]
  );

  const isInChannel = useCallback(() => {
    if (serverId && channelId) {
      WebIM.conn.isInChannel({ serverId, channelId }).then((res) => {
        if (!res.data.result) {
          WebIM.conn
            .joinChannel({
              serverId,
              channelId
            })
            .then((res) => {
              getChannelThread({ channelId });
              let msg = createMsg({
                chatType: CHAT_TYPE.groupChat,
                type: "custom",
                to: channelId,
                customEvent: ACCEPT_INVITE_TYPE.acceptInviteChannel,
                customExts: {
                  server_name: serverInfo.name,
                  channel_name: res.data.name
                }
              });
              deliverMsg(msg).then(() => {
                insertChatMessage({
                  chatType: msg.chatType,
                  fromId: msg.to,
                  messageInfo: {
                    list: [{ ...msg, from: WebIM.conn.user }]
                  }
                });
              });
            });
        }
      });
    }
  }, [serverId, channelId]);

  const getHistoryMsg = ({ cursor = "" }) => {
    WebIM.conn
      .getHistoryMessages({
        targetId: channelId,
        pageSize: PAGE_SIZE,
        chatType: "groupChat",
        cursor
      })
      .then((res) => {
        res.messages.forEach((item) => {
          setMsgReaction({
            msgId: item.id,
            reactions: item.reactions
          });
        });
        pushChatMessage({
          chatType: "groupChat",
          fromId: channelId,
          messageInfo: {
            list: res.messages,
            cursor: res.cursor,
            loadCount: res.messages.length
          },
          reset: cursor ? false : true
        });
      });
  };

  //拉取漫游消息
  useEffect(() => {
    // 切换channel 关闭thread面板
    handleThreadPanel(false);
    //清空thread数据
    setThreadInfo({});
    getHistoryMsg({ cursor: "" });
  }, [channelId]);

  //消息操作
  const handleOperation = (op, isChatThread = false, data, from) => {
    switch (op) {
      case "createThread":
        setChannelMemberVisible(false);
        setIsCreatingThread(true);
        setThreadInfo({
          parentMessage: data
        });
        handleThreadPanel(true);
        setThreadHasHistory(false);
        break;
      case "openThreadPanel":
        const chatThreadId =
          from === "threadList" ? data.id : data.chatThreadOverview.id;
        if (chatThreadId === currentThreadInfo.id) {
          return;
        }
        WebIM.conn
          .joinChatThread({ chatThreadId })
          .then((res) => {
            setChannelMemberVisible(false);
            changeThreadStatus(data, from);
          })
          .catch((e) => {
            if (e.type === 1301) {
              setChannelMemberVisible(false);
              //用户已经在子区了
              changeThreadStatus(data, from);
            } else if (e.type === 1300) {
              message.warn({ content: "该子区已经被销毁" });
            }
          });
        break;
      case "showMember":
        setThreadInfo({});
        handleThreadPanel(false);
        setChannelMemberVisible(!channelMemberVisible);
        break;
      case "setting":
        setChannelFormVisible("edit");
        break;
      case "recall":
        recallMessage(data, isChatThread);
        break;
      default:
        break;
    }
  };

  const changeThreadStatus = (data, from) => {
    setIsCreatingThread(false);
    //update currentThreadInfo
    const chatThreadId =
      from === "threadList" ? data.id : data.chatThreadOverview.id;
    WebIM.conn.getChatThreadDetail({ chatThreadId }).then((res) => {
      //从thread列表点击，需要查询本地消息
      let findMsg =
        from === "threadList"
          ? getThreadParentMsg(data.parentId, data.messageId)
          : data;
      let parentMessage = findMsg ? { ...findMsg, chatThreadOverview: {} } : {};
      setThreadInfo({ ...res.data, parentMessage });
      //open threadPanel
      handleThreadPanel(true);
    });
  };

  const loadMoreData = () => {
    getHistoryMsg({ cursor: messageInfo?.cursor });
  };

  useEffect(() => {
    return () => {
      setVisible(false);
    };
  }, [serverId]);

  useEffect(() => {
    isInChannel();
    setVisible(false);
  }, [channelId]);

  const renderTextChannel = () => {
    return (
      <>
        <MessageList
          messageInfo={messageInfo}
          channelId={channelId}
          handleOperation={handleOperation}
          className={s.messageWrap}
        />
        <div className={s.iptWrap}>
          <Input chatType={CHAT_TYPE.groupChat} fromId={channelId} />
        </div>
      </>
    );
  }

  const [enableVoice, setEnableVoice] = useState(false);
  const [enableChat, setEnableChat] = useState(true);
  const toggleVoice = () => {
    setEnableVoice((enable) => {
      return !enable;
    });
  }
  const toggleChat = () => {
    setEnableChat((enable) => {
      return !enable;
    });
  }

  const renderStreamMenu = () => {
    return [
      {
        key: "voice",
        label: (
          <div
            className="circleDropItem"
            onClick={toggleVoice}
          >
            <Icon
              name="person_wave_slash"
              size="24px"
              iconClass="circleDropMenuIcon"
            />
            <span className="circleDropMenuOp">
              {enableVoice ? "关闭语音" : "开启语音"}
            </span>
          </div>
        ),
      },
      {
        key: "showChat",
        label: (
          <div
          className="circleDropItem"
          onClick={toggleChat}
        >
          <Icon
            name="message_on_message"
            size="24px"
            iconClass="circleDropMenuIcon"
          />
          <span className="circleDropMenuOp">
            {enableChat ? "关闭信息栏" : "开启信息栏"}
          </span>
        </div>
        )
      }
    ];
  }
  const renderStreamChannel = () => {
    return (
      <>
        <Row className={s.messageRowWrap}>
          <Col span={18} style={{height:"100%"}}>
            <StreamHandler messageInfo={messageInfo} channelId={channelId} enableLocalVoice={enableVoice} />
          </Col>
          <Col span={6} style={{height:"100%"}}>
            <MessageList
              messageInfo={messageInfo}
              channelId={channelId}
              handleOperation={handleOperation}
              className={s.messageList}
            />
          </Col>
        </Row>
        <div className={s.iptWrap}>
          <Input chatType={CHAT_TYPE.groupChat} fromId={channelId} extraMenuItems={renderStreamMenu()} />
        </div>
      </>
    );
  }

  const serverInfo = useMemo(() => {
    return getServerInfoById({ serverId, serverList: joinedServerInfo.list });
  }, [serverId, joinedServerInfo]);

  const isVideoChannel = useMemo(() => {
    return currentChannelInfo?.name?.startsWith("video-");
  }, [currentChannelInfo]);

  return (
    <div ref={ref} className={s.channelWrap}>
      <div className={s.main}>
        <Header
          serverId={serverId}
          channelId={channelId}
          onHandleOperation={handleOperation}
        />
        <div className={s.contentWrap}>
          {isVideoChannel ? renderStreamChannel() : renderTextChannel()}
        </div>
      </div>
      <MemberModal />

      {showThreadPanel && (
        <div className={s.side}>
          <Thread />
        </div>
      )}

      {channelMemberVisible && (
        <div className={s.drawerWrap}>
          <ChannelMemberHeader
            channelInfo={currentChannelInfo}
            onInvite={setInviteVisible}
            onClose={() => {
              setChannelMemberVisible(false);
            }}
          />
          <div className={s.drawerBody}>
            <ChannelMember />
          </div>
        </div>
      )}
    </div>
  );
};

const mapStateToProps = ({ channel, app, thread, server }) => {
  return {
    appUserInfo: app.appUserInfo,
    chatMap: app.chatMap,
    showThreadPanel: thread.showThreadPanel,
    currentChannelInfo: app.currentChannelInfo,
    channelMemberVisible: channel.channelMemberVisible,
    joinedServerInfo: server.joinedServerInfo,
    currentThreadInfo: thread.currentThreadInfo
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    setVisible: (params) => {
      return dispatch({
        type: "channel/setVisible",
        payload: params
      });
    },
    pushChatMessage: (params) => {
      return dispatch({
        type: "app/pushChatMessage",
        payload: params
      });
    },
    handleThreadPanel: (params) => {
      return dispatch({
        type: "thread/setThreadPanelStatus",
        payload: params
      });
    },
    setIsCreatingThread: (params) => {
      return dispatch({
        type: "thread/setIsCreatingThread",
        payload: params
      });
    },
    setThreadInfo: (params) => {
      return dispatch({
        type: "thread/setThreadInfo",
        payload: params
      });
    },
    setMsgReaction: (params) => {
      return dispatch({
        type: "app/setMsgReaction",
        payload: params
      });
    },
    setThreadHasHistory: (params) => {
      return dispatch({
        type: "thread/setThreadHasHistory",
        payload: params
      });
    },
    setChannelMemberVisible: (params) => {
      return dispatch({
        type: "channel/setChannelMemberVisible",
        payload: params
      });
    },
    setChannelFormVisible: (params) => {
      return dispatch({
        type: "channel/setChannelVisible",
        payload: params
      });
    },
    setInviteVisible: (params) => {
      return dispatch({
        type: "channel/setInviteVisible",
        payload: params
      });
    },
    insertChatMessage: (params) => {
      return dispatch({
        type: "app/insertChatMessage",
        payload: params
      });
    },
    setThreadMap: (params) => {
      return dispatch({
        type: "channel/setThreadMap",
        payload: params
      });
    }
  };
};

export default memo(connect(mapStateToProps, mapDispatchToProps)(Channel));
