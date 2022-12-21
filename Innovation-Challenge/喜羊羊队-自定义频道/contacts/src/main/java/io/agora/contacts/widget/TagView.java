package io.agora.contacts.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import io.agora.contacts.R;
import io.agora.service.db.entity.CircleServer;


public class TagView extends ViewGroup {

    private View view;
    private int measuredWidth;
    private int measuredHeight;
    private TextView tvContent;
    private ImageView ivDelete;
    private OnDeleteClickListener onDeleteClickListener;
    private CircleServer.Tag tag;

    public TagView(Context context) {
        this(context, null);
    }

    public TagView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TagView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        view = LayoutInflater.from(getContext()).inflate(R.layout.widget_tag, this, false);
        tvContent = view.findViewById(R.id.tv_content);
        ivDelete = view.findViewById(R.id.iv_delete);
        addView(view);
        addListener();
    }

    private void addListener() {
        ivDelete.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onDeleteClickListener != null) {
                    onDeleteClickListener.onClick(TagView.this);
                }
            }
        });
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        measureChild(view, widthMeasureSpec, heightMeasureSpec);
        measuredWidth = view.getMeasuredWidth();
        measuredHeight = view.getMeasuredHeight();
        setMeasuredDimension(measuredWidth, measuredHeight);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        view.layout(0, 0, measuredWidth, measuredHeight);
    }

    public void setTagData(CircleServer.Tag tag) {
        this.tag = tag;
        tvContent.setText(tag.name);
        requestLayout();
    }

    public CircleServer.Tag getData() {
        return tag;
    }

    public interface OnDeleteClickListener {
        void onClick(View view);
    }

    public void setonDeleteClickListener(OnDeleteClickListener listener) {
        this.onDeleteClickListener = listener;
    }
}
