import React, { memo, useEffect, useState, createRef } from "react";
import { connect } from "react-redux";
import s from "./index.module.less";
import { Modal, message } from 'antd';
import WebIM from "@/utils/WebIM";
import Icon from "@/components/Icon";
import CloseIcon from "@/components/CloseIcon";

const UserInfo = (props) => {
    const { userInfo, setUserInfo, appUserInfo, setAppUserInfo } = props
    const nicknameRef = createRef();
    //const errInfo = err.data?.data ? JSON.parse(err.data.data) : "";
    const myExt = userInfo.ext ? JSON.parse(userInfo.ext) : "";
    const [isModalVisible, setIsModalVisible] = useState(false);
    const showModal = () => {
        setIsModalVisible(true);
        setNameValue(userInfo?.nickname || '');
        setRankValue(myExt?.rankValue || '');
        setVipValue(myExt?.vipValue || '');
    };

    useEffect(() => {
        setTimeout(() => {
            //isModalVisible && nicknameRef?.current && nicknameRef.current.focus();
        },0)
    }, [isModalVisible, nicknameRef])
    useEffect(() => {
        localStorage.setItem("userInfo", JSON.stringify(userInfo));
    }, [userInfo])

    const handleOk = () => {
        if (nameValue === "") return;
        if (rankValue === "") return;
        if (vipValue === "") return;

        //debugger
        let ext  =  JSON.stringify({
            v: 1,
            rankValue,
            vipValue
        });
        // let ext2 = {
        //     v:1,
        //     server_id: 1,
        //     server_name: 2,
        //     icon: 3,
        //     desc: 4
        // };
        WebIM.conn.updateUserInfo({ nickname: nameValue,ext }).then(res => {
            setUserInfo(Object.assign({ ...userInfo }, res.data));
            setAppUserInfo({ ...appUserInfo, [userInfo.username]: { ...appUserInfo[userInfo.username], ...res.data } });
        }).catch(e => {
            message.warn({ content: "昵称修改失败，请重试！" });
        })
        setNameValue("");
        setIsModalVisible(false);
    };

    const handleCancel = () => {
        setIsModalVisible(false);
    };

    const [nameValue, setNameValue] = useState('');
    const [rankValue, setRankValue] = useState('');
    const [vipValue, setVipValue] = useState('');
    const changeNickname = (e) => {
        setNameValue(e.target.value);
    }
    const changeRankValue = (e) => {
        setRankValue(e.target.value);
    }
    const changeVipValue = (e) => {
        setVipValue(e.target.value);
    }

    return (
        <div className={s.container}>
            <div className={s.header}>
                <span className={s.icon}>
                    <Icon name="person_normal" size="24px" />
                </span>
                <span className={s.text}>个人资料</span>
            </div>
            <div className={s.main}>
                <div className={s.item}>
                    <div className={s.info}>
                        <span className={s.nameLeft}>我的昵称</span>
                        <span className={s.nickname}>{userInfo.nickname || userInfo.username}</span>
                    </div>
                    <div className={s.edit} onClick={showModal}>编辑</div>
                </div>
                {/*<div className={s.item}>*/}
                {/*    <div className={s.info}>*/}
                {/*        <span className={s.nameLeft}>扩展信息</span>*/}
                {/*        <span className={s.nickname}>{userInfo.ext || userInfo.ext}</span>*/}
                {/*    </div>*/}
                {/*</div>*/}
                <div className={s.item}>
                    <div className={s.info}>
                        <span className={s.nameLeft}>等级</span>
                        <span className={s.nickname}>{myExt.rankValue}</span>
                    </div>
                </div>
                <div className={s.item}>
                    <div className={s.info}>
                        <span className={s.nameLeft}>VIP信息</span>
                        <span className={s.nickname}>{myExt.vipValue}</span>
                    </div>
                </div>
            </div>

            <Modal className={`userInfoModal`} destroyOnClose={true} title="更改昵称" visible={isModalVisible} onCancel={handleCancel} footer={null} closeIcon={<CloseIcon />}>
                <div className={s.updateNickname}>
                    <div>
                        <span className={s.title}>昵称</span>
                        <div className={s.updateCon}>
                            <input ref={nicknameRef} className={s.input} value={nameValue} maxLength={16} onChange={(e) => changeNickname(e)} placeholder="请输入昵称"></input>
                            <span className={s.count}>{nameValue.length}/16</span>

                        </div>
                    </div>
                    <div>
                        <span className={s.title}>等级(1-5之间)</span>
                        <div className={s.updateCon}>
                            <input className={s.input} value={rankValue} maxLength={16} onChange={(e) => changeRankValue(e)} placeholder="请输入等级"></input>
                            {/*<span className={s.count}>{nameValue.length}/16</span>*/}

                        </div>
                    </div>
                    <div>
                        <span className={s.title}>VIP信息(1-5之间)</span>
                        <div className={s.updateCon}>
                            <input className={s.input} value={vipValue} maxLength={16} onChange={(e) => changeVipValue(e)} placeholder="请输入VIP信息"></input>
                            {/*<span className={s.count}>{nameValue.length}/16</span>*/}

                        </div>
                    </div>
                    <div className={`circleBtn circleBtn106 ${s.confirm} ${nameValue === "" ? "disable" : null}`} onClick={handleOk}>确认</div>
                </div>
            </Modal>
        </div>
    );
};
const mapStateToProps = ({ app }) => {
    return {
        userInfo: app.userInfo,
        appUserInfo: app.appUserInfo,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        setUserInfo: (params) => {
            return dispatch({
                type: "app/setUserInfo",
                payload: params
            });
        },
        setAppUserInfo: (params) => {
            return dispatch({
                type: "app/setAppUserInfo",
                payload: params
            });
        },
    };
};
export default memo(connect(mapStateToProps, mapDispatchToProps)(UserInfo));
