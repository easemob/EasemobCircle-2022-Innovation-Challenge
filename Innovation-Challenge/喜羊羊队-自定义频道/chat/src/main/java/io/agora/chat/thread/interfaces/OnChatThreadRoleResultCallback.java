package io.agora.chat.thread.interfaces;

import io.agora.chat.thread.EaseChatThreadRole;

/**
 * Use to get thread role in {@link EaseChatThreadFragment}
 */
public interface OnChatThreadRoleResultCallback {
    /**
     * The role of thread
     * @param role
     */
    void onThreadRole(EaseChatThreadRole role);
}
