package io.agora.service.db.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

import io.agora.service.db.entity.CircleServer;

@Dao
public interface CircleServerDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(CircleServer... servers);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(List<CircleServer> servers);

    @Delete
    void delete(CircleServer server);

    @Query("DELETE FROM circle_server")
    void deleteAll();

    @Query("DELETE FROM circle_server WHERE serverId=:id")
    int deleteByServerId(String id);

    @Update
    void updateCircleServer(CircleServer server);

    @Query("SELECT * FROM circle_server")
    List<CircleServer> getAllServers();

    @Query("SELECT * FROM circle_server")
    LiveData<List<CircleServer>> getAllServersLiveData();

    @Query("SELECT * FROM circle_server WHERE isJoined = 1 ")//bool值使用0、1代表
    LiveData<List<CircleServer>> getJoinedServersLiveData();

    @Query("SELECT * FROM circle_server WHERE isRecommand = 1")
    LiveData<List<CircleServer>> getRecommandServersLiveData();

    @Query("SELECT * FROM circle_server WHERE serverId = :id")
    CircleServer getServerById(String id);

    @Query("SELECT * FROM circle_server WHERE serverId = :id")
    LiveData<CircleServer> getServerByIdLiveData(String id);

}
