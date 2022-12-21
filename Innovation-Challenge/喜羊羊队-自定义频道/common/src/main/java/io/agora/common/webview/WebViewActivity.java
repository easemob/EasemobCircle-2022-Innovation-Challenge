package io.agora.common.webview;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.just.agentweb.AgentWeb;
import com.just.agentweb.DefaultWebClient;
import com.just.agentweb.WebChromeClient;
import com.just.agentweb.WebViewClient;

import io.agora.common.R;
import io.agora.common.base.BaseActivity;

public class WebViewActivity extends BaseActivity {

    private LinearLayout ll_container;
    private AgentWeb mAgentWeb;

    @Override
    protected int getResLayoutId() {
        return R.layout.activity_web_view;
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        ll_container = findViewById(R.id.ll_container);
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mAgentWeb = AgentWeb.with(this)
                .setAgentWebParent(ll_container, new LinearLayout.LayoutParams(-1, -1))
                .useDefaultIndicator()
                .setWebChromeClient(mWebChromeClient)
                .setWebViewClient(mWebViewClient)
//                .setMainFrameErrorView(R.layout.agentweb_error_page, -1)
                .setSecurityType(AgentWeb.SecurityType.STRICT_CHECK)
                .setOpenOtherPageWays(DefaultWebClient.OpenOtherPageWays.ASK)//打开其他应用时，弹窗咨询用户是否前往其他应用
                .interceptUnkownUrl() //拦截找不到相关页面的Scheme
                .createAgentWeb()
                .ready()
                .go(getUrl());

//        mAgentWeb.getJsInterfaceHolder().addJavaObject("android",new AndroidInterface(mAgentWeb,this));
    }

    private String getUrl() {
        return getIntent().getStringExtra("url");
    }

    @Override
    protected void initData() {
        super.initData();
    }

    private WebViewClient mWebViewClient=new WebViewClient(){
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            //do you  work
        }
    };
    private WebChromeClient mWebChromeClient=new WebChromeClient(){
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            //do you work
        }
    };

    @Override
    protected void onPause() {
        mAgentWeb.getWebLifeCycle().onPause();
        super.onPause();

    }

    @Override
    protected void onResume() {
        mAgentWeb.getWebLifeCycle().onResume();
        super.onResume();
    }

    public void onDestroy() {
        mAgentWeb.getWebLifeCycle().onDestroy();
        super.onDestroy();
    }

    public static void actionStart(Context context,String url){
        Intent intent = new Intent(context,WebViewActivity .class);
        intent.putExtra("url",url);
        context.startActivity(intent);
    }

}