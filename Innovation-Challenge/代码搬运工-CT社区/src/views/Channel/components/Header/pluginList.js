import CloseIcon from "@/components/CloseIcon";
import { openPlugin } from '@/components/Plugin/index';
import React, { memo, useState } from "react";
import { connect } from "react-redux";
import { useParams } from "react-router-dom";
import s from "./plugin.module.less";

const PLUGIN_STOP_ID = '__plugin__shop__id__'

const PluginList = (props) => {
    const { serverRole, appUserInfo, onHandleOperation, onClose, visiblePlugin } = props;
    const { serverId, channelId } = useParams();
    const role = serverRole[serverId];

    const [pluginList, setPluginList] = useState(
        [
            // {
            //     logo: AppLogo,
            //     name: '插件商店',
            //     url: 'http://121.37.205.80/ext/market',
            //     id: 1
            // },
            {
                logo: "http://rmf3cjpb1.hn-bkt.clouddn.com/ext-icon/share.png",
                name: '打卡',
                url: 'http://121.37.205.80:4173/#/ext/reportShare',
                id: 2
            },
            {
                logo: "http://rmf3cjpb1.hn-bkt.clouddn.com/ext-icon/sign.png",
                name: '每日签到',
                url: 'http://121.37.205.80:4173/#/ext/sign',
                id: 3
            },
            {
                logo: "http://rmf3cjpb1.hn-bkt.clouddn.com/ext-icon/robot.png",
                name: '机器人',
                url: 'http://121.37.205.80:4173/#/ext/robot',
                id: 4
            },
            {
                logo: "http://rmf3cjpb1.hn-bkt.clouddn.com/ext-icon/vote.png",
                name: '投票',
                url: 'http://121.37.205.80:4173/#/ext/vote',
                id: 5
            },
            {
                logo: "http://rmf3cjpb1.hn-bkt.clouddn.com/ext-icon/code.png",
                name: '代码片段',
                url: 'http://121.37.205.80:4173/#/ext/code',
                id: 6,
                setting: {
                    width: '720px',
                    height: '600px'
                }
            }
        ]
    )

    const handleShowPluginShop = (item) => {
        if (item.id === PLUGIN_STOP_ID) {
            /** 打开插件商店 */
        } else {
            /** 打开插件 */
            openPlugin(item)
            onClose(false)
        }
    }

    return (
        <div className={s.layout}>
            <div className={s.headerThread}>
                <span className={s.headerTitle}>插件商店</span>
                <div className={s.HeaderIcon} onClick={() => onClose()}>
                    <CloseIcon />
                </div>
            </div>
            <div className={s.list}>
                {pluginList.map((item, index) => {
                    return <div className={s.pluginInfo} title={item.name} key={item.id} onClick={() => handleShowPluginShop(item)}>
                        {
                            item.logo && <img src={item.logo} className={s.pluginImg} alt="logo" />
                        }
                        <div className={s.pluginName}>{item.name}</div>
                    </div>
                })}
                {/* <div className={s.pluginInfo}>
                    <img src={ChannelPlus} className={s.pluginImg} />
                    <div className={s.pluginName}>添加插件</div>
                </div> */}
            </div>
        </div>
    );
};

const mapStateToProps = ({ app }) => {
    return {
        serverRole: app.serverRole,
        appUserInfo: app.appUserInfo
    };
};

const mapDispatchToProps = (dispatch) => {
    return {

    };
};
export default memo(connect(mapStateToProps, mapDispatchToProps)(PluginList));
