package io.agora.circle.ui;

import android.Manifest;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;

import androidx.fragment.app.Fragment;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.interfaces.OnChatExtendMenuItemClickListener;
import com.hyphenate.easeui.modules.chat.interfaces.OnAddMsgAttrsBeforeSendEvent;
import com.hyphenate.easeui.modules.chat.interfaces.OnChatRecordTouchListener;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.hyphenate.util.EMLog;

import io.agora.chat.R;
import io.agora.chat.thread.EaseChatThreadCreateFragment;
import io.agora.chat.thread.interfaces.EaseChatThreadParentMsgViewProvider;
import io.agora.circle.databinding.ActivityThreadCreateBinding;
import io.agora.service.base.BaseInitActivity;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.global.Constants;
import io.agora.service.permission.PermissionsManager;

@Route(path = "/app/ChatThreadCreateActivity")
public class ChatThreadCreateActivity extends BaseInitActivity<ActivityThreadCreateBinding>  {
    public String parentId;
    public String messageId;
    private CircleChannel channel;

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        parentId = getIntent().getStringExtra(Constants.CHANNEL_ID);
        messageId = getIntent().getStringExtra(Constants.MESSAGE_ID);
        channel = (CircleChannel) getIntent().getSerializableExtra(Constants.CHANNEL);

        Fragment fragment = getSupportFragmentManager().findFragmentByTag("create_chat_thread");
        if (fragment == null) {
            EaseChatThreadCreateFragment.Builder builder = new EaseChatThreadCreateFragment.Builder(parentId, messageId, channel)
                    .useHeader(true)
                    .setHeaderBackPressListener(new EaseTitleBar.OnBackPressListener() {
                        @Override
                        public void onBackPress(View view) {
                            onBackPressed();
                        }
                    })
                    .setOnChatExtendMenuItemClickListener(new OnChatExtendMenuItemClickListener() {
                        @Override
                        public boolean onChatExtendMenuItemClick(View view, int itemId) {
                            EMLog.e("TAG", "onChatExtendMenuItemClick");
                            if (itemId == R.id.extend_item_take_picture) {
                                // check if has permissions
                                if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.CAMERA)) {
                                    PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this, new String[]{Manifest.permission.CAMERA}, null);
                                    return true;
                                }
                                if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                    PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this
                                            , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                    return true;
                                }
                                return false;
                            } else if (itemId == R.id.extend_item_picture || itemId == R.id.extend_item_file) {
                                if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                    PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this
                                            , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                    return true;
                                }
                                return false;
                            } else if (itemId == R.id.extend_item_video) {
                                if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.CAMERA)) {
                                    PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this
                                            , new String[]{Manifest.permission.CAMERA}, null);
                                    return true;
                                }
                                if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                    PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this
                                            , new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, null);
                                    return true;
                                }
                                return false;
                            }
                            return false;
                        }
                    })
                    .setOnChatRecordTouchListener(new OnChatRecordTouchListener() {
                        @Override
                        public boolean onRecordTouch(View v, MotionEvent event) {
                            // Check if has record audio permission
                            if (!PermissionsManager.getInstance().hasPermission(mContext, Manifest.permission.RECORD_AUDIO)) {
                                PermissionsManager.getInstance().requestPermissionsIfNecessaryForResult(ChatThreadCreateActivity.this
                                        , new String[]{Manifest.permission.RECORD_AUDIO}, null);
                                return true;
                            }
                            return false;
                        }
                    })
                    .setThreadParentMsgViewProvider(new EaseChatThreadParentMsgViewProvider() {
                        @Override
                        public View parentMsgView(EMMessage message) {
                            // Add your parent view
                            return null;
                        }
                    })
                    .setOnAddMsgAttrsBeforeSendEvent(new OnAddMsgAttrsBeforeSendEvent() {
                        @Override
                        public void addMsgAttrsBeforeSend(EMMessage message) {

                        }
                    })
                    ;
            fragment = builder.build();
        }
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_fragment, fragment, "create_chat_thread").commit();
    }

    @Override
    protected int getResLayoutId() {
        return io.agora.circle.R.layout.activity_thread_create;
    }


}
