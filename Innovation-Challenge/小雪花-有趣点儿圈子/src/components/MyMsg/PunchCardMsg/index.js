import s from "./index.module.less";
import React, { memo } from "react";
import { Card ,Avatar} from 'antd';
import st from '@/assets/myImg/1.png';
import jd from '@/assets/myImg/2.png';
import bu from '@/assets/myImg/3.png';
import { EditOutlined, EllipsisOutlined, SettingOutlined,HeartOutlined,ShareAltOutlined } from '@ant-design/icons';
const { Meta } = Card;

const PunchCardMsg = (props) => {
  const { message } = props;
  const img = "https://wanan-1251268525.cos.ap-shanghai.myqcloud.com/uuuu/"+message.customExts.uCardId+".png";
    switch (message.customExts.uCardId) {
        case 1:
            message.customExts.uInfo = "早安世界";
            break;
        case 2:
            message.customExts.uInfo = "每日阅读打卡";
            break;
        case 3:
            message.customExts.uInfo = "好好学习，天天向上";
            break;
        case 4:
            message.customExts.uInfo = "好运连连";
            break;
        default:
            break;
    }
    return (
      <div className={s.main}>
        <Card
            style={{ width: 300 }}
            cover={
              <img
                  alt="example"
                  src={img}
              />
            }
            actions={[
              <HeartOutlined key="setting" title="点赞" />,
              <ShareAltOutlined key="edit" title="分享"/>,
              <EllipsisOutlined key="ellipsis" title="更多" />,
            ]}
        >
          <Meta
              avatar={<Avatar src="https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg" />}
              title={message.customExts?.uName}
              description={ message.customExts?.uInfo}
          />
        </Card>
      </div>
  );
};

export default memo(PunchCardMsg);
