package io.agora.service.db.converter;


import androidx.annotation.Keep;
import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import io.agora.service.db.entity.CircleChannel;
@Keep
public class CircleChannelConverter {

    @TypeConverter
    public String objectToString(List<CircleChannel> list) {
        return new Gson().toJson(list);
    }

    @TypeConverter
    public List<CircleChannel> stringToObject(String json) {
        Type listType = new TypeToken<List<CircleChannel>>() {
        }.getType();
        return new Gson().fromJson(json, listType);
    }
}
