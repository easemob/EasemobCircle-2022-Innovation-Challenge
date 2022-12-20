package io.agora.service.db;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import io.agora.service.db.converter.FormatConverter;
import io.agora.service.db.dao.CircleChannelDao;
import io.agora.service.db.dao.CircleServerDao;
import io.agora.service.db.dao.CircleUserDao;
import io.agora.service.db.entity.CircleChannel;
import io.agora.service.db.entity.CircleServer;
import io.agora.service.db.entity.CircleUser;


@Database(entities = {CircleServer.class, CircleChannel.class,CircleUser.class},
        version = 1)
@TypeConverters(FormatConverter.class)
public abstract class AppDatabase extends RoomDatabase {

    public abstract CircleUserDao userDao();

    public abstract CircleServerDao serverDao();

    public abstract CircleChannelDao channelDao();
}
