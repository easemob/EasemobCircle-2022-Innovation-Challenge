package io.agora.service.db.converter;


import androidx.annotation.Keep;
import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import io.agora.service.db.entity.CircleServer;
@Keep
public class TagConverter {

    @TypeConverter
    public String objectToString(List<CircleServer.Tag> list) {
        return new Gson().toJson(list);
    }

    @TypeConverter
    public List<CircleServer.Tag> stringToObject(String json) {
        Type listType = new TypeToken<List<CircleServer.Tag>>(){}.getType();
        return new Gson().fromJson(json, listType);
    }
}
