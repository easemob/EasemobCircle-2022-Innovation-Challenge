package com.hyphenate.easeui.modules.menu;


import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.hyphenate.chat.EMMessageReaction;
import com.hyphenate.easeui.EaseIM;
import com.hyphenate.easeui.R;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;
import com.hyphenate.easeui.domain.EaseEmojicon;
import com.hyphenate.easeui.interfaces.OnItemClickListener;
import com.hyphenate.easeui.model.EaseMessageMenuData;
import com.hyphenate.easeui.model.styles.EaseReactionOptions;
import com.hyphenate.easeui.utils.EaseCommonUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class EaseReactionMenuHelper {
    private static final int REACTION_SPAN_COUNT = 6;
    private static final String TAG = EaseReactionMenuHelper.class.getSimpleName();
    private final Map<String, Boolean> mEmojiContainCurrentUserMap = new HashMap<>();
    private final List<ReactionItemBean> mReactionItems = new ArrayList<>();

    private Context mContext;
    private View mLayout;
    private RecyclerView mReactionListView;
    private ReactionAdapter mReactionAdapter;
    private EasePopupWindowHelper popupWindowHelper;
    private EasePopupWindow.OnPopupWindowItemClickListener mItemClickListener;
    private boolean mIsShowReactionView = true;

    public void init(Context context, EasePopupWindowHelper popupWindowHelper) {
        EaseReactionOptions reactionOptions = EaseIM.getInstance().getReactionOptions();
        if(reactionOptions != null && !reactionOptions.isOpen()) {
            return;
        }
        this.mContext = context;
        this.popupWindowHelper = popupWindowHelper;
        mLayout = LayoutInflater.from(context).inflate(R.layout.ease_layout_menu_reactions, null);
        mReactionListView = mLayout.findViewById(R.id.rv_reaction_list);
        mReactionListView.setLayoutManager(new GridLayoutManager(context, REACTION_SPAN_COUNT + 1));

        mReactionAdapter = new ReactionAdapter();
        mReactionListView.setAdapter(mReactionAdapter);
        mReactionAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                if (mItemClickListener != null) {
                    ReactionItemBean item = mReactionAdapter.getItem(position);
                    if (EaseMessageMenuData.EMOTICON_MORE_IDENTITY_CODE.equals(item.getIdentityCode())) {
                        showAllReactionEmoticon();
                    } else {
                        boolean isAdd;
                        if (null == mEmojiContainCurrentUserMap.get(item.getIdentityCode())) {
                            isAdd = true;
                        } else {
                            isAdd = !mEmojiContainCurrentUserMap.get(item.getIdentityCode());
                        }
                        mItemClickListener.onReactionItemClick(item, isAdd);
                        popupWindowHelper.dismiss();
                    }
                }
            }
        });
        mReactionListView.addItemDecoration(new ReactionSpacesItemDecoration((int) EaseCommonUtils.dip2px(mContext, 5)));
    }

    public void show() {
        EaseReactionOptions reactionOptions = EaseIM.getInstance().getReactionOptions();
        if(reactionOptions != null && !reactionOptions.isOpen()) {
            return;
        }
        mReactionItems.clear();
        Map<String, EaseEmojicon> reactionMap = EaseMessageMenuData.getReactionDataMap();
        int count = 1;
        ReactionItemBean item;
        for (String id : EaseMessageMenuData.REACTION_FREQUENTLY_ICONS_IDS) {
            if (count > REACTION_SPAN_COUNT) {
                break;
            }
            item = new ReactionItemBean();
            item.setEmojiText("");
            item.setIdentityCode(reactionMap.get(id).getIdentityCode());
            item.setIcon(reactionMap.get(id).getIcon());
            mReactionItems.add(item);
            count++;
        }

        // add more emoticon
        item = new ReactionItemBean();
        EaseEmojicon moreEntry = EaseMessageMenuData.getReactionMore();
        item.setEmojiText(moreEntry.getEmojiText());
        item.setIdentityCode(moreEntry.getIdentityCode());
        item.setIcon(moreEntry.getIcon());
        mReactionItems.add(item);

        mReactionAdapter.setData(mReactionItems);
    }

    public View getView() {
        return mLayout;
    }

    public void setReactionItemClickListener(EasePopupWindow.OnPopupWindowItemClickListener listener) {
        mItemClickListener = listener;
    }

    public void setMessageReactions(List<EMMessageReaction> messageReactions) {
        mEmojiContainCurrentUserMap.clear();
        if (null == messageReactions) {
            mReactionAdapter.setEmojiContainCurrentUserMap(null);
            return;
        }

        for (EMMessageReaction messageReaction : messageReactions) {
            mEmojiContainCurrentUserMap.put(messageReaction.getReaction(), messageReaction.isAddedBySelf());
        }

        mReactionAdapter.setEmojiContainCurrentUserMap(mEmojiContainCurrentUserMap);
    }

    private void showAllReactionEmoticon() {
        popupWindowHelper.getView().findViewById(R.id.rv_menu_list).setVisibility(View.GONE);
        mReactionItems.clear();
        initAllReactionData();
    }

    private void initAllReactionData() {
        Map<String, EaseEmojicon> reactionMap = EaseMessageMenuData.getReactionDataMap();
        ReactionItemBean item;
        for (Map.Entry<String, EaseEmojicon> entry : reactionMap.entrySet()) {
            item = new ReactionItemBean();
            item.setEmojiText("");
            item.setIdentityCode(entry.getValue().getIdentityCode());
            item.setIcon(entry.getValue().getIcon());
            mReactionItems.add(item);
        }
        mReactionAdapter.setData(mReactionItems);
    }

    private static class ReactionAdapter extends EaseBaseRecyclerViewAdapter<ReactionItemBean> {
        private static Map<String, Boolean> mDataMap;

        public void setEmojiContainCurrentUserMap(Map<String, Boolean> emojiContainCurrentUserMap) {
            mDataMap = emojiContainCurrentUserMap;
        }

        @Override
        public ReactionViewHolder getViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(mContext).inflate(R.layout.ease_layout_item_reaction_popupwindow, parent, false);
            return new ReactionViewHolder(view);
        }

        private static class ReactionViewHolder extends ViewHolder<ReactionItemBean> {
            private View layout;
            private ImageView ivEmoticon;

            public ReactionViewHolder(@NonNull View itemView) {
                super(itemView);
            }

            @Override
            public void initView(View itemView) {
                layout = findViewById(R.id.reaction_layout);
                ivEmoticon = findViewById(R.id.iv_emoticon);
            }

            @Override
            public void setData(ReactionItemBean item, int position) {
                if (null != item) {
                    ivEmoticon.setImageResource(item.getIcon());
                    boolean isAdded;
                    if (null == mDataMap || 0 == mDataMap.size() ||
                            null == mDataMap.get(item.getIdentityCode())) {
                        isAdded = false;
                    } else {
                        isAdded = mDataMap.get(item.getIdentityCode());
                    }
                    if (isAdded) {
                        layout.setBackgroundResource(R.drawable.ease_bg_message_menu_reaction_popupwindow);
                    } else {
                        layout.setBackgroundColor(Color.TRANSPARENT);
                    }
                }
            }
        }
    }

    private static class ReactionSpacesItemDecoration extends RecyclerView.ItemDecoration {
        private final int space;

        public ReactionSpacesItemDecoration(int space) {
            this.space = space;
        }

        @Override
        public void getItemOffsets(Rect outRect, @NonNull View view,
                                   RecyclerView parent, @NonNull RecyclerView.State state) {
            outRect.bottom = space;
            outRect.top = space;
        }
    }
}
