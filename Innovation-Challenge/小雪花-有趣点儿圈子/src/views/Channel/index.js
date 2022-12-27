import React, { memo, useEffect, useMemo, useCallback, useRef } from "react";
import s from "./index.module.less";
import Header from "./components/Header";
import { connect } from "react-redux";
import MemberModal from "./components/MemberModal";
import { useParams } from "react-router-dom";
import MessageLeft from "@/components/MessageLeft";
import MessageLeft4Notice from "@/components/MessageLeft/MessageLeft4Notice";
import Input from "@/components/Input";
import {
  CHAT_TYPE,
  MESSAGE_ITEM_SOURCE,
  INVITE_TYPE,
  SCROLL_WARP_ID,
  ACCEPT_INVITE_TYPE,
  THREAD_PAGE_SIZE, USER_ROLE
} from "@/consts";
import Thread from "../Thread";
import WebIM from "@/utils/WebIM";
import {message, Spin, Col, Row, Layout, Badge, Card, Tooltip} from "antd";
import {
  getThreadParentMsg,
  recallMessage,
  createMsg,
  deliverMsg
} from "@/utils/common";
import ChannelMember from "./components/ChannelMember";
import Icon from "@/components/Icon";
import InfiniteScroll from "react-infinite-scroll-component";
import FileMsg from "@/components/FileMsg";

import ReactPlayer from 'react-player'

import { Player } from 'wjj-player'

import ReactJkMusicPlayer from 'react-jinke-music-player'
import 'react-jinke-music-player/assets/index.css'


