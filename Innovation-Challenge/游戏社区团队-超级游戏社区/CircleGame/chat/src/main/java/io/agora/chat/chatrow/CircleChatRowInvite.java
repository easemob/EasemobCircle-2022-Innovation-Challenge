package io.agora.chat.chatrow;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.bumptech.glide.Glide;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTranslationResult;
import com.hyphenate.easeui.manager.EaseDingMessageHelper;
import com.hyphenate.easeui.widget.chatrow.EaseChatRow;

import java.util.Map;

import io.agora.chat.R;
import io.agora.service.global.Constants;

public class CircleChatRowInvite extends EaseChatRow {
    private TextView contentView;
    private TextView translationContentView;
    private ImageView translationStatusView;
    private View translationContainer;
    private ConstraintLayout cslInvite;
    private ImageView ivServer;
    private TextView tvServerName;
    private TextView tvChannelName;

    public CircleChatRowInvite(Context context, boolean isSender) {
        super(context, isSender);
    }

    public CircleChatRowInvite(Context context, EMMessage message, int position, Object adapter) {
        super(context, message, position, adapter);
    }

    @Override
    protected void onInflateView() {
        inflater.inflate(!showSenderType ? R.layout.circle_row_received_custom_invite
                : R.layout.circle_row_sent_custom_invite, this);
    }

    @Override
    protected void onFindViewById() {
        contentView = (TextView) findViewById(R.id.tv_chatcontent);
        cslInvite = findViewById(R.id.csl_invite);
        ivServer = findViewById(R.id.iv_server);
        tvServerName = findViewById(R.id.tv_server_name);
        tvChannelName = findViewById(R.id.tv_channel_name);

        translationContentView = (TextView) findViewById(R.id.tv_subContent);
        translationStatusView = (ImageView) findViewById(R.id.translation_status);
        translationContainer = (View) findViewById(R.id.subBubble);
    }

