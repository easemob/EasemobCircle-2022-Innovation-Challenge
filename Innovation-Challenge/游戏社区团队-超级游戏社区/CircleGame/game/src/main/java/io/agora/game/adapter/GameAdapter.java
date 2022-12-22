package io.agora.game.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.hyphenate.easeui.adapter.EaseBaseRecyclerViewAdapter;

import java.util.List;

import io.agora.game.R;
import io.agora.game.bean.ListElementsBean;
import io.agora.game.utils.GlideRoundBannerTransform;

public class GameAdapter extends EaseBaseRecyclerViewAdapter<ListElementsBean> {

    private List<ListElementsBean> mListElementsBeans;
    private Context mContext;

    public GameAdapter(Context context) {
        mContext = context;
    }


    @Override
    public ViewHolder getViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_game, parent, false);
        return new GameViewHolder(view);
    }

    private class GameViewHolder extends ViewHolder<ListElementsBean>{
        private ImageView img;
        private TextView title,time;

        public GameViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void initView(View itemView) {
            img = findViewById(R.id.iv_game);
            title = findViewById(R.id.tv_game_title);
            time = findViewById(R.id.tv_game_time);
        }

        @Override
        public void setData(ListElementsBean item, int position) {
            title.setText(item.getTitle());
            if (!TextUtils.isEmpty(item.getPublishTimeCaption())){
                time.setVisibility(View.VISIBLE);
                time.setText(item.getPublishTimeCaption());
            } else {
                time.setVisibility(View.INVISIBLE);
            }

            Log.e("wyz", item.getTitle() + "setData: "+item.getContentUrl());
            if (item.getThumbnailUrls() != null && item.getThumbnailUrls().size() > 0) {
                Glide.with(mContext).load(item.getThumbnailUrls().get(0)).apply(new RequestOptions().bitmapTransform(new GlideRoundBannerTransform(mContext, 5))).into((ImageView) img);
            }

        }
    }
}
