package io.agora.common.base;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.LayoutRes;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.common.R;


public abstract class BaseAdapter<T> extends RecyclerView.Adapter<BaseAdapter.ViewHolder> {

    private MuitiTypeSupport muitiTypeSupport;
    protected Context mContext;
    private List<T> datas;//数据类型用泛型代替，由使用者自己配置
    private int layoutId;
    private LayoutInflater inflater;
    public static final int VIEW_TYPE_EMPTY = -1;
    private int emptyViewId;
    private boolean hideEmptyView;
    private View emptyView;
    protected SubViewClickListener subViewClickListener;
    protected OnUserPresenceListener userPresenceListener;
    private ItemLongClickListener longClickListener;

    public BaseAdapter(Context context, int layoutId) {
        this(context, null, layoutId);
    }


    public BaseAdapter(Context context, List<T> datas, int layoutId) {
        this.datas = datas;
        this.layoutId = layoutId;
        this.mContext = context;
        inflater = LayoutInflater.from(context);
    }

    public BaseAdapter(Context context, List<T> datas, MuitiTypeSupport muitiTypeSupport) {
        this(context, datas, -1);
        this.muitiTypeSupport = muitiTypeSupport;
    }

    @Override
    public int getItemViewType(int position) {
        if (datas == null || datas.isEmpty()) {
            return VIEW_TYPE_EMPTY;
        }
        if (muitiTypeSupport != null) {
            return muitiTypeSupport.getLayoutId(position);
        }
        return super.getItemViewType(position);
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == VIEW_TYPE_EMPTY) {
            return getEmptyViewHolder(parent);
        }
        if (muitiTypeSupport != null) {
            layoutId = viewType;
        }
        return new ViewHolder(inflater.inflate(layoutId, parent, false));
    }


    @Override
    public void onBindViewHolder(ViewHolder holder, @SuppressLint("RecyclerView") final int position) {
        if (isEmptyViewType(position)) {
            return;
        }
        convert(holder, datas, position);//把数据暴露出去，由实现者具体去实现
        //设置点击事件
        if (clickListener != null) {
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    clickListener.onClick(v, position);
                }
            });
        }
        if (longClickListener != null) {
            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    return longClickListener.onClick(position);
                }
            });
        }
    }

    protected ViewHolder getEmptyViewHolder(ViewGroup parent) {
        View emptyView = getEmptyView(parent);
        if (this.emptyView != null) {
            emptyView = this.emptyView;
        }
        if (this.emptyViewId > 0) {
            emptyView = LayoutInflater.from(mContext).inflate(this.emptyViewId, parent, false);
        }
        if (hideEmptyView) {
            emptyView = LayoutInflater.from(mContext).inflate(R.layout.layout_no_data_show_nothing, parent, false);
        }
        return new ViewHolder(emptyView);
    }

    private View getEmptyView(ViewGroup parent) {
        return LayoutInflater.from(mContext).inflate(getEmptyLayoutId(), parent, false);
    }

    public int getEmptyLayoutId() {
        return emptyViewId == 0 ? R.layout.ease_layout_default_no_data : emptyViewId;
    }

    public void setEmptyLayoutId(@LayoutRes int emptyLayoutId) {
        this.emptyViewId = emptyLayoutId;
    }

    /**
     * Check if it is an empty layout type
     *
     * @param position
     * @return
     */
    public boolean isEmptyViewType(int position) {
        int viewType = getItemViewType(position);
        return viewType == VIEW_TYPE_EMPTY;
    }

    public void hideEmptyView(boolean hide) {
        hideEmptyView = hide;
        notifyDataSetChanged();
    }

    public abstract void convert(ViewHolder holder, List<T> datas, int position);

    @Override
    public int getItemCount() {
        if (datas == null || datas.isEmpty()) {
            return 1;
        }
        return muitiTypeSupport == null ? (datas == null ? 0 : datas.size()) : muitiTypeSupport.getItemCount();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        private SparseArray<View> sparseArray;//省去装箱拆箱，效率更高

        public ViewHolder(View itemView) {
            super(itemView);
            sparseArray = new SparseArray();
        }

        /**
         * 通过id获取view
         *
         * @param viewId
         * @param <V>
         * @return
         */
        public <V extends View> V getView(int viewId) {
            View view = sparseArray.get(viewId);
            if (view == null) {
                view = itemView.findViewById(viewId);
                sparseArray.put(viewId, view);
            }
            return (V) view;
        }

        /**
         * 设置文本
         *
         * @param viewId
         * @param text
         * @return this, 方便使用链式调用
         */
        public ViewHolder setText(int viewId, CharSequence text) {
            android.widget.TextView textView = getView(viewId);
            textView.setText(text);
            return this;
        }

        /**
         * 使用系统的ImageView直接设置图片资源
         *
         * @param viewId
         * @param imgId
         * @return
         */
        public ViewHolder setImageResource(int viewId, int imgId) {
            ImageView imageView = getView(viewId);
            imageView.setImageResource(imgId);
            return this;
        }

        /**
         * 使用第三方工具加载图片
         *
         * @param viewId
         * @param imagePath
         * @param imageLoader
         * @param <S>
         * @return
         */
        public <S> ViewHolder setImageByThirdUtils(int viewId, S imagePath, ImageLoader imageLoader) {
            if (imageLoader == null) {
                throw new NullPointerException("imageLoader不能为空");
            }
            imageLoader.setImage((ImageView) getView(viewId), imagePath);
            return this;
        }

        static abstract class ImageLoader {
            public abstract <T> void setImage(ImageView imageView, T imagePath);
        }
    }

    public void refresh(List<T> datas) {
        this.datas = datas;
        notifyDataSetChanged();
    }

    public List<T> getDatas() {
        return datas;
    }

    public interface ItemClickListener {
        void onClick(View itemView, int positon);
    }

    private ItemClickListener clickListener;

    public void setOnItemClickListener(ItemClickListener listener) {
        this.clickListener = listener;
    }

    public void setOnSubViewClickListener(SubViewClickListener listener) {
        this.subViewClickListener = listener;
    }


    public interface ItemLongClickListener {
        boolean onClick(int positon);
    }

    public interface SubViewClickListener {
        void onSubViewClick(View v, int positon);
    }


    public void setOnItemLongClickListener(ItemLongClickListener listener) {
        this.longClickListener = listener;
    }

    public interface OnUserPresenceListener {
        void subscribe(String username, long expireTime);
    }

    public void setOnUserPresenceListener(OnUserPresenceListener userPresenceListener) {
        this.userPresenceListener = userPresenceListener;
    }

    /**
     * 多布局加载,这个本质上还是一种接口回调的思想，只不过是改为直接从构造器中去设置了罢了
     */
    public interface MuitiTypeSupport {
        /**
         * 根据数据内容或者位置position来拿布局
         *
         * @param positon
         * @return
         */
        int getLayoutId(int positon);

        /**
         * 作为几个布局来显示
         *
         * @return
         */
        int getItemCount();
    }

}
