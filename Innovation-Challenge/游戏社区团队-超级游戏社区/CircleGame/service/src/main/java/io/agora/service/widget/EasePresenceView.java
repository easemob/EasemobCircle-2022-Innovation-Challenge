package io.agora.service.widget;


import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.ColorInt;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.blankj.utilcode.util.ConvertUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.easeui.widget.EaseImageView;

import io.agora.service.R;
import io.agora.service.bean.PresenceData;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.utils.EasePresenceUtil;


public class EasePresenceView extends ConstraintLayout {
    private EaseImageView ivAvatar;
    private EaseImageView ivPresence;
    private TextView tvName;
    private TextView tvPresence;
    private float mAvaterWidth;
    private float mStatusImageWidth;
    private float mNameTextSize;
    private float mStatusTextSize;
    private int mStatusVisiable;

    public EasePresenceView(Context context) {
        this(context, null);
    }

    public EasePresenceView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EasePresenceView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initAttrs(attrs);
        init();
    }

    private void initAttrs(AttributeSet attrs) {
        if (attrs != null) {
            TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.EasePresenceView);
            mAvaterWidth = a.getDimensionPixelSize(R.styleable.EasePresenceView_avater_width, 0);
            mStatusImageWidth = a.getDimensionPixelSize(R.styleable.EasePresenceView_status_image_width, 0);
            mNameTextSize = a.getDimensionPixelSize(R.styleable.EasePresenceView_name_text_size, ConvertUtils.sp2px(16));
            mStatusTextSize = a.getDimensionPixelSize(R.styleable.EasePresenceView_status_text_size, 0);
            mStatusVisiable = a.getInteger(R.styleable.EasePresenceView_status_text_visiable, 0);
            a.recycle();
        }
    }

    private void init() {

        inflate(getContext(), R.layout.presence_view, this);
        ivAvatar = findViewById(R.id.iv_user_avatar);
        ivPresence = findViewById(R.id.iv_presence);
        tvName = findViewById(R.id.tv_name);
        tvPresence = findViewById(R.id.tv_presence);

        ViewGroup.LayoutParams avatarLayoutParams = ivAvatar.getLayoutParams();
        if (mAvaterWidth != 0) {
            avatarLayoutParams.width = (int) mAvaterWidth;
            avatarLayoutParams.height = (int) mAvaterWidth;
            ivAvatar.setLayoutParams(avatarLayoutParams);
        }

        ViewGroup.LayoutParams presenceLayoutParams = ivPresence.getLayoutParams();
        if (mStatusImageWidth != 0) {
            presenceLayoutParams.height = (int) mStatusImageWidth;
            presenceLayoutParams.width = (int) mStatusImageWidth;
            ivPresence.setLayoutParams(presenceLayoutParams);
        }
        tvName.setTextSize(TypedValue.COMPLEX_UNIT_PX, mNameTextSize);
        tvPresence.setTextSize(TypedValue.COMPLEX_UNIT_PX, mStatusTextSize);

        if (mStatusVisiable == 0) {
            tvPresence.setVisibility(GONE);
        } else {
            tvPresence.setVisibility(VISIBLE);
        }
    }

    public void setPresenceData(String avatar, EMPresence presence) {
        try {
            int resourceId = Integer.parseInt(avatar);
            Glide.with(this)
                    .load(resourceId)
                    .placeholder(R.drawable.circle_default_avatar)
                    .error(R.drawable.circle_default_avatar)
                    .into(ivAvatar);
        } catch (NumberFormatException e) {
            Glide.with(this)
                    .load(avatar)
                    .placeholder(R.drawable.circle_default_avatar)
                    .error(R.drawable.circle_default_avatar)
                    .into(ivAvatar);
        }
        if (presence != null) {
            String publisher = presence.getPublisher();
            CircleUser circleUser = AppUserInfoManager.getInstance().getUserInfobyId(publisher);
            tvPresence.setText(EasePresenceUtil.getPresenceString(getContext(), presence));
            ivPresence.setImageResource(EasePresenceUtil.getPresenceIcon(getContext(), presence));
            tvName.setText(circleUser == null ? publisher : circleUser.getVisiableName());
        } else {
            tvPresence.setText("");
            ivPresence.setImageResource(EasePresenceUtil.getPresenceIcon(getContext(), presence));
        }
    }

    public void setCustomData(String avatar, String name, PresenceData presenceData) {
        Glide.with(this)
                .load(avatar)
                .placeholder(R.drawable.circle_default_avatar)
                .error(R.drawable.circle_default_avatar)
                .into(ivAvatar);
        tvPresence.setText(getContext().getString(presenceData.getPresence()));
        ivPresence.setImageResource(EasePresenceUtil.getPresenceIcon(getContext(), null));
        tvName.setText(name);
    }

    public void setPresenceTextViewArrowVisible(boolean visible) {
        if (visible) {
            Drawable arrow = getResources().getDrawable(R.drawable.ease_presence_arrow_left);
            tvPresence.setCompoundDrawablesWithIntrinsicBounds(null, null, arrow, null);
        } else {
            tvPresence.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
        }
    }

    public void setPresenceTextViewColor(@ColorInt int color) {
        tvPresence.setTextColor(color);
    }

    public void setNameTextViewVisibility(int visible) {
        tvName.setVisibility(visible);
    }

}
