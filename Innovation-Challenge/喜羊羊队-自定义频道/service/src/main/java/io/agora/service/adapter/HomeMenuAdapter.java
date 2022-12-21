package io.agora.service.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.CollectionUtils;
import com.bumptech.glide.Glide;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.widget.EaseImageView;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.service.R;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.repo.ServiceReposity;

public class HomeMenuAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int TYPE_TOP = 0;
    private static final int TYPE_NORMAL = 1;
    private static final int TYPE_BOTTOM = 2;
    private List<CircleServer> mList = new ArrayList<>();
    private Context mContext;
    private int mCheckedPos = 0;
    private Map<String, Integer> mUnreadMap = new HashMap<>();//规定key="-1"为单聊

    public void addData(CircleServer userGroundBean) {
        mList.add(userGroundBean);
        notifyDataSetChanged();
    }

    public void setData(Collection<CircleServer> list) {
        mList.clear();
        if (!CollectionUtils.isEmpty(list)) {
            mList.addAll(list);
            if (mCheckedPos > mList.size()) {
                mCheckedPos = mList.size();
            }
        } else {
            mCheckedPos = 0;
        }
        notifyDataSetChanged();
    }

    public HomeMenuAdapter(Context context) {
        mContext = context;
    }

    public void setCheckedPos(int pos) {
        this.mCheckedPos = pos;
        notifyDataSetChanged();
    }

    public void setCheckedServer(CircleServer server) {
        int index = mList.size() - 1;
        for (int i = 0; i < mList.size(); i++) {
            CircleServer circleServer = mList.get(i);
            if (circleServer.serverId.equals(server.serverId)) {
                index = i;
            }
        }
        this.mCheckedPos = index + 1;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == TYPE_TOP) {
            return new NormalHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_home_menu_top, parent, false));
        }
        if (viewType == TYPE_BOTTOM) {
            return new NormalHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_home_menu_bottom, parent, false));
        }
        return new NormalHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_home_menu_normal, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        int viewType = getItemViewType(position);
        int pos = position;
        if (viewType == TYPE_TOP || viewType == TYPE_NORMAL) {
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @SuppressLint("NotifyDataSetChanged")
                @Override
                public void onClick(View view) {
                    mCheckedPos = holder.getBindingAdapterPosition();
                    if (mOnMenuClickListener != null) {
                        if (viewType == TYPE_TOP) {
                            mOnMenuClickListener.onStartClick();
                        } else {
                            mOnMenuClickListener.onItemClick(holder.getBindingAdapterPosition(), mList.get(pos - 1));
                        }
                    }
                    notifyDataSetChanged();
                }
            });

            CanCheckHolder canCheckHolder = (CanCheckHolder) holder;
            canCheckHolder.mIvBg.setBackgroundResource(position == mCheckedPos ? R.drawable.sp_home_menu_selected : R.drawable.sp_home_menu_unselected);
            if (viewType == TYPE_TOP) {
                Integer count = mUnreadMap.get("-1");
                if (count != null && count.intValue() != 0) {
                    canCheckHolder.mTvUnRead.setVisibility(View.VISIBLE);
                    canCheckHolder.mTvUnRead.setText(EaseCommonUtils.handleBigNum(count.intValue()));
                } else {
                    canCheckHolder.mTvUnRead.setVisibility(View.GONE);
                }
                canCheckHolder.mIvIcon.setImageResource(mCheckedPos == 0 ? R.drawable.smile_focus : R.drawable.smile_normal);
                if (mCheckedPos == 0) {
                    mOnMenuClickListener.onStartClick();
                }
            } else {

                CircleServer server = mList.get(pos - 1);
                int randomServerIcon = ServiceReposity.getRandomServerIcon(server.serverId);
                Glide.with(mContext).load(server.icon).placeholder(randomServerIcon).into(canCheckHolder.mIvIcon);

                canCheckHolder.mTvUnRead.setVisibility(View.GONE);
                if (mCheckedPos == position) {
                    mOnMenuClickListener.onItemClick(mCheckedPos, server);
                }
            }

        } else if (viewType == TYPE_BOTTOM) {
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mOnMenuClickListener != null) {
                        mOnMenuClickListener.onAddClick();
                    }
                }
            });
        }
    }

    private OnMenuClickListener mOnMenuClickListener;

    public void setOnMenuClickListener(OnMenuClickListener onMenuClickListener) {
        mOnMenuClickListener = onMenuClickListener;
    }

    public void setUnreadMap(String groundId, int finalCount, int pos) {
        mUnreadMap.put(groundId, finalCount);
        notifyItemChanged(pos);
    }

    public interface OnMenuClickListener<T> {
        void onStartClick();

        void onItemClick(int pos, T bean);

        void onAddClick();
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return TYPE_TOP;
        }
        if (position == mList.size() + 1) {
            return TYPE_BOTTOM;
        }
        return TYPE_NORMAL;
    }

    @Override
    public int getItemCount() {
        return CollectionUtils.isEmpty(mList) ? 2 : mList.size() + 2;
    }

    private class NormalHolder extends CanCheckHolder {

        protected EaseImageView mIvIcon;

        public NormalHolder(@NonNull View itemView) {
            super(itemView);
            mIvIcon = itemView.findViewById(R.id.iv_icon);
        }
    }

    private class CanCheckHolder extends RecyclerView.ViewHolder {
        protected ImageView mIvBg;
        protected ImageView mIvIcon;
        protected TextView mTvUnRead;

        public CanCheckHolder(@NonNull View itemView) {
            super(itemView);
            mIvBg = itemView.findViewById(R.id.iv_bg);
            mIvIcon = itemView.findViewById(R.id.iv_icon);
            mTvUnRead = itemView.findViewById(R.id.tv_unread);
        }
    }
}
