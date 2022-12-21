package io.agora.service.global;


public class Constants {
    public static final String USERNAME = "username";
    public static final String PASSWORD = "password";
    public static final String GROUP_CHANGE = "group_change";
    public static final String CHAT_ROOM_CHANGE = "chat_room_change";
    public static final String CONTACT_CHANGE = "contact_change";
    public static final String USERINFO_CHANGE = "userinfo_change";
    public static final String PRESENCES_CHANGED = "presences_changed";
    public static final String SERVER_CHANGED = "server_changed";
    public static final String SERVER_ADDED = "server_added";
    public static final String SERVER_UPDATED = "server_updated";
    public static final String LEAVE_OR_DELETE_SERVER = "leave_or_delete_server";
    public static final String CHANNEL_CHANGED = "channel_changed";
    public static final String CHANNEL_LEAVE = "channel_leave";
    public static final String CHANNEL_DELETE = "channel_delete";
    public static final String NOTIFY_CHANGE = "notify_change";


    public static final String SHOW_SERVER_INVITE_FRAGMENT = "show_server_invite_fragment";
    public static final String SHOW_SERVER_SETTING_FRAGMENT = "show_server_setting_fragment";
    public static final String SHOW_CHANNEL_SETTING_FRAGMENT = "show_channel_setting_fragment";
    public static final String SHOW_CREATE_CHANNEL_FRAGMENT = "show_create_channel_fragment";
    public static final String SHOW_THREAD_SETTING_FRAGMENT = "show_thread_setting_fragment";
    public static final long PRESENCE_SUBSCRIBE_EXPIRY = 7 * 24 * 60 * 60;

    public static final String SYSTEM_MESSAGE_FROM = "from";
    public static final String SYSTEM_MESSAGE_REASON = "reason";
    public static final String SYSTEM_MESSAGE_STATUS = "status";
    public static final String SYSTEM_MESSAGE_GROUP_ID = "groupId";
    public static final String SYSTEM_MESSAGE_NAME = "name";
    public static final String SYSTEM_MESSAGE_INVITER = "inviter";
    public static final String SYSTEM_MESSAGE_EXPIRED = "expired";

    public static final String SYSTEM_CREATE_GROUP = "system_createdGroup";
    public static final String SYSTEM_JOINED_GROUP = "system_joinedGroup";
    public static final String SYSTEM_ADD_CONTACT = "system_add_contact";

    public static final String DEFAULT_SYSTEM_MESSAGE_ID = "em_system";
    public static final String DEFAULT_SYSTEM_MESSAGE_TYPE = "em_system_type";
    public static final String EASE_SYSTEM_NOTIFICATION_TYPE = "em_system_notification_type";
    public static final String SYSTEM_NOTIFICATION_TYPE = "system_notification_type";
    public static final String MESSAGE_CHANGE_RECEIVE = "message_receive";
    public static final String MESSAGE_CHANGE_CMD_RECEIVE = "message_cmd_receive";
    public static final String MESSAGE_CHANGE_RECALL = "message_recall";
    public static final String MESSAGE_CHANGE_CHANGE = "message_change";
    public static final String MESSAGE_FORWARD = "message_forward";
    public static final String MESSAGE_CALL_SAVE = "message_call_save";
    public static final String MESSAGE_NOT_SEND = "message_not_send";

    public static final String CONVERSATION_READ = "conversation_read";
    public static final String CONVERSATION_DELETE = "conversation_delete";

    public static final String CONTACT_ADD = "contact_add";
    public static final String CONTACT_DELETE = "contact_delete";
    public static final String CONTACT_UPDATE = "contact_update";
    public static final String NICK_NAME_CHANGE = "nick_name_change";
    public static final String AVATAR_CHANGE = "avatar_change";
    public static final String REMOVE_BLACK = "remove_black";
    public static final String USER_INFO_CHANGE = "user_info_change";

    public static final String MESSAGE_ATTR_IS_VOICE_CALL = "is_voice_call";
    public static final String MESSAGE_ATTR_IS_VIDEO_CALL = "is_video_call";

    public static final int CHATTYPE_SINGLE = 1;
    public static final int CHATTYPE_GROUP = 2;
    public static final int CHATTYPE_CHATROOM = 3;

    public static final String FORWARD_MSG_ID = "forward_msg_id";
    public static final String HISTORY_MSG_ID = "history_msg_id";

    public static final String SERVER_ID = "server_id";
    public static final String CHANNEL = "channel";
    public static final String CHANNELS = "channels";
    public static final String SERVER = "server";
    public static final String SERVERS = "servers";

    public static final String CHANNEL_ID = "channel_id";
    public static final String MESSAGE_ID = "message_id";

