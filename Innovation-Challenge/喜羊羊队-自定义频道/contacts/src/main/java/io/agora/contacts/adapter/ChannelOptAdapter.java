package io.agora.contacts.adapter;

import android.content.Context;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import io.agora.common.base.BaseAdapter;
import io.agora.contacts.R;
import io.agora.contacts.bean.ChannelOpt;

public class ChannelOptAdapter extends BaseAdapter<ChannelOpt> {
    public ChannelOptAdapter(Context context, int layoutId) {
        super(context, layoutId);
    }

    private int mCheckPos;

    @Override
    public void convert(ViewHolder holder, List<ChannelOpt> datas, int position) {
        TextView tvName = holder.getView(R.id.tv_channel_name);
        tvName.setText(datas.get(position).getTitle());

        ImageView ivChannelIcon = holder.getView(R.id.iv_channel_icon);
        ivChannelIcon.setImageResource(datas.get(position).getIcon());

        CheckBox cb = holder.getView(R.id.cb);
        cb.setChecked(position == mCheckPos);
        cb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mCheckPos = position;
                notifyDataSetChanged();
            }
        });
    }

    public int getChecked() {
        return mCheckPos;
    }
}