    @Override
    public void onSetUpView() {
        contentView.setVisibility(GONE);
        cslInvite.setVisibility(GONE);
        EMCustomMessageBody customBody = (EMCustomMessageBody) message.getBody();
        contentView.setTextColor(Color.WHITE);
        if (customBody != null) {
            String content = "";
            Map<String, String> params = customBody.getParams();
            String event = customBody.event();
            if (TextUtils.equals(event, Constants.ACCEPT_INVITE_SERVER)) {
                //同意社区邀请时，自己给默认频道发送此条消息
                contentView.setTextColor(ContextCompat.getColor(context, com.hyphenate.easeui.R.color.circle_gray_929497));
                contentView.setVisibility(VISIBLE);
                String serverName = params.get(Constants.CUSTOM_MESSAGE_SERVER_NAME);
                content = "我已加入社区【" + serverName + "】";
                contentView.setText(content, TextView.BufferType.SPANNABLE);
            } else if (TextUtils.equals(event, Constants.ACCEPT_INVITE_CHANNEL)) {
                //同意频道邀请时，自己给频道发送此条消息
                contentView.setTextColor(ContextCompat.getColor(context, com.hyphenate.easeui.R.color.circle_gray_929497));
                contentView.setVisibility(VISIBLE);
                String serverName = params.get(Constants.CUSTOM_MESSAGE_SERVER_NAME);
                String channelName = params.get(Constants.CUSTOM_MESSAGE_CHANNEL_NAME);
                content = "我已加入频道【" + serverName + "】- #【" + channelName + "】";
                contentView.setText(content, TextView.BufferType.SPANNABLE);
            } else if (TextUtils.equals(event, Constants.INVITE_SERVER)) {
                //邀请好友加入server时，自己给好友单聊发送此条消息
                cslInvite.setVisibility(VISIBLE);
                tvChannelName.setVisibility(GONE);

                String serverId = params.get(Constants.CUSTOM_MESSAGE_SERVER_ID);
                String serverName = params.get(Constants.CUSTOM_MESSAGE_SERVER_NAME);
                String serverIcon = params.get(Constants.CUSTOM_MESSAGE_SERVER_ICON);
                Glide.with(context).load(serverIcon).placeholder(io.agora.service.R.drawable.cover03).into(ivServer);
                tvServerName.setText(serverName);

            } else if (TextUtils.equals(event, Constants.INVITE_CHANNEL)) {
                //邀请好友加入channel时，自己给好友单聊发送此条消息
                cslInvite.setVisibility(VISIBLE);
                tvChannelName.setVisibility(VISIBLE);
                String serverId = params.get(Constants.CUSTOM_MESSAGE_SERVER_ID);
                String serverName = params.get(Constants.CUSTOM_MESSAGE_SERVER_NAME);
                String serverIcon = params.get(Constants.CUSTOM_MESSAGE_SERVER_ICON);
                String channelName = params.get(Constants.CUSTOM_MESSAGE_CHANNEL_NAME);
                Glide.with(context).load(serverIcon).placeholder(io.agora.service.R.drawable.cover03).into(ivServer);
                tvServerName.setText(serverName);
                tvChannelName.setText(channelName);
            }


            EMTranslationResult result = EMClient.getInstance().translationManager().getTranslationResult(message.getMsgId());
            if (result != null) {
                if (result.showTranslation()) {
                    translationContainer.setVisibility(View.VISIBLE);
                    translationContentView.setText(result.translatedText());
                    translationContainer.setOnLongClickListener(new OnLongClickListener() {
                        @Override
                        public boolean onLongClick(View v) {
                            contentView.setTag(R.id.action_chat_long_click, true);
                            if (itemClickListener != null) {
                                return itemClickListener.onBubbleLongClick(v, message);
                            }
                            return false;
                        }
                    });
                    translationStatusView.setImageResource(com.hyphenate.easeui.R.drawable.translation_success);
                } else {
                    translationContainer.setVisibility(View.GONE);
                }
            } else {
                translationContainer.setVisibility(View.GONE);
            }
        }
    }


    @Override
    protected void onMessageCreate() {
        setStatus(View.VISIBLE, View.GONE);
    }

    @Override
    protected void onMessageSuccess() {
        setStatus(View.GONE, View.GONE);

        // Show "1 Read" if this msg is a ding-type msg.
        if (isSender() && EaseDingMessageHelper.get().isDingMessage(message) && ackedView != null) {
            ackedView.setVisibility(VISIBLE);
            int count = message.groupAckCount();
            ackedView.setText(String.format(getContext().getString(com.hyphenate.easeui.R.string.group_ack_read_count), count));
        }

        // Set ack-user list change listener.
        // Only use the group ack count from message. - 2022.04.27
        //EaseDingMessageHelper.get().setUserUpdateListener(message, userUpdateListener);
    }

    @Override
    protected void onMessageError() {
        super.onMessageError();
        setStatus(View.GONE, View.VISIBLE);
    }

    @Override
    protected void onMessageInProgress() {
        setStatus(View.VISIBLE, View.GONE);
    }

    /**
     * set progress and status view visible or gone
     *
     * @param progressVisible
     * @param statusVisible
     */
    private void setStatus(int progressVisible, int statusVisible) {
        if (progressBar != null) {
            progressBar.setVisibility(progressVisible);
        }
        if (statusView != null) {
            statusView.setVisibility(statusVisible);
        }
    }

    private EaseDingMessageHelper.IAckUserUpdateListener userUpdateListener = list -> onAckUserUpdate(list.size());

    public void onAckUserUpdate(final int count) {
        if (ackedView == null) {
            return;
        }
        ackedView.post(() -> {
            if (isSender()) {
                ackedView.setVisibility(VISIBLE);
                ackedView.setText(String.format(getContext().getString(com.hyphenate.easeui.R.string.group_ack_read_count), count));
            }
        });
    }
}
