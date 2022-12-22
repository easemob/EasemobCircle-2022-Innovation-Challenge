package io.agora.service.managers;

import android.text.TextUtils;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.easeui.constants.EaseConstant;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;


public class NotificationMsgManager {
    private static NotificationMsgManager instance;

    private NotificationMsgManager(){}

    public static NotificationMsgManager getInstance() {
        if(instance == null) {
            synchronized (NotificationMsgManager.class) {
                if(instance == null) {
                    instance = new NotificationMsgManager();
                }
            }
        }
        return instance;
    }

    /**
     * Create notification message
     * @param message
     * @param ext
     * @return
     */
    public EMMessage createMessage(String message, Map<String, Object> ext) {
        EMMessage emMessage = EMMessage.createReceiveMessage(EMMessage.Type.TXT);
        emMessage.setFrom(EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID);
        emMessage.setMsgId(UUID.randomUUID().toString());
        emMessage.setStatus(EMMessage.Status.SUCCESS);
        emMessage.addBody(new EMTextMessageBody(message));
        if(ext != null && !ext.isEmpty()) {
            Iterator<String> iterator = ext.keySet().iterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                Object value = ext.get(key);
                putObject(emMessage, key, value);
            }
        }
        emMessage.setUnread(true);
        EMClient.getInstance().chatManager().saveMessage(emMessage);
        return emMessage;
    }

    private void putObject(EMMessage message, String key, Object value) {
        if(TextUtils.isEmpty(key)) {
            return;
        }
        if(value instanceof String) {
            message.setAttribute(key, (String) value);
        }else if(value instanceof Byte) {
            message.setAttribute(key, (Integer) value);
        }else if(value instanceof Character) {
            message.setAttribute(key, (Integer) value);
        }else if(value instanceof Short) {
            message.setAttribute(key, (Integer) value);
        }else if(value instanceof Integer) {
            message.setAttribute(key, (Integer) value);
        }else if(value instanceof Boolean) {
            message.setAttribute(key, (Boolean) value);
        }else if(value instanceof Long) {
            message.setAttribute(key, (Long) value);
        }else if(value instanceof Float) {
            JSONObject object = new JSONObject();
            try {
                object.put(key, value);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            message.setAttribute(key, object);
        }else if(value instanceof Double) {
            JSONObject object = new JSONObject();
            try {
                object.put(key, value);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            message.setAttribute(key, object);
        }else if(value instanceof JSONObject) {
            message.setAttribute(key, (JSONObject) value);
        }else if(value instanceof JSONArray) {
            message.setAttribute(key, (JSONArray) value);
        }else {
            JSONObject object = new JSONObject();
            try {
                object.put(key, value);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            message.setAttribute(key, object);
        }
    }

    /**
     * Create ext map
     * @return
     */
    public Map<String, Object> createMsgExt() {
        return new HashMap<>();
    }

    /**
     * Get latest message
     * @param con
     * @return
     */
    public EMMessage getLastMessageByConversation(EMConversation con) {
        if(con == null) {
            return null;
        }
        return con.getLastMessage();
    }

    /**
     * Get notification conversation
     * @return
     */
    public EMConversation getConversation() {
        return getConversation(true);
    }

    /**
     * Get notification conversation
     * @param createIfNotExists
     * @return
     */
    public EMConversation getConversation(boolean createIfNotExists) {
        return EMClient.getInstance().chatManager().getConversation(EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID
                , EMConversation.EMConversationType.Chat, createIfNotExists);
    }

    /**
     * Get all messages of notification
     * @return
     */
    public List<EMMessage> getAllMessages() {
        return getConversation().getAllMessages();
    }

    /**
     * Check whether is a notification message
     * @param message
     * @return
     */
    public boolean isNotificationMessage(EMMessage message) {
        return message.getType() == EMMessage.Type.TXT
                && TextUtils.equals(message.getFrom(), EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID);
    }

    /**
     * Check whether is a notification conversation
     * @param conversation
     * @return
     */
    public boolean isNotificationConversation(EMConversation conversation) {
        return conversation.getType() == EMConversation.EMConversationType.Chat
                && TextUtils.equals(conversation.conversationId(), EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID);
    }

    /**
     * Get the message content
     * @param message
     * @return
     */
    public String getMessageContent(EMMessage message) {
        if(message.getBody() instanceof EMTextMessageBody) {
            return ((EMTextMessageBody)message.getBody()).getMessage();
        }
        return "";
    }

    /**
     * Update notification message
     * @param message
     * @return
     */
    public boolean updateMessage(EMMessage message) {
        if(message == null || !isNotificationMessage(message)) {
            return false;
        }
        EMClient.getInstance().chatManager().updateMessage(message);
        return true;
    }

    /**
     * Remove notification message
     * @param message
     * @return
     */
    public boolean removeMessage(EMMessage message) {
        if(message == null || !isNotificationMessage(message)) {
            return false;
        }
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID);
        conversation.removeMessage(message.getMsgId());
        return true;
    }

    /**
     * Make all message in notification conversation as read
     */
    public void markAllMessagesAsRead() {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(EaseConstant.DEFAULT_SYSTEM_MESSAGE_ID);
        conversation.markAllMessagesAsRead();
    }
}

