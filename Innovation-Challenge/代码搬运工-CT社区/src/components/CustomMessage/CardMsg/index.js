import React, { memo } from "react";
import { openPlugin } from "../../Plugin";
import s from "./index.module.less";
// 自定义消息——卡片消息
const CardMsg = (props) => {
  const { message } = props;
  const {title, smallTitle, description, url} = message.customExts ?? {};

  const handleClick = () => {
    if (!url) return
    openPlugin({url})
  }

  return (
    <div className={s.card} onClick={() => {
        handleClick()
    }}>
        <div className={s.title}>{title}</div>
        <div className={s.desc}>{description}</div>
        <div className={s.delive}></div>
        <div className={s.smallTitle}>{smallTitle}</div>
    </div>
  );
};

export default memo(CardMsg);
