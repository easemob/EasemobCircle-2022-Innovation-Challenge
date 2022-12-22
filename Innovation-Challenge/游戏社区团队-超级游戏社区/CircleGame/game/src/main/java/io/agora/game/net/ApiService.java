package io.agora.game.net;



import java.util.List;
import java.util.Map;

import io.agora.game.bean.CommonBean;
import io.agora.game.bean.Empty;
import io.agora.game.bean.GameContentBean;
import io.agora.game.bean.ListElementsBean;
import io.agora.game.bean.TestBean;
import io.reactivex.Observable;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;

public interface ApiService {

    @POST("/@/postPage/index/6.10.21/0/App_Android")
    Observable<CommonBean<GameContentBean>> getContent(@Body Map<String, String> map);

//    /@/lists/getListElements/6.10.21/0/App_Android?listName=2_%E5%A4%B4%E6%9D%A1%E5%88%97%E8%A1%A8&pageSize=20&pageIndex=0&deviceId=0e8abce0af03653e

    @GET("/@/lists/getListElements/6.10.21/0/App_Android?listName=2_%E5%A4%B4%E6%9D%A1%E5%88%97%E8%A1%A8&pageSize=20&pageIndex=0&deviceId=0e8abce0af03653e")
    Observable<CommonBean<List<ListElementsBean>>> getListElements();


//
//    @GET("metatown/user/getAllOccupation")
//    Observable<CommonBean<List<OccupationBean>>> getAllOccupation();
//
//    /**
//     * 根据职业获取用户列表
//     * @param map
//     * @return
//     */
//    @POST("metatown/user/getUsersByOccupation")
//    Observable<CommonBean<List<UserBean>>> getUsersByOccupation(@Body Map<String, String> map);
//
//    /**
//     * 根据职业获取用户列表
//     * @param map
//     * @return
//     * {
//     * 	"id": "用户id",
//     * 	"coins": "要操作金币数 入 10 ，-10",
//     * }
//     */
//    @POST("metatown/user/updateCoins")
//    Observable<CommonBean<UserBean>> updateCoins(@Body Map<String, Object> map);
//
//
//    @POST("metatown/user/getUsersByChatId")
//    Observable<CommonBean<UserBean>> getUsersByChatId(@Body Map<String, String> map);
//
//    /**
//     * 根据ID查询用户
//     * @param map
//     * @return
//     * {
//     * 	"id": "用户id",
//     * }
//     */
//    @POST("metatown/user/getUsersById")
//    Observable<CommonBean<UserBean>> getUsersById(@Body Map<String, String> map);
//
//    /**
//     * 获取工位列表以及用户信息
//     * @return
//     */
//    @POST("metatown/office/getAll")
//    Observable<CommonBean<List<OfficeUser>>> getAllOffice();
//
//    /**
//     * 根据职业获取用户列表
//     * @param map
//     * @return
//     * {
//     * 	"id": "400001",
//     * 	"status": "程序员",
//     * 	"uid": "1560644374419865600",
//     * }
//     */
//    @POST("metatown/office/update")
//    Observable<CommonBean<OfficeUser>> updateStatus(@Body Map<String, String> map);
//
//
//
//    /**
//     * 打卡接口
//     * @param map
//     * @return
//     * {
//     * 	"id": "400001",  用户ID
//     * }
//     */
//    @POST("metatown/user/punchClock")
//    Observable<CommonBean<Empty>> punchClock(@Body Map<String, String> map);
}
