package io.agora.game.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.just.agentweb.AgentWeb;
import com.just.agentweb.DefaultWebClient;
import com.just.agentweb.WebChromeClient;

import java.util.HashMap;
import java.util.Map;

import io.agora.game.R;
import io.agora.game.app.GameInit;
import io.agora.game.bean.GameContentBean;
import io.agora.game.databinding.ActivityGameContentBinding;
import io.agora.game.net.QObserver;
import io.agora.service.base.BaseInitActivity;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class GameContentActivity extends BaseInitActivity<ActivityGameContentBinding> {

    private String url;
    private AgentWeb mAgentWeb;
    public static void actionStart(Context context, String contentUrl) {
        Intent intent = new Intent(context, GameContentActivity.class);
        intent.putExtra("contentUrl",contentUrl);
        context.startActivity(intent);
    }
    @Override
    protected int getResLayoutId() {
        return R.layout.activity_game_content;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        TextView leftTitle = mBinding.toolbarGame.getLeftTitle();
        leftTitle.setText(getString(R.string.game_information));
        leftTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        leftTitle.setVisibility(View.VISIBLE);

    }



    @Override
    protected void initData() {
        super.initData();
        url = getIntent().getStringExtra("contentUrl");
        Map<String,String> map = new HashMap<>();
        map.put("postUrl",url);
        GameInit.getGameInit().getApi().getContent(map).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new QObserver<GameContentBean>(mBaseActivity, false) {
                    @Override
                    public void next(GameContentBean bean) {
                        if (bean != null ) {
                           String url = bean.getShareInfo().getContentUrl();
                           loadUrl(url);
                        }
                    }
                });
    }

    private void loadUrl(String url ){
        mAgentWeb = AgentWeb.with(this)
                .setAgentWebParent(mBinding.wvContainer, new LinearLayout.LayoutParams(-1, -1))
                .useDefaultIndicator()
                .setWebChromeClient(mWebChromeClient)
                .setWebViewClient(mWebViewClient)
//                .setMainFrameErrorView(R.layout.agentweb_error_page, -1)
                .setSecurityType(AgentWeb.SecurityType.STRICT_CHECK)
                .setOpenOtherPageWays(DefaultWebClient.OpenOtherPageWays.ASK)//打开其他应用时，弹窗咨询用户是否前往其他应用
                .interceptUnkownUrl() //拦截找不到相关页面的Scheme
                .createAgentWeb()
                .ready()
                .go(url);
    }


    private com.just.agentweb.WebViewClient mWebViewClient=new com.just.agentweb.WebViewClient(){
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            //do you  work
        }
        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
//                super.onReceivedSslError(view, handler, error); // 解除https拦截
            handler.proceed(); //证书信任
            Log.e("hwhw", "onReceivedSslError sslErrorHandler = [" + handler + "], sslError = [" + error.getPrimaryError() + "]");
        }
    };
    private WebChromeClient mWebChromeClient=new WebChromeClient(){
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            //do you work
        }


    };
}