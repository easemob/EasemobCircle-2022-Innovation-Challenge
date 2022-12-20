package io.agora.ground.adapter;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ConvertUtils;
import com.bumptech.glide.Glide;

import java.util.ArrayList;
import java.util.List;

import io.agora.ground.R;
import io.agora.ground.callbacks.OnItemClickListener;
import io.agora.ground.widget.BlurringView;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.repo.ServiceReposity;
import io.agora.service.utils.KeyWordUtil;

public class GroundAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private Context mContext;
    private List<CircleServer> mList = new ArrayList<>();
    private OnItemClickListener<CircleServer> mOnItemClickListener;
    private String mKey;
    public static final int TYPE_TOP = 0;
    public static final int TYPE_NORMAL = 1;
    public static final int TYPE_EMPTY = 2;
    private OnSearchClickListener mOnSearchClickListener;
    private boolean mShowTop;

    public GroundAdapter(boolean showTop) {
        mShowTop = showTop;
    }

    public GroundAdapter(Context context, boolean showTop) {
        this.mContext = context;
        mShowTop = showTop;
    }

    public void setData(List<CircleServer> list) {
        if (list == null) {
            return;
        }
        mList.clear();
        mList.addAll(list);
        notifyDataSetChanged();
    }

    public void setData(List<CircleServer> list, String key) {
        if (list == null) {
            return;
        }
        mList.clear();
        mList.addAll(list);
        mKey = key;
        notifyDataSetChanged();
    }

    public void addData(List<CircleServer> list) {
        if (CollectionUtils.isEmpty(list)) {
            return;
        }
        mList.addAll(list);
        notifyItemRangeInserted(mList.size() - list.size() + 1, list.size());
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (!mShowTop) {
            if (viewType == TYPE_EMPTY) {
                return new EmptyHolder(LayoutInflater.from(parent.getContext()).inflate(io.agora.service.R.layout.layout_empty, parent, false));
            }
            return new GroundViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ground, parent, false));
        }

        if (viewType == TYPE_TOP) {
            return new TopHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_search_ground_top, parent, false));
        }

        if (viewType == TYPE_EMPTY) {
            return new EmptyHolder(LayoutInflater.from(parent.getContext()).inflate(io.agora.service.R.layout.layout_empty, parent, false));
        }

        return new GroundViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ground, parent, false));
    }

    @Override
    public int getItemViewType(int position) {
        if (!mShowTop) {
            if (mList.isEmpty()) {
                return TYPE_EMPTY;
            }
            return TYPE_NORMAL;
        }

        if (position == 0) {
            return TYPE_TOP;
        }

        if ((mList == null || mList.isEmpty()) && position == 1) {
            return TYPE_EMPTY;
        }

        return TYPE_NORMAL;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder viewHolder, int position) {
        int viewType = getItemViewType(position);

        if (viewType == TYPE_TOP) {
            TopHolder holder = (TopHolder) viewHolder;
            StaggeredGridLayoutManager.LayoutParams layoutParams = new StaggeredGridLayoutManager.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            // set title full span
            layoutParams.setFullSpan(true);
            holder.itemView.setLayoutParams(layoutParams);
            holder.mTvSearch.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mOnSearchClickListener != null) {
                        mOnSearchClickListener.onSearchClick();
                    }
                }
            });
        } else if (viewType == TYPE_NORMAL) {
            GroundViewHolder holder = (GroundViewHolder) viewHolder;
            CircleServer bean = mList.get(mShowTop ? position - 1 : position);

            setText(holder.serverName, bean.name);
            setText(holder.tvDesc, bean.desc);
            Glide.with(holder.ivServer)
                    .load(ServiceReposity.getRandomServerIcon(bean.serverId))
                    .placeholder(ServiceReposity.getRandomServerIcon(bean.serverId))
                    .into(holder.ivServer);
            Glide.with(holder.ivServerIcon)
                    .load(bean.icon)
                    .placeholder(ServiceReposity.getRandomServerIcon(bean.serverId))
                    .into(holder.ivServerIcon);
            for (CircleServer.Tag tag : bean.tags) {
                if (mContext != null && !TextUtils.isEmpty(tag.name)) {
                    TextView textView = new TextView(mContext);
                    Drawable drawableLeft = mContext.getResources().getDrawable(io.agora.service.R.drawable.circle_bookmark);
                    textView.setCompoundDrawablesWithIntrinsicBounds(drawableLeft,
                            null, null, null);
                    textView.setCompoundDrawablePadding(4);
                    textView.setText(tag.name);
                    textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 8);
                    textView.setTextColor(Color.WHITE);
                    textView.setPadding(0, 0, ConvertUtils.dp2px(6), 0);
                    holder.llTags.addView(textView);
                }
            }

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mOnItemClickListener != null) {
                        mOnItemClickListener.onItemClick(bean);
                    }
                }
            });
        } else if (viewType == TYPE_EMPTY) {
            EmptyHolder holder = (EmptyHolder) viewHolder;
            StaggeredGridLayoutManager.LayoutParams layoutParams = new StaggeredGridLayoutManager.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            // set title full span
            layoutParams.setFullSpan(true);
            holder.itemView.setLayoutParams(layoutParams);
        }

    }

    public void setOnSearchClickListener(OnSearchClickListener onSearchClickListener) {
        mOnSearchClickListener = onSearchClickListener;
    }

    public interface OnSearchClickListener {
        void onSearchClick();
    }

    @Override
    public int getItemCount() {
        int size;
        if (mList == null || mList.isEmpty()) {
            if (mShowTop) {
                size = 2;
            } else {
                size = 1;
            }
        } else {
            if (mShowTop) {
                size = mList.size() + 1;
            } else {
                size = mList.size();
            }
        }

        return size;
    }

    public void clearData() {
        mList = new ArrayList<>();
        mKey = "";
        notifyDataSetChanged();
    }

    protected class TopHolder extends RecyclerView.ViewHolder {

        protected TextView mTvSearch;

        public TopHolder(@NonNull View itemView) {
            super(itemView);

            mTvSearch = itemView.findViewById(R.id.tv_search);
        }
    }

    protected class EmptyHolder extends RecyclerView.ViewHolder {

        public EmptyHolder(@NonNull View itemView) {
            super(itemView);
        }
    }

    protected class GroundViewHolder extends RecyclerView.ViewHolder {

        public TextView tvDesc;
        public TextView serverName;
        public ImageView ivServer;
        private LinearLayout llTags;
        private ImageView ivServerIcon;

        public GroundViewHolder(@NonNull View itemView) {
            super(itemView);

            ivServer = itemView.findViewById(R.id.iv_server);
            serverName = itemView.findViewById(R.id.tv_name);
            tvDesc = itemView.findViewById(R.id.tv_describe);
            llTags = itemView.findViewById(R.id.ll_tags);
            ivServerIcon = itemView.findViewById(R.id.iv_server_icon);

            BlurringView bv = itemView.findViewById(R.id.bv);
            bv.setBlurredView(ivServer);
        }
    }

    public void setOnItemClickListener(OnItemClickListener<CircleServer> onItemClickListener) {
        mOnItemClickListener = onItemClickListener;
    }

    private void setText(TextView textView, String text) {
        if (!TextUtils.isEmpty(text) && !TextUtils.isEmpty(mKey) && text.contains(mKey)) {
            textView.setText(KeyWordUtil.matcherSearchTitleBackColor(Color.parseColor("#27ae60"), text, mKey));
        } else {
            textView.setText(text);
        }
    }
}
