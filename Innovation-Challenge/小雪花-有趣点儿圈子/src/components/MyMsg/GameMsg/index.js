import s from "./index.module.less";
import React, { memo } from "react";
import { Card ,Avatar} from 'antd';
import st from '@/assets/myImg/1.png';
import jd from '@/assets/myImg/2.png';
import bu from '@/assets/myImg/3.png';
const { Meta } = Card;

const GameMsg = (props) => {
  const { message } = props;
    return (
      <div className={s.main}>
          {message.customExts?.gameInfo === 1 && <Avatar size={64} src={st}/> }
          {message.customExts?.gameInfo === 2 && <Avatar size={64} src={jd}/> }
          {message.customExts?.gameInfo === 3 && <Avatar size={64} src={bu}/> }
      </div>
  );
};

export default memo(GameMsg);
