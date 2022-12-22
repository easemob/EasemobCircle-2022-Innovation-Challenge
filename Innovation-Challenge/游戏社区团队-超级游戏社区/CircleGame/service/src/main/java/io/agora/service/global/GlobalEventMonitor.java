package io.agora.service.global;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.StringRes;

import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.EMChatThreadChangeListener;
import com.hyphenate.EMCircleChannelListener;
import com.hyphenate.EMCircleServerListener;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMContactListener;
import com.hyphenate.EMConversationListener;
import com.hyphenate.EMError;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMCircleChannel;
import com.hyphenate.chat.EMCircleChannelInviteInfo;
import com.hyphenate.chat.EMCircleServerEvent;
import com.hyphenate.chat.EMCircleUserRole;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.easeui.manager.EaseAtMessageHelper;
import com.hyphenate.easeui.manager.EaseChatPresenter;
import com.hyphenate.easeui.manager.EaseSystemMsgManager;
import com.hyphenate.easeui.model.EaseEvent;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.UUID;
import java.util.concurrent.ConcurrentLinkedQueue;

import io.agora.service.BaseApplication;
import io.agora.service.R;
import io.agora.service.bean.CustomInfo;
import io.agora.service.bean.ThreadData;
import io.agora.service.bean.channel.ChannelEventNotifyBean;
import io.agora.service.bean.channel.ChannelInvitationNotifyBean;
import io.agora.service.bean.channel.ChannelMemberRemovedNotifyBean;
import io.agora.service.bean.channel.ChannelMuteNotifyBean;
import io.agora.service.bean.channel.ChannelUpdateNotifyBean;
import io.agora.service.bean.server.ServerInvitationNotifyBean;
import io.agora.service.bean.server.ServerMemberNotifyBean;
import io.agora.service.bean.server.ServerMembersNotifyBean;
import io.agora.service.bean.server.ServerRoleChangeNotifyBean;
import io.agora.service.db.DatabaseManager;
import io.agora.service.db.dao.CircleChannelDao;
import io.agora.service.db.dao.CircleServerDao;
import io.agora.service.db.dao.CircleUserDao;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.repo.EMContactManagerRepository;
import io.agora.service.repo.EMPushManagerRepository;
import io.agora.service.utils.CircleUtils;
import io.agora.service.utils.InviteMessageStatus;
import io.agora.service.utils.PushAndMessageHelper;

/**
 * 主要用于chat过程中的全局监听，并对相应的事件进行处理
 * {@link #init(Context context)}方法建议在登录成功以后进行调用
 */
public class GlobalEventMonitor extends EaseChatPresenter {
    private static final String TAG = GlobalEventMonitor.class.getSimpleName();
    private static final int HANDLER_SHOW_TOAST = 0;
    private static final int HANDLER_TASK = 1;
    private static GlobalEventMonitor instance;
    private final ChatConnectionListener chatConnectionListener;
    private final ChatMultiDeviceListener chatMultiDeviceListener;
    private final ChatContactListener chatContactListener;
    private final ChatConversationListener chatConversationListener;
    private final ChatServerListener chatServerListener;
    private final ChatChannelListener chatChannelListener;
    private final ChatThreadListener chatThreadListener;
    private boolean isGroupsSyncedWithServer = false;
    private boolean isContactsSyncedWithServer = false;
    private boolean isBlackListSyncedWithServer = false;
    private boolean isPushConfigsWithServer = false;
    private Context applicationContext;
    protected Handler handler;

    private Queue<String> msgQueue = new ConcurrentLinkedQueue<>();
    private Queue<Runnable> tasks = new ConcurrentLinkedQueue<>();

    private GlobalEventMonitor() {
        chatConnectionListener = new ChatConnectionListener();
        chatMultiDeviceListener = new ChatMultiDeviceListener();
        chatContactListener = new ChatContactListener();
        chatConversationListener = new ChatConversationListener();
        chatServerListener = new ChatServerListener();
        chatChannelListener = new ChatChannelListener();
        chatThreadListener = new ChatThreadListener();
        initListener();
    }

    public static GlobalEventMonitor getInstance() {
        if (instance == null) {
            synchronized (GlobalEventMonitor.class) {
                if (instance == null) {
                    instance = new GlobalEventMonitor();
                }
            }
        }
        return instance;
    }

    /**
     * 将需要登录成功进入MainActivity中初始化的逻辑，放到此处进行处理
     */
    public void init(Context context) {
        applicationContext = context.getApplicationContext();
        initHandler(applicationContext.getMainLooper());
    }

    private void initListener() {

        //添加网络连接状态监听
        EMClient.getInstance().addConnectionListener(chatConnectionListener);
        //添加多端登录监听
        EMClient.getInstance().addMultiDeviceListener(chatMultiDeviceListener);
        //添加联系人监听
        EMClient.getInstance().contactManager().setContactListener(chatContactListener);
        //添加对会话的监听（监听已读回执）
        EMClient.getInstance().chatManager().addConversationListener(chatConversationListener);
        //添加对社区的监听
        EMClient.getInstance().chatCircleManager().addServerListener(chatServerListener);
        //添加对频道的监听
        EMClient.getInstance().chatCircleManager().addChannelListener(chatChannelListener);
        //添加对子区的监听
        EMClient.getInstance().chatThreadManager().addChatThreadChangeListener(chatThreadListener);
    }

    public void initHandler(Looper looper) {
        handler = new Handler(looper) {
            @Override
            public void handleMessage(Message msg) {
                switch (msg.what) {
                    case HANDLER_SHOW_TOAST:
                        handleShowToast(msg);
                        break;
                    case HANDLER_TASK:
                        handleExecuteTasks(msg);
                        break;
                }
            }
        };
        while (!msgQueue.isEmpty()) {
            showToast(msgQueue.remove());
        }
        while (!tasks.isEmpty()) {
            executeTask(tasks.poll());
        }
    }