const PAGE_SIZE = 20;
const {Content } = Layout;

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
    setThreadMap,
    serverRole,
  } = props;

  const { serverId, channelId } = useParams();
  const userRole = serverRole[serverId];
  const ref = useRef();

  const myExt = currentChannelInfo.ext? JSON.parse(currentChannelInfo.ext): {type:"0"};
  console.log("myExt %o",myExt)

  const messageInfo = useMemo(() => {
    return chatMap[CHAT_TYPE.groupChat].get(channelId) || {};
  }, [channelId, chatMap]);

  const audioList1 = [
    {
      name: 'Despacito',
      singer: 'Luis Fonsi',
      cover:
          'http://res.cloudinary.com/alick/image/upload/v1502689731/Despacito_uvolhp.jpg',
      musicSrc:
          'http://res.cloudinary.com/alick/video/upload/v1502689683/Luis_Fonsi_-_Despacito_ft._Daddy_Yankee_uyvqw9.mp3',
      // support async fetch music src. eg.
      // musicSrc: async () => {
      //   return await fetch('/api')
      // },
    },
    {
      name: 'Dorost Nemisham',
      singer: 'Sirvan Khosravi',
      cover:
          'https://res.cloudinary.com/ehsanahmadi/image/upload/v1573758778/Sirvan-Khosravi-Dorost-Nemisham_glicks.jpg',
      musicSrc:
          'https://res.cloudinary.com/ehsanahmadi/video/upload/v1573550770/Sirvan-Khosravi-Dorost-Nemisham-128_kb8urq.mp3',
    },
  ]

  const options = {
    // audio lists model
    audioLists: audioList1,

    // default play index of the audio player  [type `number` default `0`]
    defaultPlayIndex: 0,
  }

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

  function choiceMessage(data, isChatThread) {
    alert("choiceMessage")
  }

  function replyMessage(data, isChatThread) {
    alert("replyMessage")
  }

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
      case "choice":
        choiceMessage(data, isChatThread);
        break;
      case "reply":
        replyMessage(data, isChatThread);
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

  const serverInfo = useMemo(() => {
    return getServerInfoById({ serverId, serverList: joinedServerInfo.list });
  }, [serverId, joinedServerInfo]);
  return (
    <div ref={ref} className={s.channelWrap}>
      <div className={s.main}>
        <Header
          serverId={serverId}
          channelId={channelId}
          onHandleOperation={handleOperation}
        />
        <div className={s.contentWrap}>
          <div id={SCROLL_WARP_ID} className={s.messageWrap}>
            {/*aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa*/}
            {/*{serverInfo.type === "custom" && message.customExts?.customMsgType === CUSTOM_MSG_TYPE.code && <CodeMsg message={message} />}*/}
            {myExt?.type === "0" &&
                <InfiniteScroll
                    inverse={true}
                    dataLength={messageInfo?.list?.length || 0}
                    next={loadMoreData}
                    hasMore={messageInfo?.loadCount >= PAGE_SIZE}
                    style={{
                      display: "flex",
                      flexDirection: "column-reverse",
                      minHeight: "435px"
                    }}
                    loader={<Spin />}
                    endMessage={
                      <div style={{ textAlign: "center" }}>没有更多消息啦～</div>
                    }
                    scrollableTarget={SCROLL_WARP_ID}
                >
                  {messageInfo?.list?.map((item) => {
                    return (
                        <div key={item.id}>
                          <MessageLeft
                              parentId={channelId}
                              message={item}
                              onHandleOperation={handleOperation}
                              source={MESSAGE_ITEM_SOURCE.groupChat}
                          />
                        </div>
                    );
                  })}
                </InfiniteScroll>
            }
            {myExt?.type === "1" &&
                <InfiniteScroll
                    inverse={true}
                    dataLength={messageInfo?.list?.length || 0}
                    next={loadMoreData}
                    hasMore={messageInfo?.loadCount >= PAGE_SIZE}
                    style={{
                      display: "flex",
                      flexDirection: "column-reverse",
                      minHeight: "435px"
                    }}
                    loader={<Spin />}
                    endMessage={
                      <div style={{ textAlign: "center" }}>没有更多通知啦～</div>
                    }
                    scrollableTarget={SCROLL_WARP_ID}
                >
                  {messageInfo?.list?.map((item) => {
                    return (
                        <div key={item.id} style={{
                          margin: "20px 40px 60px",
                          background: "#181818",
                        }}>
                          <Badge.Ribbon text="通知" style={{
                            background: "#181818",
                          }}>
                            <Card title="" size="small" style={{
                              background: "#181818",
                            }}>
                              <MessageLeft4Notice
                                  parentId={channelId}
                                  message={item}
                                  onHandleOperation={handleOperation}
                                  source={MESSAGE_ITEM_SOURCE.groupChat}
                              />
                            </Card>
                          </Badge.Ribbon>

                        </div>
                    );
                  })}
                </InfiniteScroll>
            }
            {myExt?.type === "5" &&
                <InfiniteScroll
                    inverse={true}
                    dataLength={messageInfo?.list?.length || 0}
                    next={loadMoreData}
                    hasMore={messageInfo?.loadCount >= PAGE_SIZE}
                    style={{
                      display: "flex",
                      flexDirection: "column-reverse",
                      minHeight: "435px"
                    }}
                    loader={<Spin />}
                    endMessage={
                      <div style={{ textAlign: "center" }}>没有更多消息啦～</div>
                    }
                    scrollableTarget={SCROLL_WARP_ID}
                >
                  {messageInfo?.list?.map((item) => {
                    return (
                        <div key={item.id}>
                          <MessageLeft
                              parentId={channelId}
                              message={item}
                              onHandleOperation={handleOperation}
                              source={MESSAGE_ITEM_SOURCE.groupChat}
                          />
                        </div>
                    );
                  })}
                </InfiniteScroll>
            }
            {myExt?.type === "2" &&
                <Row>
                  <Col>
                    <ReactPlayer className='react-player'
                        //这里是由上级页面传过来的视频地址
                                 url='http://vjs.zencdn.net/v/oceans.mp4'
                                 playing
                                 width='100%'
                                 controls
                                 config={{
                                   file: {
                                     forceHLS: true,
                                   }
                                 }}
                    />

                    电影频道</Col>
                  <Col flex="500px">
                    <InfiniteScroll
                        inverse={true}
                        dataLength={messageInfo?.list?.length || 0}
                        next={loadMoreData}
                        hasMore={messageInfo?.loadCount >= PAGE_SIZE}
                        style={{
                          display: "flex",
                          flexDirection: "column-reverse",
                          minHeight: "435px"
                        }}
                        loader={<Spin />}
                        endMessage={
                          <div style={{ textAlign: "center" }}>没有更多消息啦～</div>
                        }
                        scrollableTarget={SCROLL_WARP_ID}
                    >
                      {messageInfo?.list?.map((item) => {
                        return (
                            <div key={item.id}>
                              <MessageLeft
                                  parentId={channelId}
                                  message={item}
                                  onHandleOperation={handleOperation}
                                  source={MESSAGE_ITEM_SOURCE.groupChat}
                              />
                            </div>
                        );
                      })}
                    </InfiniteScroll>
                  </Col>
                </Row>
            }

            {myExt.type === "4" &&
                <Row>
                  <Col flex="auto">
                    <Content style={{ padding: '0 50px' }}>
                      {/*<Player />*/}
                      <ReactJkMusicPlayer {...options} />
                      <div className="site-layout-content">Contentasdfasdfasdfasdfasdf</div>
                    </Content>
                  </Col>
                  <Col flex="400px">
                    <InfiniteScroll
                        inverse={true}
                        dataLength={messageInfo?.list?.length || 0}
                        next={loadMoreData}
                        hasMore={messageInfo?.loadCount >= PAGE_SIZE}
                        style={{
                          display: "flex",
                          flexDirection: "column-reverse",
                          minHeight: "435px"
                        }}
                        loader={<Spin />}
                        endMessage={
                          <div style={{ textAlign: "center" }}>没有更多消息啦～</div>
                        }
                        scrollableTarget={SCROLL_WARP_ID}
                    >
                      {messageInfo?.list?.map((item) => {
                        return (
                            <div key={item.id}>
                              <MessageLeft
                                  parentId={channelId}
                                  message={item}
                                  onHandleOperation={handleOperation}
                                  source={MESSAGE_ITEM_SOURCE.groupChat}
                              />
                            </div>
                        );
                      })}
                    </InfiniteScroll>
                  </Col>
                </Row>
            }

          </div>

          {(myExt?.type === "1" && userRole && userRole === USER_ROLE.user) ? (
              <div className={s.iptWrap}>
                通知频道,非管理用户,禁止发言
              </div>
          ):(
              <div className={s.iptWrap}>
                <Input chatType={CHAT_TYPE.groupChat} fromId={channelId} />
              </div>
          )}


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
    currentThreadInfo: thread.currentThreadInfo,
    serverRole: app.serverRole,
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
