package io.agora.game.utils;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.stx.xhb.xbanner.XBanner;
import com.stx.xhb.xbanner.transformers.Transformer;

import java.util.List;

import io.agora.game.bean.ChildElements;

/**
 * 项目名:    中移在线
 * 包名       com.yinuo.wann.animalhusbandrytg
 * 文件名:    BannerRuleUtil
 * 创建时间:  2020-09-02 on 10:25
 * 描述:      banner跳转规则基类
 *
 * @author 流年
 */
public class BannerRuleUtil {
    //控件宽高比
    public static void initXBannerAspectRatio(Context context, View view, int width, int height) {
        ViewGroup.MarginLayoutParams linearParams = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        linearParams.height = (int) (DisplayUtil.getWidth(context) * height / width);
        linearParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        view.setLayoutParams(linearParams);
    }


    /**
     * 轮播图跳转规则（通知跳转）
     */
    public static void initXBanner(final Context context, XBanner xBanner, final List<ChildElements> bannerInfoList, final boolean isRound, String come) {//come:来自哪里 StudyArea学习区域不跳学习模块列表
        xBanner.setPageTransformer(Transformer.Default);

        xBanner.loadImage(new XBanner.XBannerAdapter() {
            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
            @Override
            public void loadBanner(XBanner banner, Object model, View view, int position) {
                //此处适用Fresco加载图片，可自行替换自己的图片加载框架
//                int resId = bannerInfoList.get(position).getResId();
//                Drawable drawable = MarketApplication.getContext().getResources().getDrawable(resId);
                if (isRound) {
                    Glide.with(context).load(bannerInfoList.get(position).getThumbnailUrls().get(0)).apply(new RequestOptions().bitmapTransform(new GlideRoundBannerTransform(context, 5))).into((ImageView) view);
                } else {
                    Glide.with(context).load(bannerInfoList.get(position).getThumbnailUrls().get(0)).into((ImageView) view);
                }

//                ImageUtil.load((ImageView) view,bannerInfoList.get(position).filePath);
//                Glide.with(mActivity).load(bannerInfoList.get(position).getImg_url()).apply(new RequestOptions().bitmapTransform(new RoundedCorners(15))).into((ImageView) view);
            }
        });
    }


    /**
     * 轮播图跳转规则（通知跳转）
     */
//    public static void initXBannerForExperience(final Context context, XBanner xBanner, final List<BannerBean> bannerInfoList, final boolean isRound, String come) {//come:来自哪里 StudyArea学习区域不跳学习模块列表
//        xBanner.setPageTransformer(Transformer.Default);
//        xBanner.setOnItemClickListener(new XBanner.OnItemClickListener() {
//            @Override
//            public void onItemClick(XBanner banner, Object model, View view, int position) {
//                Intent intent = new Intent(MarketApplication.getContext(), WebviewActivity.class);
//                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//                intent.putExtra(WebViewHelper.EXTRA_DEALBACK, false);
//                intent.putExtra(WebViewHelper.EXTRA_TEXT_SIZE_LARGE, true);
//                intent.putExtra(WebViewHelper.EXTRA_URL, bannerInfoList.get(position).getWebUrl());
//                MarketApplication.getContext().startActivity(intent);
//            }
//        });
//        xBanner.loadImage(new XBanner.XBannerAdapter() {
//            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
//            @Override
//            public void loadBanner(XBanner banner, Object model, View view, int position) {
//                //此处适用Fresco加载图片，可自行替换自己的图片加载框架
//                int resId = bannerInfoList.get(position).getResId();
//                Drawable drawable = MarketApplication.getContext().getResources().getDrawable(resId);
//                if (isRound) {
//                    Glide.with(context).load(drawable).apply(new RequestOptions().bitmapTransform(new GlideRoundBannerTransform(context, 5))).into((ImageView) view);
//                } else {
//                    Glide.with(context).load(drawable).into((ImageView) view);
//                }
//
//                //ImageUtil.load((ImageView) view,bannerInfoList.get(position).filePath);
//                //Glide.with(mActivity).load(bannerInfoList.get(position).getImg_url()).apply(new RequestOptions().bitmapTransform(new RoundedCorners(15))).into((ImageView) view);
//            }
//        });
//    }
}