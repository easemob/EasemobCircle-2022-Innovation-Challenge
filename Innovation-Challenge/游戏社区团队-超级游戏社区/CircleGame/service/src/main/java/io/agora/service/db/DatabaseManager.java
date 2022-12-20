package io.agora.service.db;

import android.content.Context;
import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.room.Room;

import com.hyphenate.util.EMLog;

import io.agora.common.utils.MD5;
import io.agora.service.db.dao.CircleChannelDao;
import io.agora.service.db.dao.CircleServerDao;
import io.agora.service.db.dao.CircleUserDao;


public class DatabaseManager {
    private final String TAG = getClass().getSimpleName();
    private static DatabaseManager instance;
    private Context mContext;
    private String currentUser;
    private AppDatabase mDatabase;
    private final MutableLiveData<Boolean> mIsDatabaseCreated = new MutableLiveData<>();

    private DatabaseManager(){
    }

    public static DatabaseManager getInstance() {
        if(instance == null) {
            synchronized (DatabaseManager.class) {
                if(instance == null) {
                    instance = new DatabaseManager();
                }
            }
        }
        return instance;
    }
    public void init(Context context){
        mContext=context.getApplicationContext();
    }

    /**
     * Initialize the database
     * @param user
     */
    public void initDB(String user) {
        if(currentUser != null) {
            if(TextUtils.equals(currentUser, user)) {
                EMLog.i(TAG, "you have opened the db");
                return;
            }
            closeDb();
        }
        this.currentUser = user;
        String userMd5 = MD5.encrypt2MD5(user);
        // The following database upgrade settings, in order to upgrade the database will clear the previous data,
        // if you want to keep the data, use this method carefully
        // You can use addMigrations() to upgrade the database
        String dbName = String.format("em_%1$s.db", userMd5);
        EMLog.i(TAG, "db name = "+dbName);
        mDatabase = Room.databaseBuilder(mContext, AppDatabase.class, dbName)
                        .allowMainThreadQueries()
                        .fallbackToDestructiveMigration()
                        .build();
        mIsDatabaseCreated.postValue(true);
    }

    public LiveData<Boolean> getDatabaseCreatedObservable() {
        return mIsDatabaseCreated;
    }

    /**
     * Close database
     */
    public void closeDb() {
        if(mDatabase != null) {
            mDatabase.close();
            mDatabase = null;
        }
        currentUser = null;
    }

    public CircleUserDao getUserDao() {
        if(mDatabase != null) {
            return mDatabase.userDao();
        }
        EMLog.i(TAG, "get userDao failed, should init db first");
        return null;
    }

    public CircleServerDao getServerDao() {
        if(mDatabase != null) {
            return mDatabase.serverDao();
        }
        EMLog.i(TAG, "get getServerDao failed, should init db first");
        return null;
    }
    public CircleChannelDao getChannelDao() {
        if(mDatabase != null) {
            return mDatabase.channelDao();
        }
        EMLog.i(TAG, "get getChannelDao failed, should init db first");
        return null;
    }

}