    private void handleExecuteTasks(Message msg) {
        Object obj = msg.obj;
        if (obj instanceof Runnable) {
            handler.post((Runnable) obj);
        }
    }

    private void handleShowToast(Message msg) {
        Object obj = msg.obj;
        if (obj instanceof String) {
            String str = (String) obj;
            //ToastUtils.showToast(str);
            Toast.makeText(applicationContext, str, Toast.LENGTH_SHORT).show();
        }
    }

    void showToast(@StringRes int mesId) {
        showToast(context.getString(mesId));
    }

    void showToast(final String message) {
        Log.d(TAG, "receive invitation to join the group：" + message);
        if (handler != null) {
            Message msg = Message.obtain(handler, HANDLER_SHOW_TOAST, message);
            handler.sendMessage(msg);
        } else {
            msgQueue.add(message);
        }
    }

    private void executeTask(Runnable runnable) {
        if (handler != null) {
            Message msg = Message.obtain(handler, HANDLER_TASK, runnable);
            handler.sendMessage(msg);
        } else {
            tasks.add(runnable);
        }
    }

    @Override
    public void onMessageReceived(List<EMMessage> messages) {
        super.onMessageReceived(messages);
        EaseEvent event = EaseEvent.create(Constants.MESSAGE_CHANGE_RECEIVE, EaseEvent.TYPE.MESSAGE);
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).post(event);
        for (EMMessage message : messages) {
            EMLog.d(TAG, "onMessageReceived id : " + message.getMsgId());
            EMLog.d(TAG, "onMessageReceived: " + message.getType());
            // 如果设置群组离线消息免打扰，则不进行消息通知
            List<String> disabledIds = EMClient.getInstance().pushManager().getNoPushGroups();
            if (disabledIds != null && disabledIds.contains(message.conversationId())) {
                return;
            }
            // in background, do not refresh UI, notify it in notification bar
            if (!((BaseApplication) BaseApplication.getContext()).getLifecycleCallbacks().isFront()) {
                getNotifier().notify(message);
            }
            //notify new message
            getNotifier().vibrateAndPlayTone(message);
        }
    }


    @Override
    public void onCmdMessageReceived(List<EMMessage> messages) {
        super.onCmdMessageReceived(messages);
        EaseEvent event = EaseEvent.create(Constants.MESSAGE_CHANGE_CMD_RECEIVE, EaseEvent.TYPE.MESSAGE);
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).post(event);
    }

    @Override
    public void onMessageRead(List<EMMessage> messages) {
        super.onMessageRead(messages);
        EaseEvent event = EaseEvent.create(Constants.MESSAGE_CHANGE_RECALL, EaseEvent.TYPE.MESSAGE);
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).post(event);
    }

    @Override
    public void onMessageRecalled(List<EMMessage> messages) {

        for (EMMessage msg : messages) {
            if (msg.getChatType() == EMMessage.ChatType.GroupChat && EaseAtMessageHelper.get().isAtMeMsg(msg)) {
                EaseAtMessageHelper.get().removeAtMeGroup(msg.getTo());
            }
            EMMessage msgNotification = EMMessage.createReceiveMessage(EMMessage.Type.TXT);
            String text = null;
            String recaller = msg.getRecaller();
            String from = msg.getFrom();
            if ((!TextUtils.isEmpty(recaller)) && !TextUtils.equals(recaller, from)) {
                text = String.format(context.getString(R.string.msg_recall_by_another), recaller, from);
            } else {
                text = String.format(context.getString(R.string.msg_recall_by_user), from);
            }
            EMTextMessageBody txtBody = new EMTextMessageBody(text);
            msgNotification.addBody(txtBody);
            msgNotification.setDirection(msg.direct());
            msgNotification.setFrom(msg.getFrom());
            msgNotification.setTo(msg.getTo());
            msgNotification.setUnread(false);
            msgNotification.setMsgTime(msg.getMsgTime());
            msgNotification.setLocalTime(msg.getMsgTime());
            msgNotification.setChatType(msg.getChatType());
            msgNotification.setAttribute(Constants.MESSAGE_TYPE_RECALL, true);
            msgNotification.setAttribute(Constants.MESSAGE_TYPE_RECALLER, recaller);
            msgNotification.setStatus(EMMessage.Status.SUCCESS);
            EMClient.getInstance().chatManager().saveMessage(msgNotification);
        }

        EaseEvent event = EaseEvent.create(Constants.MESSAGE_CHANGE_RECALL, EaseEvent.TYPE.MESSAGE);
        LiveEventBus.get(Constants.MESSAGE_CHANGE_CHANGE).post(event);
    }

    private class ChatConversationListener implements EMConversationListener {

        @Override
        public void onCoversationUpdate() {

        }

        @Override
        public void onConversationRead(String from, String to) {
            EaseEvent event = EaseEvent.create(Constants.CONVERSATION_READ, EaseEvent.TYPE.MESSAGE);
            LiveEventBus.get(Constants.CONVERSATION_READ).post(event);
        }
    }

    private class ChatConnectionListener implements EMConnectionListener {

        @Override
        public void onConnected() {
            EMLog.i(TAG, "onConnected");
            if (!EMClient.getInstance().isLoggedInBefore()) {
                return;
            }

            if (!isContactsSyncedWithServer) {
                EMLog.i(TAG, "isContactsSyncedWithServer");
                new EMContactManagerRepository().fetchContactListFromServer(null);
                isContactsSyncedWithServer = true;
            }
//            if(!isBlackListSyncedWithServer) {
//                EMLog.i(TAG, "isBlackListSyncedWithServer");
//                new EMContactManagerRepository().getBlackContactList(null);
//                isBlackListSyncedWithServer = true;
//            }
            if (!isPushConfigsWithServer) {
                EMLog.i(TAG, "isPushConfigsWithServer");
                //首先获取push配置，否则获取push配置项会为空
                new EMPushManagerRepository().fetchPushConfigsFromServer();
                isPushConfigsWithServer = true;
            }
        }

        /**
         * 用来监听账号异常
         *
         * @param error
         */
        @Override
        public void onDisconnected(int error) {
            EMLog.i(TAG, "onDisconnected =" + error);
            String event = null;
            if (error == EMError.USER_REMOVED) {
                event = Constants.ACCOUNT_REMOVED;
            } else if (error == EMError.USER_LOGIN_ANOTHER_DEVICE
                    || error == EMError.USER_BIND_ANOTHER_DEVICE
                    || error == EMError.USER_DEVICE_CHANGED
                    || error == EMError.USER_LOGIN_TOO_MANY_DEVICES) {
                event = Constants.ACCOUNT_CONFLICT;
            } else if (error == EMError.SERVER_SERVICE_RESTRICTED) {
                event = Constants.ACCOUNT_FORBIDDEN;
            } else if (error == EMError.USER_KICKED_BY_CHANGE_PASSWORD) {
                event = Constants.ACCOUNT_KICKED_BY_CHANGE_PASSWORD;
            } else if (error == EMError.USER_KICKED_BY_OTHER_DEVICE) {
                event = Constants.ACCOUNT_KICKED_BY_OTHER_DEVICE;
            }
            if (!TextUtils.isEmpty(event)) {
                LiveEventBus.get(Constants.ACCOUNT_CHANGE).post(new EaseEvent(event, EaseEvent.TYPE.ACCOUNT));
                EMLog.i(TAG, event);
            }
        }
    }

    //这里主要做些同步数据库和发送通知事件方便相关UI接收到通知事件进行刷新等操作
    private class ChatServerListener implements EMCircleServerListener {

        @Override
        public void onServerDestroyed(String serverId, String initiator) {
            Map<String, CircleServer> userJoinedSevers = AppUserInfoManager.getInstance().getUserJoinedSevers();
            if (userJoinedSevers != null) {
                userJoinedSevers.remove(serverId);
            }
            CircleServerDao serverDao = DatabaseManager.getInstance().getServerDao();
            if (serverDao != null) {
                CircleServer serverDeleted = serverDao.getServerById(serverId);
                if (serverDeleted != null) {
                    serverDao.deleteByServerId(serverId);//room会自动通过livedata帮助管理UI刷新
                    ToastUtils.showShort(applicationContext.getString(R.string.circle_delete_server, initiator, serverDeleted.name));
                }
            }
        }

        @Override
        public void onServerUpdated(EMCircleServerEvent event) {
            String serverId = event.getId();
            CircleServer circleServer = getServerDao().getServerById(serverId);
            if (circleServer != null) {
                String serverName = event.getName();
                String serverDesc = event.getDesc();
                String serverExt = event.getExt();
                String serverIcon = event.getIcon();
                if (serverName != null) {
                    circleServer.name = serverName;
                }
                if (serverDesc != null) {
                    circleServer.desc = serverDesc;
                }
                if (serverExt != null) {
                    circleServer.custom = serverExt;
                }
                if (serverIcon != null) {
                    circleServer.icon = serverIcon;
                }
                getServerDao().updateCircleServer(circleServer);
            }
            LiveEventBus.get(Constants.SERVER_UPDATED_NOTIFY).post(event);
        }

        @Override
        public void onMemberJoinedServer(String serverId, String member) {
            CircleServer server = getServerDao().getServerById(serverId);
            if (server != null) {
                ToastUtils.showShort(applicationContext.getString(R.string.circle_join_server, member, server.name));
            }
            LiveEventBus.get(Constants.SERVER_MEMBER_JOINED_NOTIFY).post(new ServerMemberNotifyBean(serverId, member));
        }

        @Override
        public void onMemberLeftServer(String serverId, String member) {
            CircleServer server = getServerDao().getServerById(serverId);
            if (server != null) {
                ToastUtils.showShort(applicationContext.getString(R.string.circle_leave_server, member, server.name));
            }
            LiveEventBus.get(Constants.SERVER_MEMBER_LEFT_NOTIFY).post(new ServerMemberNotifyBean(serverId, member));
        }

        @Override
        public void onMemberRemovedFromServer(String serverId, List<String> members) {
            LiveEventBus.get(Constants.SERVER_MEMBER_BE_REMOVED_NOTIFY).post(new ServerMembersNotifyBean(serverId, members));
        }

        @Override
        public void onReceiveInvitation(EMCircleServerEvent event, String inviter) {
            Log.e("TAG", "onReceive ServerInvitation serverId=" + event.getId() + "server name=" + event.getName());
            Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    if (event == null) {
                        Log.e(TAG, "onReceive server Invitation ,but event is null");
                        return;
                    }
                    Activity currentActivity = ((BaseApplication) BaseApplication.getContext()).getLifecycleCallbacks().current();
                    CustomInfo info = new CustomInfo();
                    info.setServerId(event.getId());
                    info.setServerDesc(event.getDesc());
                    info.setServerIcon(event.getIcon());
                    info.setServerName(event.getName());
                    info.setInviter(event.getFrom());
                    CircleUtils.showServerInviteDialog(currentActivity, info);

                    LiveEventBus.get(Constants.SERVER_RECEIVE_INVITATION_NOTIFY).post(new ServerInvitationNotifyBean(event, inviter));
                }
            };
            executeTask(runnable);
        }

        @Override
        public void onInvitationBeAccepted(String serverId, String invitee) {
            LiveEventBus.get(Constants.SERVER_INVITAION_BE_ACCEPTED_NOTIFY).post(new ServerMemberNotifyBean(serverId, invitee));
        }

        @Override
        public void onInvitationBeDeclined(String serverId, String invitee) {
            LiveEventBus.get(Constants.SERVER_INVITAION_BE_DECLINED_NOTIFY).post(new ServerMemberNotifyBean(serverId, invitee));
        }

        @Override
        public void onRoleAssigned(String serverId, String member, EMCircleUserRole role) {
            if (TextUtils.equals(member, AppUserInfoManager.getInstance().getCurrentUserName())) {
                AppUserInfoManager.getInstance().saveSelfServerRole(serverId, role.getRoleId());
            }
            LiveEventBus.get(Constants.SERVER_ROLE_ASSIGNED_NOTIFY).post(new ServerRoleChangeNotifyBean(serverId, member, role));
        }
    }

    private class ChatChannelListener implements EMCircleChannelListener {

        @Override
        public void onChannelCreated(String serverId, String channelId, String creator) {
            EMClient.getInstance().chatCircleManager().fetchChannelDetail(serverId, channelId, new EMValueCallBack<EMCircleChannel>() {
                @Override
                public void onSuccess(EMCircleChannel value) {
                    getChannelDao().insert(new CircleChannel(value));
                }

                @Override
                public void onError(int error, String errorMsg) {

                }
            });
            LiveEventBus.get(Constants.CHANNEL_CREATED_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, creator));
        }

        @Override
        public void onChannelDestroyed(String serverId, String channelId, String initiator) {
            getChannelDao().deleteByChannelId(channelId);
            LiveEventBus.get(Constants.CHANNEL_DESTORYED_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, initiator));
        }

        @Override
        public void onChannelUpdated(String serverId, String channelId, String channelName, String channelDesc, String initiator) {
            CircleChannel circleChannel = getChannelDao().getChannelByChannelID(channelId);
            if (circleChannel != null) {
                circleChannel.name = channelName;
                circleChannel.desc = channelDesc;
                getChannelDao().updateChannel(circleChannel);
            }
            LiveEventBus.get(Constants.CHANNEL_UPDATED_NOTIFY).post(new ChannelUpdateNotifyBean(serverId, channelId, initiator, channelName, channelDesc));
        }

        @Override
        public void onMemberJoinedChannel(String serverId, String channelId, String member) {
            CircleChannel channel = getChannelDao().getChannelByChannelID(channelId);
            if (channel != null) {
                List<CircleUser> channelUsers = channel.channelUsers;
                if (channelUsers != null) {
                    channelUsers.add(new CircleUser(member));
                    getChannelDao().updateChannel(channel);
                }
                ToastUtils.showShort(applicationContext.getString(R.string.circle_join_channel, member, channel.name));
            }
            LiveEventBus.get(Constants.MEMBER_JOINED_CHANNEL_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, member));
        }

        @Override
        public void onMemberLeftChannel(String serverId, String channelId, String member) {
            CircleChannel channel = getChannelDao().getChannelByChannelID(channelId);
            if (channel != null) {
                List<CircleUser> channelUsers = channel.channelUsers;
                if (channelUsers != null) {
                    for (int i = 0; i < channelUsers.size(); i++) {
                        CircleUser circleUser = channelUsers.get(i);
                        if (circleUser.username.equals(member)) {
                            channelUsers.remove(circleUser);
                            break;
                        }
                    }
                    getChannelDao().updateChannel(channel);
                }
                ToastUtils.showShort(applicationContext.getString(R.string.circle_leave_channel, member, channel.name));
            }
            LiveEventBus.get(Constants.MEMBER_LEFT_CHANNEL_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, member));
        }

        @Override
        public void onMemberRemovedFromChannel(String serverId, String channelId, String member, String initiator) {
            LiveEventBus.get(Constants.MEMBER_REMOVED_FROM_CHANNEL_NOTIFY).post(new ChannelMemberRemovedNotifyBean(serverId, channelId, member, initiator));
        }

        @Override
        public void onReceiveInvitation(EMCircleChannelInviteInfo inviteInfo, String inviter) {
            Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    if (inviteInfo == null) {
                        Log.e(TAG, "onReceive channel Invitation ,but inviteinfo is null");
                        return;
                    }
                    Activity currentActivity = ((BaseApplication) BaseApplication.getContext()).getLifecycleCallbacks().current();

                    CustomInfo info = new CustomInfo();
                    info.setInviter(inviter);
                    info.setServerId(inviteInfo.getServerId());
                    info.setServerName(inviteInfo.getServerName());
                    info.setServerIcon(inviteInfo.getServerIcon());
                    info.setChannelId(inviteInfo.getChannelId());
                    info.setChannelDesc(inviteInfo.getChannelDesc());
                    info.setChannelName(inviteInfo.getChannelName());

                    CircleUtils.showChannelInviteDialog(currentActivity, info);
                    LiveEventBus.get(Constants.RECEIVE_INVITATION_NOTIFY).post(new ChannelInvitationNotifyBean(inviteInfo, inviter));
                }
            };
            executeTask(runnable);
        }

        @Override
        public void onInvitationBeAccepted(String serverId, String channelId, String invitee) {
            LiveEventBus.get(Constants.INVITAION_BE_ACCEPTED_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, invitee));
        }

        @Override
        public void onInvitationBeDeclined(String serverId, String channelId, String invitee) {
            LiveEventBus.get(Constants.INVITAION_BE_DECLINED_NOTIFY).post(new ChannelEventNotifyBean(serverId, channelId, invitee));
        }

        @Override
        public void onMemberMuteChanged(String serverId, String channelId, boolean isMuted, List<String> muteMembers) {
            LiveEventBus.get(Constants.MEMBER_MUTE_CHANGED_NOTIFY).post(new ChannelMuteNotifyBean(serverId, channelId, isMuted, muteMembers));
        }
    }

    private class ChatThreadListener implements EMChatThreadChangeListener {

        @Override
        public void onChatThreadCreated(EMChatThreadEvent event) {
            if(event!=null) {
                LiveEventBus.get(Constants.THREAD_CHANGE).post(event.getChatThread());
            }
        }

        @Override
        public void onChatThreadUpdated(EMChatThreadEvent event) {
            if(event!=null) {
                LiveEventBus.get(Constants.THREAD_CHANGE).post(event.getChatThread());
            }
        }

        @Override
        public void onChatThreadDestroyed(EMChatThreadEvent event) {
            if(event!=null) {
                EMChatThread chatThread = event.getChatThread();
                ThreadData threadData = new ThreadData(chatThread.getChatThreadName(), chatThread.getChatThreadId(), chatThread.getParentId());
                LiveEventBus.get(Constants.THREAD_DESTROY).post(threadData);
            }
        }

        @Override
        public void onChatThreadUserRemoved(EMChatThreadEvent event) {

        }
    }

    private class ChatContactListener implements EMContactListener {

        @Override
        public void onContactAdded(String username) {
            EMLog.i("ChatContactListener", "onContactAdded");
            String[] userId = new String[1];
            userId[0] = username;
            EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userId, new EMValueCallBack<Map<String, EMUserInfo>>() {
                @Override
                public void onSuccess(Map<String, EMUserInfo> value) {
                    EMUserInfo userInfo = value.get(username);
                    CircleUser circleUser = new CircleUser();
                    circleUser.setUsername(username);
                    if (userInfo != null) {
                        circleUser.setNickname(userInfo.getNickName());
                        circleUser.setEmail(userInfo.getEmail());
                        circleUser.setAvatar(userInfo.getAvatarUrl());
                        circleUser.setBirth(userInfo.getBirth());
                        circleUser.setGender(userInfo.getGender());
                        circleUser.setExt(userInfo.getExt());
                        circleUser.setContact(0);
                        circleUser.setSign(userInfo.getSignature());
                    }
                    DatabaseManager.getInstance().getUserDao().insert(circleUser);
                    EaseEvent event = EaseEvent.create(Constants.CONTACT_ADD, EaseEvent.TYPE.CONTACT);
                    event.message = username;
                    LiveEventBus.get(Constants.CONTACT_ADD).post(event);

                    showToast(context.getString(R.string.demo_contact_listener_onContactAdded, username));
                    EMLog.i(TAG, context.getString(R.string.demo_contact_listener_onContactAdded, username));
                }

                @Override
                public void onError(int error, String errorMsg) {
                    EMLog.i(TAG, context.getString(R.string.demo_contact_get_userInfo_failed) + username + "error:" + error + " errorMsg:" + errorMsg);
                }
            });
        }

        @Override
        public void onContactDeleted(String username) {
            EMLog.i("ChatContactListener", "onContactDeleted");
            int num = DatabaseManager.getInstance().getUserDao().deleteUser(username);
            EaseEvent event = EaseEvent.create(Constants.CONTACT_DELETE, EaseEvent.TYPE.CONTACT);
            event.message = username;
            LiveEventBus.get(Constants.CONTACT_DELETE).post(event);

            if (num == 0) {
                showToast(context.getString(R.string.demo_contact_listener_onContactDeleted, username));
                EMLog.i(TAG, context.getString(R.string.demo_contact_listener_onContactDeleted, username));
            } else {
                //showToast(context.getString(R.string.demo_contact_listener_onContactDeleted_by_other, username));
                EMLog.i(TAG, context.getString(R.string.demo_contact_listener_onContactDeleted_by_other, username));
            }
        }


        @Override
        public void onContactInvited(String username, String reason) {
            EMLog.i("ChatContactListener", "onContactInvited");
            List<EMMessage> allMessages = EaseSystemMsgManager.getInstance().getAllMessages();
            if (allMessages != null && !allMessages.isEmpty()) {
                for (EMMessage message : allMessages) {
                    Map<String, Object> ext = message.ext();
                    if (ext != null && !ext.containsKey(Constants.SYSTEM_MESSAGE_GROUP_ID)
                            && (ext.containsKey(Constants.SYSTEM_MESSAGE_FROM) && TextUtils.equals(username, (String) ext.get(Constants.SYSTEM_MESSAGE_FROM)))) {
                        EaseSystemMsgManager.getInstance().removeMessage(message);
                    }
                }
            }

            Map<String, Object> ext = EaseSystemMsgManager.getInstance().createMsgExt();
            ext.put(Constants.SYSTEM_MESSAGE_FROM, username);
            ext.put(Constants.SYSTEM_MESSAGE_REASON, reason);
            ext.put(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.BEINVITEED.name());
            EMMessage message = EaseSystemMsgManager.getInstance().createMessage(PushAndMessageHelper.getSystemMessage(ext), ext);

            notifyNewInviteMessage(message);
            EaseEvent event = EaseEvent.create(Constants.CONTACT_CHANGE, EaseEvent.TYPE.CONTACT);
            LiveEventBus.get(Constants.CONTACT_CHANGE).post(event);

            showToast(context.getString(InviteMessageStatus.BEINVITEED.getMsgContent(), username));
            EMLog.i(TAG, context.getString(InviteMessageStatus.BEINVITEED.getMsgContent(), username));
        }

        @Override
        public void onFriendRequestAccepted(String username) {
            EMLog.i("ChatContactListener", "onFriendRequestAccepted");
            List<EMMessage> allMessages = EaseSystemMsgManager.getInstance().getAllMessages();
            if (allMessages != null && !allMessages.isEmpty()) {
                for (EMMessage message : allMessages) {
                    Map<String, Object> ext = message.ext();
                    if (ext != null && (ext.containsKey(Constants.SYSTEM_MESSAGE_FROM)
                            && TextUtils.equals(username, (String) ext.get(Constants.SYSTEM_MESSAGE_FROM)))) {
                        updateMessage(message);
                        return;
                    }
                }
            }
            Map<String, Object> ext = EaseSystemMsgManager.getInstance().createMsgExt();
            ext.put(Constants.SYSTEM_MESSAGE_FROM, username);
            ext.put(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.BEAGREED.name());
            EMMessage message = EaseSystemMsgManager.getInstance().createMessage(PushAndMessageHelper.getSystemMessage(ext), ext);

            notifyNewInviteMessage(message);
            EaseEvent event = EaseEvent.create(Constants.CONTACT_CHANGE, EaseEvent.TYPE.CONTACT);
            LiveEventBus.get(Constants.CONTACT_CHANGE).post(event);

            showToast(context.getString(InviteMessageStatus.BEAGREED.getMsgContent()));
            EMLog.i(TAG, context.getString(InviteMessageStatus.BEAGREED.getMsgContent()));
        }

        @Override
        public void onFriendRequestDeclined(String username) {
            EMLog.i("ChatContactListener", "onFriendRequestDeclined");
            Map<String, Object> ext = EaseSystemMsgManager.getInstance().createMsgExt();
            ext.put(Constants.SYSTEM_MESSAGE_FROM, username);
            ext.put(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.BEREFUSED.name());
            EMMessage message = EaseSystemMsgManager.getInstance().createMessage(PushAndMessageHelper.getSystemMessage(ext), ext);

            notifyNewInviteMessage(message);

            EaseEvent event = EaseEvent.create(Constants.CONTACT_CHANGE, EaseEvent.TYPE.CONTACT);
            LiveEventBus.get(Constants.CONTACT_CHANGE).post(event);
            showToast(context.getString(InviteMessageStatus.BEREFUSED.getMsgContent(), username));
            EMLog.i(TAG, context.getString(InviteMessageStatus.BEREFUSED.getMsgContent(), username));
        }
    }


    private void updateMessage(EMMessage message) {
        message.setAttribute(Constants.SYSTEM_MESSAGE_STATUS, InviteMessageStatus.BEAGREED.name());
        EMTextMessageBody body = new EMTextMessageBody(PushAndMessageHelper.getSystemMessage(message.ext()));
        message.addBody(body);
        EaseSystemMsgManager.getInstance().updateMessage(message);
    }

    private class ChatMultiDeviceListener implements EMMultiDeviceListener {


        @Override
        public void onContactEvent(int event, String target, String ext) {
            EMLog.i(TAG, "onContactEvent event" + event);
            CircleUserDao userDao = DatabaseManager.getInstance().getUserDao();
            String message = null;
            switch (event) {
                case CONTACT_REMOVE: //好友已经在其他机子上被移除
                    EMLog.i("ChatMultiDeviceListener", "CONTACT_REMOVE");
                    message = Constants.CONTACT_REMOVE;
                    if (userDao != null) {
                        userDao.deleteUser(target);
                    }
                    removeTargetSystemMessage(target, Constants.SYSTEM_MESSAGE_FROM);
                    // TODO: 2020/1/16 0016 确认此处逻辑，是否是删除当前的target
                    EMClient.getInstance().chatManager().deleteConversation(target, false);

                    showToast("CONTACT_REMOVE");
                    break;
                case CONTACT_ACCEPT: //好友请求已经在其他机子上被同意
                    EMLog.i("ChatMultiDeviceListener", "CONTACT_ACCEPT");
                    message = Constants.CONTACT_ACCEPT;
                    CircleUser entity = new CircleUser();
                    entity.setUsername(target);
                    if (userDao != null) {
                        userDao.insert(entity);
                    }
                    updateContactNotificationStatus(target, "", InviteMessageStatus.MULTI_DEVICE_CONTACT_ACCEPT);

                    showToast("CONTACT_ACCEPT");
                    break;
                case CONTACT_DECLINE: //好友请求已经在其他机子上被拒绝
                    EMLog.i("ChatMultiDeviceListener", "CONTACT_DECLINE");
                    message = Constants.CONTACT_DECLINE;
                    updateContactNotificationStatus(target, "", InviteMessageStatus.MULTI_DEVICE_CONTACT_DECLINE);

                    showToast("CONTACT_DECLINE");
                    break;
                case CONTACT_BAN: //当前用户在其他设备加某人进入黑名单
                    EMLog.i("ChatMultiDeviceListener", "CONTACT_BAN");
                    message = Constants.CONTACT_BAN;
                    if (userDao != null) {
                        userDao.deleteUser(target);
                    }
                    removeTargetSystemMessage(target, Constants.SYSTEM_MESSAGE_FROM);
                    EMClient.getInstance().chatManager().deleteConversation(target, false);
                    updateContactNotificationStatus(target, "", InviteMessageStatus.MULTI_DEVICE_CONTACT_BAN);

                    showToast("CONTACT_BAN");
                    break;
                case CONTACT_ALLOW: // 好友在其他设备被移出黑名单
                    EMLog.i("ChatMultiDeviceListener", "CONTACT_ALLOW");
                    message = Constants.CONTACT_ALLOW;
                    updateContactNotificationStatus(target, "", InviteMessageStatus.MULTI_DEVICE_CONTACT_ALLOW);

                    showToast("CONTACT_ALLOW");
                    break;
            }
            if (!TextUtils.isEmpty(message)) {
                EaseEvent easeEvent = EaseEvent.create(message, EaseEvent.TYPE.CONTACT);
                LiveEventBus.get(message).post(easeEvent);
            }
        }

        @Override
        public void onGroupEvent(int event, String groupId, List<String> usernames) {
            EMLog.i(TAG, "onGroupEvent event" + event);
            String message = null;
            switch (event) {
                case GROUP_CREATE:
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_CREATE);

                    showToast("GROUP_CREATE");
                    break;
                case GROUP_DESTROY:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID);
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_DESTROY);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_DESTROY");
                    break;
                case GROUP_JOIN:
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_JOIN);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_JOIN");
                    break;
                case GROUP_LEAVE:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID);
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_LEAVE);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_LEAVE");
                    break;
                case GROUP_APPLY:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID);
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_APPLY);

                    showToast("GROUP_APPLY");
                    break;
                case GROUP_APPLY_ACCEPT:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID, usernames.get(0), Constants.SYSTEM_MESSAGE_FROM);
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_APPLY_ACCEPT);

                    showToast("GROUP_APPLY_ACCEPT");
                    break;
                case GROUP_APPLY_DECLINE:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID, usernames.get(0), Constants.SYSTEM_MESSAGE_FROM);
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_APPLY_DECLINE);

                    showToast("GROUP_APPLY_DECLINE");
                    break;
                case GROUP_INVITE:
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_INVITE);

                    showToast("GROUP_INVITE");
                    break;
                case GROUP_INVITE_ACCEPT:
                    String st3 = context.getString(R.string.Invite_you_to_join_a_group_chat);
                    EMMessage msg = EMMessage.createReceiveMessage(EMMessage.Type.TXT);
                    msg.setChatType(EMMessage.ChatType.GroupChat);
                    // TODO: person, reason from ext
                    String from = "";
                    if (usernames != null && usernames.size() > 0) {
                        msg.setFrom(usernames.get(0));
                    }
                    msg.setTo(groupId);
                    msg.setMsgId(UUID.randomUUID().toString());
                    msg.setAttribute(Constants.EM_NOTIFICATION_TYPE, true);
                    msg.addBody(new EMTextMessageBody(msg.getFrom() + " " + st3));
                    msg.setStatus(EMMessage.Status.SUCCESS);
                    // save invitation as messages
                    EMClient.getInstance().chatManager().saveMessage(msg);

                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID);
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_INVITE_ACCEPT);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_INVITE_ACCEPT");
                    break;
                case GROUP_INVITE_DECLINE:
                    removeTargetSystemMessage(groupId, Constants.SYSTEM_MESSAGE_GROUP_ID);
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_INVITE_DECLINE);

                    showToast("GROUP_INVITE_DECLINE");
                    break;
                case GROUP_KICK:
                    // TODO: person, reason from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_KICK);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_KICK");
                    break;
                case GROUP_BAN:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_BAN);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_BAN");
                    break;
                case GROUP_ALLOW:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_ALLOW);

                    showToast("GROUP_ALLOW");
                    break;
                case GROUP_BLOCK:
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_BLOCK);

                    showToast("GROUP_BLOCK");
                    break;
                case GROUP_UNBLOCK:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/"", /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_UNBLOCK);

                    showToast("GROUP_UNBLOCK");
                    break;
                case GROUP_ASSIGN_OWNER:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_ASSIGN_OWNER);

                    showToast("GROUP_ASSIGN_OWNER");
                    break;
                case GROUP_ADD_ADMIN:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_ADD_ADMIN);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_ADD_ADMIN");
                    break;
                case GROUP_REMOVE_ADMIN:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_REMOVE_ADMIN);
                    message = Constants.GROUP_CHANGE;

                    showToast("GROUP_REMOVE_ADMIN");
                    break;
                case GROUP_ADD_MUTE:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_ADD_MUTE);

                    showToast("GROUP_ADD_MUTE");
                    break;
                case GROUP_REMOVE_MUTE:
                    // TODO: person from ext
                    saveGroupNotification(groupId, /*groupName*/"",  /*person*/usernames.get(0), /*reason*/"", InviteMessageStatus.MULTI_DEVICE_GROUP_REMOVE_MUTE);

                    showToast("GROUP_REMOVE_MUTE");
                    break;
                default:
                    break;
            }
            if (!TextUtils.isEmpty(message)) {
                EaseEvent easeEvent = EaseEvent.create(message, EaseEvent.TYPE.GROUP);
                LiveEventBus.get(message).post(easeEvent);
            }
        }

        @Override
        public void onChatThreadEvent(int i, String s, List<String> list) {

        }

        @Override
        public void onCircleServerEvent(int event, String serverId, List<String> usernames) {
            switch (event) {
                case SERVER_CREATE:
                    //当前用户在其他设备上创建社区。
                    LiveEventBus.get(Constants.CREATE_CHANNEL_MULTIPLY_NOTIFY).post(null);
                    break;
                case SERVER_DELETE:
                    // 当前用户在其他设备上删除社区。
                    DatabaseManager.getInstance().getServerDao().deleteByServerId(serverId);
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(null);
                    break;
                case SERVER_UPDATE:
                    // 当前用户在其他设备上更新社区。
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(null);
                    break;
                case SERVER_JOIN:
                    // 当前用户在其他设备上加入社区。
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(null);
                    break;
                case SERVER_LEAVE:
                    // 当前用户在其他设备上退出社区。
                    DatabaseManager.getInstance().getServerDao().deleteByServerId(serverId);
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(null);
                    break;
                case SERVER_INVITE_ACCEPT:
                    // 当前用户在其他设备上接受加入社区的邀请。
                    LiveEventBus.get(Constants.SERVER_CHANGED).post(null);
                    break;
                case SERVER_INVITE_DECLINE:
                    // 当前用户在其他设备上拒绝加入社区的邀请。
                    break;

                case CIRCLE_SERVER_SET_ROLE:
                    // 当前用户在其他设备上为用户设置社区角色。
                    break;

                case CIRCLE_SERVER_REMOVE_USER:
                    // 当前设备在其他设备上从社区中移除成员。
                    break;

                case CIRCLE_SERVER_INVITE_USER:
                    // 当前设备在其他设备上邀请其他用户加入社区。
                    break;
            }

        }

        @Override
        public void onCircleChannelEvent(int event, String channelId, List<String> usernames) {
            switch (event) {

                case CHANNEL_CREATE:
                    // 当前用户在其他设备上创建频道。
                    LiveEventBus.get(Constants.CREATE_CHANNEL_MULTIPLY_NOTIFY).post(null);
                    break;
                case CHANNEL_DELETE:
                    // 当前用户在其他设备上删除频道。

                case CHANNEL_UPDATE:
                    // 当前用户在其他设备上更新频道。

                case CHANNEL_JOIN:
                    // 当前用户在其他设备上加入频道。

                case CHANNEL_LEAVE:
                    // 当前用户在其他设备上退出频道。

                case CHANNEL_INVITATION_ACCEPT:
                    // 当前用户在其他设备上接受加入频道的邀请。
                    CircleChannel circleChannel = getChannelDao().getChannelByChannelID(channelId);
                    if (circleChannel != null) {
                        CircleServer circleServer = getServerDao().getServerById(circleChannel.serverId);
                        if (circleServer != null) {
                            LiveEventBus.get(Constants.SERVER_UPDATED).post(circleServer);
                        }
                    }
                    break;

                case CHANNEL_INVITATION_DECLINE:
                    // 当前用户在其他设备上拒绝加入频道的邀请。
                    break;

                case CIRCLE_CHANNEL_REMOVE_USER:
                    // 当前用户在其他设备上从频道中移除成员。
                    break;

                case CIRCLE_CHANNEL_INVITE_USER:
                    // 当前用户在其他设备上邀请用户加入频道。
                    break;

                case CIRCLE_CHANNEL_MEMBER_ADD_MUTE:
                    // 当前用户在其他设备上禁言频道成员。
                    break;
                case CIRCLE_CHANNEL_MEMBER_REMOVE_MUTE:
                    // 当前用户在其他设备上解除对频道成员的禁言。
                    break;
            }
        }
    }

    /**
     * 移除目标所有的消息记录，如果目标被删除
     *
     * @param target
     */
    private void removeTargetSystemMessage(String target, String params) {
        EMConversation conversation = EaseSystemMsgManager.getInstance().getConversation();
        List<EMMessage> messages = conversation.getAllMessages();
        if (messages != null && !messages.isEmpty()) {
            for (EMMessage message : messages) {
                String from = null;
                try {
                    from = message.getStringAttribute(params);
                } catch (HyphenateException e) {
                    e.printStackTrace();
                }
                if (TextUtils.equals(from, target)) {
                    conversation.removeMessage(message.getMsgId());
                }
            }
        }
    }

    /**
     * 移除目标所有的消息记录，如果目标被删除
     *
     * @param target1
     */
    private void removeTargetSystemMessage(String target1, String params1, String target2, String params2) {
        EMConversation conversation = EaseSystemMsgManager.getInstance().getConversation();
        List<EMMessage> messages = conversation.getAllMessages();
        if (messages != null && !messages.isEmpty()) {
            for (EMMessage message : messages) {
                String targetParams1 = null;
                String targetParams2 = null;
                try {
                    targetParams1 = message.getStringAttribute(params1);
                    targetParams2 = message.getStringAttribute(params2);
                } catch (HyphenateException e) {
                    e.printStackTrace();
                }
                if (TextUtils.equals(targetParams1, target1) && TextUtils.equals(targetParams2, target2)) {
                    conversation.removeMessage(message.getMsgId());
                }
            }
        }
    }


    private void notifyNewInviteMessage(EMMessage msg) {
        // notify there is new message
        getNotifier().vibrateAndPlayTone(null);
    }

    private void updateContactNotificationStatus(String from, String reason, InviteMessageStatus status) {
        EMMessage msg = null;
        EMConversation conversation = EaseSystemMsgManager.getInstance().getConversation();
        List<EMMessage> allMessages = conversation.getAllMessages();
        if (allMessages != null && !allMessages.isEmpty()) {
            for (EMMessage message : allMessages) {
                Map<String, Object> ext = message.ext();
                if (ext != null && (ext.containsKey(Constants.SYSTEM_MESSAGE_FROM)
                        && TextUtils.equals(from, (String) ext.get(Constants.SYSTEM_MESSAGE_FROM)))) {
                    msg = message;
                }
            }
        }

        if (msg != null) {
            msg.setAttribute(Constants.SYSTEM_MESSAGE_STATUS, status.name());
            EaseSystemMsgManager.getInstance().updateMessage(msg);
        } else {
            // save invitation as message
            Map<String, Object> ext = EaseSystemMsgManager.getInstance().createMsgExt();
            ext.put(Constants.SYSTEM_MESSAGE_FROM, from);
            ext.put(Constants.SYSTEM_MESSAGE_REASON, reason);
            ext.put(Constants.SYSTEM_MESSAGE_STATUS, status.name());
            msg = EaseSystemMsgManager.getInstance().createMessage(PushAndMessageHelper.getSystemMessage(ext), ext);
            notifyNewInviteMessage(msg);
        }
    }

    private void saveGroupNotification(String groupId, String groupName, String inviter, String reason, InviteMessageStatus status) {
        Map<String, Object> ext = EaseSystemMsgManager.getInstance().createMsgExt();
        ext.put(Constants.SYSTEM_MESSAGE_FROM, groupId);
        ext.put(Constants.SYSTEM_MESSAGE_GROUP_ID, groupId);
        ext.put(Constants.SYSTEM_MESSAGE_REASON, reason);
        ext.put(Constants.SYSTEM_MESSAGE_NAME, groupName);
        ext.put(Constants.SYSTEM_MESSAGE_INVITER, inviter);
        ext.put(Constants.SYSTEM_MESSAGE_STATUS, status.name());
        EMMessage message = EaseSystemMsgManager.getInstance().createMessage(PushAndMessageHelper.getSystemMessage(ext), ext);

        notifyNewInviteMessage(message);
    }

    protected String getCurrentUser() {
        return EMClient.getInstance().getCurrentUser();
    }

    protected CircleUserDao getUserDao() {
        return DatabaseManager.getInstance().getUserDao();
    }

    protected CircleServerDao getServerDao() {
        return DatabaseManager.getInstance().getServerDao();
    }

    protected CircleChannelDao getChannelDao() {
        return DatabaseManager.getInstance().getChannelDao();
    }
}
