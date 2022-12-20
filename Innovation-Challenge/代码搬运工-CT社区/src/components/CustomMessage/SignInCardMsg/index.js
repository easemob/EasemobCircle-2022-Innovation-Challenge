import { Image } from "antd";
import React, { memo } from "react";
import s from "./index.module.less";
// 自定义消息——打卡卡片
const SignInCardMsg = (props) => {
  const { message } = props;
  const imgUrl = message.customExts?.backgroundUrl;
  return (
    <div className={s.main}>
      <div className={s.imgCon}>
        <Image className={s.imgSrc} src={imgUrl} placeholder={true}
          preview={{
            src: imgUrl,
          }} />
        <div className={s.titleName}>{`${message.customExts?.title}`}</div>
      </div>
    </div>
  );
};

export default memo(SignInCardMsg);
