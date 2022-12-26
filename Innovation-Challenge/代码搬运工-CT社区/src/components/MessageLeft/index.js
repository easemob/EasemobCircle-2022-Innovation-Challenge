import AvatarInfo from "@/components/AvatarInfo";
import CardMsg from "@/components/CustomMessage/CardMsg";
import CodeMsg from '@/components/CustomMessage/CodeMsg';
import CustomMsg from "@/components/CustomMessage/InviteMsg";
import SignInCardMsg from "@/components/CustomMessage/SignInCardMsg";
import FileMsg from "@/components/FileMsg";
import ImgMsg from "@/components/ImgMsg";
import Operation from "@/components/MsgOperation";
import ReactionMsg from "@/components/ReactionMsg";
import RecallMsg from "@/components/RecallMsg";
import ThreadMsg from "@/components/ThreadMsg";
import TxtMsg from "@/components/TxtMsg";
import { CUSTOM_MSG_TYPE, MESSAGE_ITEM_SOURCE } from "@/consts";
import { getUsersInfo, renderTime } from "@/utils/common";
import WebIM from "@/utils/WebIM";
import UserDetail from "@/views/Channel/components/UserDetail";
import { Popover } from "antd";
import React, { memo, useEffect, useMemo, useRef, useState } from "react";
import { connect } from "react-redux";
import s from "./index.module.less";

const Message = (props) => {
  const parent = useRef();
  const operationRef = useRef();
  const {
    source,
    isThreadMessage,
    message,
    reactionMap,
    onHandleOperation,
    appUserInfo
  } = props;

  const reactionList = useMemo(() => {
    return reactionMap.get(message.id) || [];
  }, [reactionMap, message.id]);

  //消息操作 撤回、复制、翻译
  const handleOperation = (operation) => {
    onHandleOperation(operation, isThreadMessage, message);
  };

  //点击thread消息数量
  const handleThreadCount = () => {
    onHandleOperation("openThreadPanel", isThreadMessage, message);
  };
  //点击头像-好友详情
  const handlerAvatar = () => {
    onHandleOperation("openUserInfoPanel", isThreadMessage, message);
    if (source === "groupChat") {
      if (WebIM.conn.user !== message.from) {
        //更新单聊者信息
        getUsersInfo([message.from]).then(() => {
          handleUserPanel(true);
        });
      }
    }
  };
  const [showUserPanel, setShowUserPanel] = useState(false);
  const handleUserPanel = (state) => {
    setShowUserPanel(state);
  };

  const canCreateThread =
    source === MESSAGE_ITEM_SOURCE.groupChat &&
    !isThreadMessage &&
    message.type !== "recall" &&
    (!message.chatThreadOverview ||
      JSON.stringify(message.chatThreadOverview) === "{}");

  const showThreadInfo =
    source === MESSAGE_ITEM_SOURCE.groupChat &&
    message.chatThreadOverview &&
    message.type !== "recall" &&
    JSON.stringify(message.chatThreadOverview) !== "{}";

  const showReactionInfo =
    source !== MESSAGE_ITEM_SOURCE.threadParentMsg &&
    reactionList?.length > 0 &&
    message.type !== "recall";
  const showOperation =
    source !== MESSAGE_ITEM_SOURCE.threadParentMsg &&
    message.type !== "recall" &&
    message.type !== "custom";


  const [selected, setSelected] = useState(false);
  //点击消息
  useEffect(() => {
    let onClick = (e) => {
      let dom = operationRef.current;
      if (dom) {
        // 如果点击的区域不在自定义dom范围
        if (dom.contains(e.target)) {
          setSelected(true)
        } else {
          setSelected(false)
        }
      }
    };
    document.addEventListener("click", onClick);
    return () => {
      document.removeEventListener("click", onClick);
    };
  }, []);
  return (
    <div className={`${s.layout} ${selected ? s.selected : null}`} ref={parent}>
      <div className={s.message}>
        <div className={s.avatar} onClick={handlerAvatar}>
          <Popover
            placement="bottomLeft"
            destroyTooltipOnHide={true}
            overlayClassName={s.channelUserInfo}
            content={<UserDetail userId={message.from} />}
            visible={showUserPanel}
            onVisibleChange={handleUserPanel}
            trigger="click"
          >
            <AvatarInfo size={36} src={appUserInfo[message.from]?.avatarurl} robot={appUserInfo[message.from]?.robot || message.ext?.robot} />
          </Popover>
        </div>

        <div className={s.messageInfo}>
          <div className={s.bar}>
            <div className={s.l}>
              <span className={s.name}>
                {/* 先取最新的nickname, 没有就取消息的nickname, 最后兜底 username */}
                {appUserInfo[message.from]?.nickname || message.ext?.nickname || message.from}
              </span>
              {
                /**
                 * robot 也先取ext 里面的robot, 没有就取appUserInfo 里面的 robot
                 * robot 1 是频道专属机器人, 2 是 webhook 机器人
                 */
                (appUserInfo[message.from]?.robot || message.ext?.robot) && <span className={`${s.tag} ${(appUserInfo[message.from]?.robot || message.ext?.robot) == 1 ? s.spec : ''}`}>BOT</span>
              }
              <span className={s.date}>{renderTime(message.time)}</span>
            </div>
            {showOperation && (
              <div className={s.operation} ref={operationRef}>
                <Operation
                  type={message.type}
                  canCreateThread={canCreateThread}
                  source={source}
                  message={message}
                  parent={parent}
                  operation={handleOperation}
                />
              </div>
            )}
          </div>
          <div className={s.content}>
            {message.type === "txt" && <TxtMsg message={message} />}
            {message.type === "img" && <ImgMsg message={message} />}
            {message.type === "file" && <FileMsg message={message} />}
            {message.type === "recall" && <RecallMsg message={message} />}
            {message.type === "custom" && message.customExts?.customMsgType === CUSTOM_MSG_TYPE.invite && <CustomMsg message={message} />}
            {message.type === "custom" && message.customExts?.customMsgType === CUSTOM_MSG_TYPE.signIn && <SignInCardMsg message={message} />}
            {message.type === "custom" && message.customExts?.customMsgType === CUSTOM_MSG_TYPE.card && <CardMsg message={message} />}
            {message.type === "custom" && message.customExts?.customMsgType === CUSTOM_MSG_TYPE.code && <CodeMsg message={message} />}
          </div>
        </div>
      </div>
      {showReactionInfo && (
        <ReactionMsg msgId={message.id} reaction={reactionList} />
      )}

      {showThreadInfo && (
        <ThreadMsg
          thread={message.chatThreadOverview}
          clickCount={handleThreadCount}
        />
      )}
    </div>
  );
};

const mapStateToProps = ({ app }) => {
  return {
    reactionMap: app.reactionMap,
    appUserInfo: app.appUserInfo
  };
};

export default memo(connect(mapStateToProps, null)(Message));
