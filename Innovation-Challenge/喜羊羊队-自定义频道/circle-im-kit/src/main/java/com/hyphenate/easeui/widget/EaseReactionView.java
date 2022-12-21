package com.hyphenate.easeui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageReaction;
import com.hyphenate.easeui.R;
import com.hyphenate.easeui.adapter.FlowlayoutAdapter;
import com.hyphenate.easeui.domain.EaseEmojicon;
import com.hyphenate.easeui.interfaces.OnItemClickListener;
import com.hyphenate.easeui.model.EaseMessageMenuData;
import com.hyphenate.easeui.model.EaseReactionEmojiconEntity;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.util.EMLog;

import java.util.ArrayList;
import java.util.List;


public class EaseReactionView extends ViewGroup {
    private String TAG = getClass().getSimpleName();

    private List<List<View>> groups;//用来装一行一行的集合
    private FlowlayoutAdapter adapter;
    private OnReactionItemListener mListener;
    private int maxReactionUsers = 9999;
    private int maxReactionDatas = 20;
    private OnItemClickListener itemClickListener;

    public EaseReactionView(Context context) {
        this(context, null);
    }

    public EaseReactionView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EaseReactionView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        groups = new ArrayList<>();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int width = MeasureSpec.getSize(widthMeasureSpec);//包含padding
        int height = 0;
        int maxHeight = 0;

        List<View> lineViews = new ArrayList<>();//用来装每行的子view的集合
        groups.clear();//因为onmeasure方法不止调用一次
        groups.add(lineViews);//第一行先添加进来

