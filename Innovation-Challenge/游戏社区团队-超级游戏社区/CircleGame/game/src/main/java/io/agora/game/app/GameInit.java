package io.agora.game.app;

import java.util.concurrent.TimeUnit;

import io.agora.game.net.ApiService;
import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

public class GameInit {
    public static final long NET_TIMEOUT_SECONDS = 30;
    public static final String HTTP_HOST = "http://router.gamersky.com/";
    private static ApiService sApi;

    private static GameInit sGameInit = new GameInit();

    private GameInit() {
    }

    public static GameInit getGameInit() {
        return sGameInit;
    }

    public void initHttp() {
        OkHttpClient client = new OkHttpClient
                .Builder()
                //断线重连
                .retryOnConnectionFailure(true)
                //链接超时时间
                .connectTimeout(NET_TIMEOUT_SECONDS, TimeUnit.SECONDS)
                //写超时时间
                .writeTimeout(NET_TIMEOUT_SECONDS, TimeUnit.SECONDS)
                //读超时时间
                .readTimeout(NET_TIMEOUT_SECONDS, TimeUnit.SECONDS)
                .build();


        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(HTTP_HOST)
                .addConverterFactory(GsonConverterFactory.create()) //增加返回值为Gson的支持(以实体类返回)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create()) //增加返回值为Oservable<T>的支持
                .client(client)//配置OkHttpClient
                .build();

        sApi = retrofit.create(ApiService.class);

    }

    public  ApiService getApi() {
        return sApi;
    }
}
