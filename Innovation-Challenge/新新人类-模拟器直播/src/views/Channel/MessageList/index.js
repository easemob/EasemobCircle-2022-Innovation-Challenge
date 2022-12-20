import React, { memo } from "react";
import { MESSAGE_ITEM_SOURCE, SCROLL_WARP_ID } from "@/consts";
import { Spin } from "antd";
import MessageLeft from "@/components/MessageLeft";

import InfiniteScroll from "react-infinite-scroll-component";
import WebIM from "@/utils/WebIM";
import { connect } from "react-redux";

const PAGE_SIZE = 20;

const MessageList = (props) => {
  const {
    messageInfo,
    channelId,
    pushChatMessage,
    setMsgReaction,
    handleOperation,
    className,
  } = props;

  const loadMoreData = () => {
    getHistoryMsg({ cursor: messageInfo?.cursor });
  };

  const getHistoryMsg = ({ cursor = "" }) => {
    WebIM.conn
      .getHistoryMessages({
        targetId: channelId,
        pageSize: PAGE_SIZE,
        chatType: "groupChat",
        cursor,
      })
      .then((res) => {
        res.messages.forEach((item) => {
          setMsgReaction({
            msgId: item.id,
            reactions: item.reactions,
          });
        });
        pushChatMessage({
          chatType: "groupChat",
          fromId: channelId,
          messageInfo: {
            list: res.messages,
            cursor: res.cursor,
            loadCount: res.messages.length,
          },
          reset: cursor ? false : true,
        });
      });
  };

  return (
    <div id={SCROLL_WARP_ID} className={className}>
      <InfiniteScroll
        inverse={true}
        dataLength={messageInfo?.list?.length || 0}
        next={loadMoreData}
        hasMore={messageInfo?.loadCount >= PAGE_SIZE}
        style={{
          display: "flex",
          flexDirection: "column-reverse",
          minHeight: "435px",
        }}
        loader={<Spin />}
        endMessage={<div style={{ textAlign: "center" }}>没有更多消息啦～</div>}
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
    </div>
  );
};

const mapDispatchToProps = (dispatch) => {
  return {
    pushChatMessage: (params) => {
      return dispatch({
        type: "app/pushChatMessage",
        payload: params,
      });
    },
    setMsgReaction: (params) => {
      return dispatch({
        type: "app/setMsgReaction",
        payload: params,
      });
    },
  };
};

export default memo(connect(mapDispatchToProps)(MessageList));