    public static final String THREAD_CHANGE = "thread_change";
    public static final String THREAD_LEAVE = "thread_leave";
    public static final String THREAD_DESTROY = "thread_destroy";
    public static final String THREAD_UPDATE = "thread_update";

    public static final String HOME_CHANGE_MODE = "home_change_mode";


    public static final String THREAD_ID = "thread_id";
    public static final String CHANNEL_NAME = "channel_name";
    public static final String THREAD_NAME = "thread_name";
    public static final String THREAD_DATA = "thread_data";

    public static final String MESSAGE_TYPE_RECALL = "message_recall";
    public static final String MESSAGE_TYPE_RECALLER = "message_recaller";

    public static final String ACCOUNT_CHANGE = "account_change";
    public static final String ACCOUNT_REMOVED = "account_removed";
    public static final String ACCOUNT_CONFLICT = "conflict";
    public static final String ACCOUNT_FORBIDDEN = "user_forbidden";
    public static final String ACCOUNT_KICKED_BY_CHANGE_PASSWORD = "kicked_by_change_password";
    public static final String ACCOUNT_KICKED_BY_OTHER_DEVICE = "kicked_by_another_device";

    public static final String CONTACT_REMOVE = "contact_remove";
    public static final String CONTACT_ACCEPT = "contact_accept";
    public static final String CONTACT_DECLINE = "contact_decline";
    public static final String CONTACT_BAN = "contact_ban";
    public static final String CONTACT_ALLOW = "contact_allow";

    public static final String EM_NOTIFICATION_TYPE = "em_notification_type";

    public static final String SERVER_MEMBER_JOINED_NOTIFY = "server_member_joined_notify";
    public static final String SERVER_MEMBER_BE_REMOVED_NOTIFY = "server_member_be_removed_notify";
    public static final String SERVER_RECEIVE_INVITATION_NOTIFY = "server_receive_invitation_notify";
    public static final String SERVER_INVITAION_BE_ACCEPTED_NOTIFY = "server_invitaion_be_accepted_notify";
    public static final String SERVER_INVITAION_BE_DECLINED_NOTIFY = "server_invitaion_be_declined_notify";
    public static final String SERVER_ROLE_ASSIGNED_NOTIFY = "server_role_assigned_notify";
    public static final String SERVER_MEMBER_LEFT_NOTIFY = "server_member_left_notify";
    public static final String SERVER_DESTROYED_NOTIFY = "server_destroyed_notify";
    public static final String SERVER_UPDATED_NOTIFY = "server_updated_notify";

    public static final String CHANNEL_CREATED_NOTIFY = "channel_created_notify";
    public static final String CHANNEL_DESTORYED_NOTIFY = "channel_destoryed_notify";
    public static final String CHANNEL_UPDATED_NOTIFY = "channel_updated_notify";
    public static final String MEMBER_JOINED_CHANNEL_NOTIFY = "member_joined_channel_notify";
    public static final String MEMBER_LEFT_CHANNEL_NOTIFY = "member_left_channel_notify";
    public static final String MEMBER_REMOVED_FROM_CHANNEL_NOTIFY = "member_removed_from_channel_notify";
    public static final String RECEIVE_INVITATION_NOTIFY = "receive_invitation_notify";
    public static final String INVITAION_BE_ACCEPTED_NOTIFY = "invitaion_be_accepted_notify";
    public static final String INVITAION_BE_DECLINED_NOTIFY = "invitaion_be_declined_notify";
    public static final String MEMBER_MUTE_CHANGED_NOTIFY = "member_mute_changed_notify";

    public static final String CREATE_CHANNEL_MULTIPLY_NOTIFY = "create_channel_multiply_notify";

    public static final String ACCEPT_INVITE_SERVER = "join_server";
    public static final String ACCEPT_INVITE_CHANNEL = "join_channel";
    public static final String INVITE_SERVER = "invite_server";
    public static final String INVITE_CHANNEL = "invite_channel";

    public static final String CUSTOM_MESSAGE_SERVER_ID = "server_id";
    public static final String CUSTOM_MESSAGE_SERVER_NAME = "server_name";
    public static final String CUSTOM_MESSAGE_SERVER_ICON = "icon";
    public static final String CUSTOM_MESSAGE_SERVER_DESC = "desc";
    public static final String CUSTOM_MESSAGE_CHANNEL_ID = "channel_id";
    public static final String CUSTOM_MESSAGE_CHANNEL_NAME = "channel_name";
    public static final String CUSTOM_MESSAGE_CHANNEL_DESC = "channel_desc";

    public static final String SHOW_MODE = "show_mode";
    public static final String NAV_POSITION = "navigation_position";
    public static final String SHOW_RED_DOT ="show_red_dot" ;
}
