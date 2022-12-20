package io.agora.contacts.adapter;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMCircleUserRole;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.service.bean.PresenceData;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.global.Constants;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.widget.EasePresenceView;


public class ContactListAdapter extends EaseBaseRecyclerViewAdapter<CircleUser> {
    private boolean showInitials;
    private boolean isCheckModel;
    private DisplayMode displayMode = DisplayMode.SHOW_CONVERSATION;//不同模式展示不同的ui
    private List<String> adminList;
    private List<String> muteList;
    private List<String> checkedList;
    private String owner;
    private OnSelectListener listener;
    private List<String> memberList;

    @Override
    public ViewHolder getViewHolder(ViewGroup parent, int viewType) {
        return new ContactViewHolder(LayoutInflater.from(mContext).inflate(R.layout.ease_widget_contact_item, parent, false));
    }

    public void setShowInitials(boolean showInitials) {
        this.showInitials = showInitials;
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setCheckModel(boolean isCheckModel) {
        this.isCheckModel = isCheckModel;
        if (isCheckModel) {
            checkedList = new ArrayList<>();
        }
        notifyDataSetChanged();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setSelectedMembers(List<String> existMembers) {
        checkedList = existMembers;
        notifyDataSetChanged();
    }

    public void setOwner(String owner) {
        this.owner = owner;
        notifyDataSetChanged();
    }

    public void setDisplayMode(DisplayMode displayMode) {
        this.displayMode = displayMode;
        notifyDataSetChanged();
    }


    @SuppressLint("NotifyDataSetChanged")
    public void setAdminList(List<String> adminList) {
        this.adminList = adminList;
        notifyDataSetChanged();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setMuteList(List<String> muteList) {
        this.muteList = muteList;
        notifyDataSetChanged();
    }

    public List<String> getMuteList() {
        return muteList;
    }

    public List<String> getCheckedList() {
        if (this.memberList != null) {
            if (checkedList == null) {
                return memberList;
            } else {
                checkedList.addAll(memberList);
            }
        }
        return checkedList;
    }

    public void setGroupMemberList(List<String> memberList) {
        this.memberList = memberList;
        notifyDataSetChanged();
    }

    private class ContactViewHolder extends ViewHolder<CircleUser> {
        private CheckBox cb_select;
        private EasePresenceView presenceView;
        private Button btnInvite;
        private ImageView ivChat;
        private TextView tvRole;

        public ContactViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void initView(View itemView) {
            cb_select = findViewById(R.id.cb_select);
            presenceView = findViewById(R.id.presenceView);
            ivChat = findViewById(R.id.iv_chat);
            btnInvite = findViewById(R.id.btn_invite);
            tvRole = findViewById(R.id.tv_role);

        }

        @Override
        public void setData(CircleUser circleUser, int position) {
            String username = circleUser.getUsername();
            EMPresence presence = AppUserInfoManager.getInstance().getPresences().get(username);
            if (presence == null) {
                if (mUserPresenceListener != null) {
                    mUserPresenceListener.subscribe(username, Constants.PRESENCE_SUBSCRIBE_EXPIRY);
                }
                presenceView.setCustomData(circleUser.getAvatar(), circleUser.getVisiableName(), PresenceData.OFFLINE);
            } else {
                CircleUser user = AppUserInfoManager.getInstance().getUserInfobyId(username);
                if (user != null) {
                    presenceView.setPresenceData(user.getAvatar(), presence);
                }
            }
            presenceView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mItemSubViewListener != null) {
                        mItemSubViewListener.onItemSubViewClick(presenceView, getBindingAdapterPosition());
                    }
                }
            });
            if (displayMode == DisplayMode.SHOW_NONE) {
                ivChat.setVisibility(View.GONE);
                btnInvite.setVisibility(View.GONE);
                if (circleUser.roleID == EMCircleUserRole.OWNER.getRoleId()) {
                    tvRole.setVisibility(View.VISIBLE);
                    tvRole.setEnabled(false);//仅仅为方便设置背景色
                } else if (circleUser.roleID == EMCircleUserRole.MODERATOR.getRoleId()) {
                    tvRole.setVisibility(View.VISIBLE);
                    tvRole.setText(mContext.getText(R.string.circle_role_moderator));
                    tvRole.setEnabled(true);
                } else if (circleUser.roleID == EMCircleUserRole.USER.getRoleId()) {
                    tvRole.setVisibility(View.GONE);
                }

            } else if (displayMode == DisplayMode.SHOW_INVITE) {
                btnInvite.setVisibility(View.VISIBLE);
                if (circleUser.inviteState == 1) {
                    btnInvite.setEnabled(false);
                    btnInvite.setText(mContext.getString(R.string.circle_inviting));
                } else {
                    btnInvite.setEnabled(true);
                    btnInvite.setText(mContext.getString(R.string.circle_invite));
                }

                ivChat.setVisibility(View.GONE);
                tvRole.setVisibility(View.GONE);
                btnInvite.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mItemSubViewListener != null) {
                            mItemSubViewListener.onItemSubViewClick(btnInvite, getBindingAdapterPosition());
                        }
                    }
                });
            } else if (displayMode == DisplayMode.SHOW_CONVERSATION) {
                btnInvite.setVisibility(View.GONE);
                tvRole.setVisibility(View.GONE);
                ivChat.setVisibility(View.VISIBLE);
            }
            if (isCheckModel) {
                cb_select.setVisibility(View.VISIBLE);
                if (checkedList != null && checkedList.contains(username)) {
                    cb_select.setSelected(true);
                } else {
                    cb_select.setSelected(false);
                }
                if (isContains(memberList, username)) {
                    cb_select.setSelected(true);
                    cb_select.setEnabled(false);
                    this.itemView.setEnabled(false);
                } else {
                    cb_select.setEnabled(true);
                    this.itemView.setEnabled(true);
                }
                this.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        boolean isSelected = cb_select.isSelected();
                        cb_select.setSelected(!isSelected);
                        if (checkedList == null) {
                            checkedList = new ArrayList<>();
                        }
                        if (cb_select.isSelected() && !isContains(checkedList, username)) {
                            checkedList.add(username);
                        }
                        if (!cb_select.isSelected()) {
                            checkedList.remove(username);
                        }
                        if (listener != null) {
                            listener.onSelected(v, checkedList);
                        }
                    }
                });
            }
        }
    }

    private void setLabel(TextView tv, String label) {
        if (!TextUtils.isEmpty(label)) {
            tv.setVisibility(View.VISIBLE);
            tv.setText(label);
        } else {
            tv.setVisibility(View.GONE);
        }
    }

    private boolean isContains(List<String> data, String username) {
        return data != null && data.contains(username);
    }

    public void setOnSelectListener(OnSelectListener listener) {
        this.listener = listener;
    }

    public interface OnSelectListener {
        void onSelected(View v, List<String> selectedMembers);
    }

    public enum DisplayMode {
        SHOW_INVITE, SHOW_CONVERSATION, SHOW_NONE
    }
}
