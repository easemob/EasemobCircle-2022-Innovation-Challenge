package io.agora.service.db.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

import io.agora.service.db.entity.CircleChannel;

@Dao
public interface CircleChannelDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(CircleChannel... channels);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    List<Long> insert(List<CircleChannel> channels);

    @Delete
    void delete(CircleChannel channel);

    @Query("DELETE FROM circle_channel WHERE channelId=:id")
    int deleteByChannelId(String id);

    @Update
    void updateChannel(CircleChannel channel);

    @Query("SELECT * FROM circle_channel")
    List<CircleChannel> getAllChannels();

    @Query("SELECT * FROM circle_channel WHERE channelId = :id")
    CircleChannel getChannelByChannelID(String id);

    @Query("SELECT * FROM circle_channel WHERE serverId = :serverID")
    LiveData<List<CircleChannel>> getChannelsByChannelServerID(String serverID);

    @Query("SELECT * FROM circle_channel WHERE serverId = :serverID and type = 0")
    LiveData<List<CircleChannel>> getPublicChannelsByChannelServerID(String serverID);

    @Query("SELECT * FROM circle_channel WHERE serverId = :serverID and type = 1")
    LiveData<List<CircleChannel>> getPrivateChannelsByChannelServerID(String serverID);

    @Query("DELETE  FROM circle_channel WHERE serverId = :serverID and type = 0 ")
    void deleteAllPublicChannelsByServerID(String serverID);

    @Query("DELETE  FROM circle_channel WHERE serverId = :serverID and type = 1 ")
    void deleteAllPrivateChannelsByServerID(String serverID);

    @Query("DELETE  FROM circle_channel WHERE serverId = :serverID ")
    void deleteChannelsByServerID(String serverID);
}
