import React, { memo } from "react";
import s from "./index.module.less";

/**
 * TODO
 * 自定义消息——转发消息
 * 外观看跟卡片消息很类似
 */
const CardMsg = (props) => {
  const { message } = props;
  
  const {title, description, url} = message.customExts ?? {};

  const handleClick = () => {
    
  }

  return (
    <div className={s.forward} onClick={() => {
        handleClick()
    }}>
        <div className={s.title}>{title}</div>
        <div className={s.desc}>{description}</div>
        <div className={s.delive}></div>
        <div className={s.smallTitle}>聊天记录</div>
    </div>
  );
};

export default memo(CardMsg);
