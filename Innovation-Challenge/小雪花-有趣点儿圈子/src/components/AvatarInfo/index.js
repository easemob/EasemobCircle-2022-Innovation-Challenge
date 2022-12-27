import { Avatar, Image ,Badge} from "antd";
import DefaultAvatar from '@/assets/images/avatar_default.png';
import DefaultServer from '@/assets/images/server.png';
import style from './index.module.less';
import { memo } from 'react'
import { ClockCircleOutlined } from '@ant-design/icons';

const DefaultAvaIcon = () => {
    return (
        <img src={DefaultServer} alt="avatar" />
    )
}
const DefaultServerIcon = () => {
    return (
        <img src={DefaultServer} alt="avatar" />
    )
}

const VipAvaIcon = ({extInfo}) => {
    return (
        <img src={DefaultServer} alt="avatar" />
    )
}
const AvatarInfo = ({ size, src, online, isServer, shape = "circle",extInfo }) => {
    //online  0-离线 1-在线 undefined 不展示在 离线状态
    const setSrc = (e) => {
        e.currentTarget.src = isServer ? DefaultServer : DefaultAvatar;
    }
    return (
        <div className={style.avatarCon}>
            {src ?
                <Badge color="#f50" text="" count={(!isServer && extInfo?.vipValue === "1") ? <ClockCircleOutlined style={{ color: '#f5222d' }} /> : ""  } >
                    <Avatar shape={shape} size={size || 40} src={<Image preview={false} src={src} onError={(e) => { setSrc(e); }} />} icon={isServer ? <DefaultServerIcon /> : (extInfo ? <VipAvaIcon extInfo={extInfo} /> : <DefaultAvaIcon />)  } />
                </Badge> :
                <Badge color="#f50" text="" count={(!isServer && extInfo?.vipValue === "1") ? <ClockCircleOutlined style={{ color: '#f5222d' }} /> : ""  } >
                    <Avatar shape={shape} size={size || 40} icon={isServer ? <DefaultServerIcon /> : (extInfo ? <VipAvaIcon extInfo={extInfo} /> : <DefaultAvaIcon />) } />
                </Badge>
            }
            {online === undefined ? null : <span className={`${style.dot} ${online === 1 ? style.online : style.offline} ${size >= 90 ? style.bigDot : null}`}></span>}
        </div>
    );
};

export default memo(AvatarInfo);
