import { CHAT_TYPE } from "@/consts";
import WebIM from "./WebIM";

/**
 * send custom message
 * @param {object} optionn.channelId 频道ID
 * @param {object} optionn.customEvent 自定义事件类型
 * @param {object} optionn.customExts 扩展字段
 * @param {object} optionn.ext 频道ID
 */
export const sendCustomMessage = (config) => {
    const { channelId: to, customEvent, customExts, ext = {} } = config
    let option = {
        // 会话类型，设置为群聊。
        chatType: CHAT_TYPE.groupChat,
        /**
         * 消息类型
         */
        type: 'custom',
        /**
         * 消息接收方, 发送频道消息
         */
        to,
        customEvent,
        customExts,
        ext
    }
    console.log({ option })
    let msg = WebIM.message.create(option);

    return WebIM.conn.send(msg).then(() => msg)
}