        int lineWidth = getPaddingLeft() + getPaddingRight();
        //1、for循环测量子view
        int childCount = getChildCount();//获取子view数量
        for (int i = 0; i < childCount; i++) {
            View child = getChildAt(i);//获取子view
            measureChild(child, widthMeasureSpec, heightMeasureSpec);//此处测量后就可以获取子view的宽高

            MarginLayoutParams params = (MarginLayoutParams) child.getLayoutParams();//仿照linearlayout重写generateLayoutParams（），获取自己的margin

            int childWidth = child.getMeasuredWidth() + params.rightMargin + params.leftMargin;
            int childHeight = child.getMeasuredHeight() + params.topMargin + params.bottomMargin;

            lineWidth += childWidth;//若干子view累积的宽度

            if (lineWidth > width) {//累积的宽度与父布局的宽度比较，超过父布局的宽度时
                height += maxHeight;//每换一行就加上上一行的高度
                maxHeight = 0;//上一行的高度清零
                lineViews = new ArrayList<>();//新的一行就重新new一个集合来装一行的子view
                groups.add(lineViews);//将每行的集合添加进装行数的总组中
                lineWidth = childWidth + getPaddingLeft() + getPaddingRight();//此处为另起一行，需要重置这一行的宽度为此行第一个子view的宽度
            }
            maxHeight = Math.max(maxHeight, childHeight);//取每行最大的高度值
            lineViews.add(child);//将每行的子view添加进每行的集合中
        }
        //2、根据子view计算和指定自己的布局
        setMeasuredDimension(width, height + maxHeight + getPaddingTop() + getPaddingBottom());
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        //3、循环遍历给每个子view指定位置
        int lineHeight = 0;
        int maxHeight = 0;
        boolean isTop = true;
        for (List<View> group : groups) {
            int left = getPaddingLeft();
            if (isTop) {
                lineHeight = getPaddingTop();//第一行才加上父布局的paddingTop
                isTop = false;
            }
            for (View child : group) {
                MarginLayoutParams params = (MarginLayoutParams) child.getLayoutParams();//仿照linearlayout重写generateLayoutParams（），获取自己的margin
                child.layout(left + params.leftMargin, lineHeight + params.topMargin, left + params.leftMargin + child.getMeasuredWidth(), lineHeight + params.topMargin + child.getMeasuredHeight());
                left += child.getMeasuredWidth() + params.leftMargin + params.rightMargin;
                maxHeight = Math.max(maxHeight, child.getHeight() + params.topMargin + params.bottomMargin);
            }

            lineHeight += maxHeight;
            maxHeight = 0;//新的一行最大高度重新计算
        }
    }

    /**
     * 获得view的margin等值
     *
     * @param attrs
     * @return
     */
    @Override
    public LayoutParams generateLayoutParams(AttributeSet attrs) {
        return new MarginLayoutParams(getContext(), attrs);
    }

    /**
     * 此处使用适配器模式，外界给view设置一个适配器，解耦
     *
     * @param adapter
     */
    public void setAdapter(FlowlayoutAdapter adapter) {
        removeAllViews();
        if (adapter == null) {
            throw new NullPointerException();
        }

        this.adapter = adapter;

        int count = adapter.getCount();

        for (int i = 0; i < count; i++) {
            View view = adapter.getView(i, this);
            addView(view);
        }
    }

    public synchronized void updateMessageInfo(EMMessage message) {
        if (null == message) {
            EMLog.e(TAG, "message is null, don't setup reaction view");
            return;
        }
        //default gone
        this.setVisibility(GONE);

        List<EMMessageReaction> messageReactions = message.getMessageReaction();
        if (null != messageReactions && messageReactions.size() > 0) {
            List<EaseReactionEmojiconEntity> list = new ArrayList<>(messageReactions.size());
            EaseReactionEmojiconEntity entity;
            EaseEmojicon emojicon;
            for (EMMessageReaction messageReaction : messageReactions) {
                entity = new EaseReactionEmojiconEntity();
                emojicon = EaseMessageMenuData.getReactionDataMap().get(messageReaction.getReaction());
                if (emojicon != null) {
                    entity.setEmojicon(emojicon);
                    entity.setCount(messageReaction.getUserCount());
                    entity.setUserList(messageReaction.getUserList());
                    entity.setAddedBySelf(messageReaction.isAddedBySelf());
                    list.add(entity);
                }
            }
            if (0 != list.size()) {
                this.setVisibility(VISIBLE);
                updateData(list, message.getMsgId());
            }
        }
    }

    private void updateData(List<EaseReactionEmojiconEntity> datas, String msgId) {
        //添加最后的添加按钮
        EaseReactionEmojiconEntity vitualEntity = new EaseReactionEmojiconEntity();
        vitualEntity.setCount(0);
        EaseEmojicon emojicon = new EaseEmojicon();
        emojicon.setIcon(R.drawable.ease_add_reaction);
        vitualEntity.setEmojicon(emojicon);
        datas.add(vitualEntity);

        setAdapter(new FlowlayoutAdapter() {
            @Override
            public int getCount() {
                return datas.size();
            }

            @Override
            public View getView(final int position, ViewGroup parent) {
                EaseReactionEmojiconEntity emojiconEntity = datas.get(position);
                View itemView = LayoutInflater.from(getContext()).inflate(R.layout.item_reaction, parent, false);
                TextView tvCount = itemView.findViewById(R.id.tv_reaction_count);
                ImageView ivEmo = itemView.findViewById(R.id.iv_emotion);

                int count = emojiconEntity.getCount();
                if (count == 0) {
                    tvCount.setVisibility(GONE);
                } else {
                    tvCount.setVisibility(VISIBLE);
                    if (count > maxReactionUsers) {
                        count = maxReactionUsers;
                    }
                    tvCount.setText(count + "");
                }

                ivEmo.setImageResource(emojiconEntity.getEmojicon().getIcon());
                if (emojiconEntity.isAddedBySelf()) {
                    itemView.setSelected(true);
                } else {
                    itemView.setSelected(false);
                }
                if (position == datas.size() - 1) {
                    //最后一个添加按钮不显示背景
                    itemView.setBackground(null);
                    ConstraintLayout.LayoutParams layoutParams = (ConstraintLayout.LayoutParams) ivEmo.getLayoutParams();
                    layoutParams.setMargins(0,0,0,0);
                    layoutParams.width= (int) EaseCommonUtils.dip2px(getContext(),20);
                    layoutParams.height= (int) EaseCommonUtils.dip2px(getContext(),20);
                    ivEmo.setLayoutParams(layoutParams);
                }
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (position == datas.size() - 1) {
                            if (datas.size() > maxReactionDatas) {
                                Toast.makeText(getContext(), getContext().getString(R.string.reaction_to_max), Toast.LENGTH_SHORT).show();
                            } else {
                                //弹框
                                if (itemClickListener != null) {
                                    itemClickListener.onItemClick(itemView, position);
                                }
                            }
                        } else {
                            if (mListener != null) {
                                if (itemView.isSelected()) {
                                    mListener.removeReaction(emojiconEntity);
                                } else {
                                    mListener.addReaction(emojiconEntity);
                                }
                            }
                        }
                    }
                });
                return itemView;
            }
        });
    }

    public void setOnReactionItemListener(OnReactionItemListener onReactionItemListener) {
        mListener = onReactionItemListener;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.itemClickListener = listener;
    }

    public interface OnReactionItemListener {

        void removeReaction(EaseReactionEmojiconEntity reactionEntity);

        void addReaction(EaseReactionEmojiconEntity reactionEntity);
    }
}
