package io.agora.service.db.converter;


import androidx.annotation.Keep;
import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import io.agora.service.db.entity.CircleUser;
@Keep
public class CircleUserConverter {

    @TypeConverter
    public String objectToString(List<CircleUser> list) {
        return new Gson().toJson(list);
    }

    @TypeConverter
    public List<CircleUser> stringToObject(String json) {
        Type listType = new TypeToken<List<CircleUser>>() {
        }.getType();
        return new Gson().fromJson(json, listType);
    }
}
