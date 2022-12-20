package io.agora.service.db.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import java.util.List;

import io.agora.service.db.entity.CircleUser;


@Dao
public interface CircleUserDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(CircleUser... users);

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    List<Long> insertIfNotExist(CircleUser... users);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(List<CircleUser> users);

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    List<Long> insertIfNotExist(List<CircleUser> users);

    @Query("select * from circle_user where username = :arg0")
    LiveData<List<CircleUser>> loadUserById(String arg0);

    @Query("select * from circle_user where username = :arg0")
    CircleUser loadUserByUserId(String arg0);

    @Query("select * from circle_user where username = :arg0")
    LiveData<CircleUser> loadUserLiveDataByUserId(String arg0);

    @Query("select contact from circle_user where username = :arg0")
    int getUserContactById(String arg0);

    @Query("select * from circle_user where contact = 0")
    LiveData<List<CircleUser>> loadUsers();

    @Query("select * from circle_user where contact = 0")
    List<CircleUser> loadContacts();

    @Query("select * from circle_user where contact = 1")
    LiveData<List<CircleUser>> loadBlackUsers();

    @Query("select * from circle_user where contact = 1")
    List<CircleUser> loadBlackEaseUsers();

    @Query("select username from circle_user")
    List<String> loadAllUsers();

    @Query("select username from circle_user where contact = 0 or contact = 1")
    List<String> loadContactUsers();

    @Query("select * from circle_user")
    List<CircleUser> loadAllCircleUsers();

    @Query("select * from circle_user where contact = 0 or contact = 1")
    List<CircleUser> loadAllContactUsers();

    @Query("delete from circle_user")
    int clearUsers();

    @Query("delete from circle_user where contact = 1")
    int clearBlackUsers();

    @Query("delete from circle_user where username = :arg0")
    int deleteUser(String arg0);

    @Query("update circle_user set contact = :arg0  where username = :arg1")
    int updateContact(int arg0, String arg1);

    @Query("update circle_user set nickname = :nickName  where username = :username")
    int updateNickName(String nickName , String username);

    @Query("select username from circle_user where lastModifyTimestamp + :arg0  <= :arg1")
    List<String> loadTimeOutEaseUsers(long arg0, long arg1);

    @Query("select username from circle_user where lastModifyTimestamp + :arg0  <= :arg1 and contact = 1")
    List<String> loadTimeOutFriendUser(long arg0, long arg1);

}
