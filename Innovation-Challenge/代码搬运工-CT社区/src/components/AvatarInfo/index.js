import DefaultAvatar from '@/assets/images/avatar_default.png';
import DefaultRobotAvatar from '@/assets/images/avatar_robot.png';
import DefaultServer from '@/assets/images/server.png';
import { Avatar, Image } from "antd";
import { memo } from 'react';
import style from './index.module.less';

const DefaultAvaIcon = () => {
    return (
        <img src={DefaultAvatar} alt="avatar" />
    )
}
const DefaultRovbotAvaIcon = () => {
    return (
        <img src={DefaultRobotAvatar} alt="avatar" />
    )
}
const DefaultServerIcon = () => {
    return (
        <img src={DefaultServer} alt="avatar" />
    )
}
const AvatarInfo = ({ size, src, online, isServer, shape = "circle", robot }) => {
    //online  0-离线 1-在线 undefined 不展示在 离线状态
    const setSrc = (e) => {
        e.currentTarget.src = isServer ? DefaultServer : DefaultAvatar;
    }
    return (
        <div className={style.avatarCon}>
            {src ?
                <Avatar shape={shape} size={size || 40} src={<Image preview={false} src={src} onError={(e) => { setSrc(e); }} />}
                    icon={isServer ? <DefaultServerIcon /> : (robot ? <DefaultRovbotAvaIcon /> : <DefaultAvaIcon />)} /> :
                <Avatar shape={shape} size={size || 40} icon={isServer ? <DefaultServerIcon /> : (robot ? <DefaultRovbotAvaIcon /> : <DefaultAvaIcon />)} />}
            {
                online === undefined ? null : <span className={`${style.dot} ${online === 1 ? style.online : style.offline} ${size >= 90 ? style.bigDot : null}`}></span>
            }

        </div>
    );
};

export default memo(AvatarInfo);
