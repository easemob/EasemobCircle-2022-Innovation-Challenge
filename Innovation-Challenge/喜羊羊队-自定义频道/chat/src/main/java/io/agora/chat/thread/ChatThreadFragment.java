package io.agora.chat.thread;


import android.text.TextUtils;
import android.view.View;

import com.blankj.utilcode.util.ToastUtils;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.constants.EaseConstant;
import com.hyphenate.easeui.modules.menu.EasePopupWindowHelper;
import com.jeremyliao.liveeventbus.LiveEventBus;

import io.agora.chat.R;
import io.agora.service.bean.ThreadData;
import io.agora.service.global.Constants;

public class ChatThreadFragment extends EaseChatThreadFragment {
    @Override
    public void onPreMenu(EasePopupWindowHelper helper, EMMessage message, View view) {
        super.onPreMenu(helper, message, view);
        boolean isRecall = message.getBooleanAttribute(EaseConstant.MESSAGE_TYPE_RECALL, false);
        if (isRecall) {
            helper.showHeaderView(false);
            helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_delete, true);
            helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_unsent, false);
            helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_recall, false);
            helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_copy, false);
        }
        helper.findItemVisible(com.hyphenate.easeui.R.id.action_chat_thread, false);
    }

    @Override
    public void recallSuccess(EMMessage originalMessage, EMMessage notification) {
        super.recallSuccess(originalMessage, notification);
        ToastUtils.showShort(R.string.thread_unsent_message_success);
    }

    @Override
    public void initListener() {
        super.initListener();
        //刷新用户图像等个人信息
        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(), obj -> {
            if (obj != null) {
                chatLayout.getChatMessageListLayout().refreshMessages();
            }
        });
        LiveEventBus.get(Constants.THREAD_UPDATE, ThreadData.class).observe(this, threadData -> {
            if (threadData != null && TextUtils.equals(threadData.getThreadId(), conversationId)) {
                mPresenter.getThreadInfo(threadData.getThreadId());
            }
        });
    }

    @Override
    public void recallFail(int code, String errorMsg) {
        super.recallFail(code, errorMsg);
        ToastUtils.showShort(errorMsg);
    }
}
