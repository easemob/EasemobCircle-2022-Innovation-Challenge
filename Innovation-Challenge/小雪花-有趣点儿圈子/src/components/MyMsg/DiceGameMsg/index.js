import s from "./index.module.less";
import React, { memo } from "react";
import { Card ,Avatar} from 'antd';
import l1 from '@/assets/myImg2/11.png';
import l2 from '@/assets/myImg2/22.png';
import l3 from '@/assets/myImg2/33.png';
import l4 from '@/assets/myImg2/44.png';
import l5 from '@/assets/myImg2/55.png';
import l6 from '@/assets/myImg2/66.png';
const { Meta } = Card;

const DiceGameMsg = (props) => {
  const { message } = props;
    return (
      <div className={s.main}>
          {message.customExts?.gameInfo === 1 && <Avatar size={64} src={l1}/> }
          {message.customExts?.gameInfo === 2 && <Avatar size={64} src={l2}/> }
          {message.customExts?.gameInfo === 3 && <Avatar size={64} src={l3}/> }
        {message.customExts?.gameInfo === 4 && <Avatar size={64} src={l4}/> }
        {message.customExts?.gameInfo === 5 && <Avatar size={64} src={l5}/> }
        {message.customExts?.gameInfo === 6 && <Avatar size={64} src={l6}/> }
      </div>
  );
};

export default memo(DiceGameMsg);
