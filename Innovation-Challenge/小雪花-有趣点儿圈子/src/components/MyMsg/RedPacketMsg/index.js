import s from "./index.module.less";
import React, { memo } from "react";
import { Card ,Badge,notification } from 'antd';
const { Meta } = Card;

const RedPacketMsg = (props) => {
  const { message } = props;

    function onClick() {
        notification.info({
            message: `恭喜发财`,
            description:
                '/(ㄒoㄒ)/~~还没做完，一起完善吧...',
            placement:"bottom",
        });
    }

    return (
      <div className={s.main}>
          <Card onClick={onClick}
              hoverable
              style={{ width: 240 }}
              cover={<img alt="恭喜发财" src="https://wanan-1251268525.cos.ap-shanghai.myqcloud.com/uuuu/hongbao.png" />}
          >
              <Meta title="恭喜发财" description="吉祥如意" />
              <div className={s.txt}>{message.msg}</div>
          </Card>
      </div>
  );
};

export default memo(RedPacketMsg);
