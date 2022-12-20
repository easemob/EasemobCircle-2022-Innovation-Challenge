package io.agora.service.db.entity;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.PrimaryKey;
import androidx.room.TypeConverters;

import com.hyphenate.chat.EMCircleChannel;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import io.agora.service.db.converter.CircleUserConverter;

@Keep
@Entity(tableName = "circle_channel")
@TypeConverters({CircleUserConverter.class})
public class CircleChannel implements Serializable, Parcelable {

    @PrimaryKey
    @NonNull
    public String channelId;
    public String serverId;
    public String name;
    public String desc;
    public String custom;
    public int inviteMode;
    public boolean isDefault;
    public int type;
    public List<CircleUser> channelUsers;
    public List<String> modetators;//目前暂时与server的一致

    public CircleChannel(@NonNull String channelId, String serverId, String name, String desc, String custom, int inviteMode, boolean isDefault, int type, List<CircleUser> channelUsers, List<String> modetators) {
        this.channelId = channelId;
        this.serverId = serverId;
        this.name = name;
        this.desc = desc;
        this.custom = custom;
        this.inviteMode = inviteMode;
        this.isDefault = isDefault;
        this.type = type;
        this.channelUsers = channelUsers;
        this.modetators = modetators;
    }

    @Ignore
    public CircleChannel(String serverlId, String channelId) {
        this.serverId = serverlId;
        this.channelId = channelId;
    }

    @Ignore
    public CircleChannel(EMCircleChannel emCircleChannel) {
        this.serverId = emCircleChannel.getServerlId();
        this.channelId = emCircleChannel.getChannelId();
        this.name = emCircleChannel.getName();
        this.desc = emCircleChannel.getDesc();
        this.custom = emCircleChannel.getExt();
        this.inviteMode = emCircleChannel.getInviteMode().getCode();
        this.isDefault = emCircleChannel.isDefault();
        this.type = emCircleChannel.getType().getCode();
    }

    @Ignore
    protected CircleChannel(Parcel in) {
        channelId = in.readString();
        serverId = in.readString();
        name = in.readString();
        desc = in.readString();
        custom = in.readString();
        inviteMode = in.readInt();
        isDefault = in.readByte() != 0;
        type = in.readInt();
        channelUsers = in.createTypedArrayList(CircleUser.CREATOR);
        modetators = in.createStringArrayList();
    }

    public static final Creator<CircleChannel> CREATOR = new Creator<CircleChannel>() {
        @Override
        public CircleChannel createFromParcel(Parcel in) {
            return new CircleChannel(in);
        }

        @Override
        public CircleChannel[] newArray(int size) {
            return new CircleChannel[size];
        }
    };

    public static List<CircleChannel> converToCirlceChannelList(List<EMCircleChannel> input) {
        if (input == null || input.isEmpty()) {
            return null;
        }
        List<CircleChannel> output = new ArrayList<>();
        for (EMCircleChannel emCircleChannel : input) {
            CircleChannel circleChannel = new CircleChannel(emCircleChannel);
            output.add(circleChannel);
        }
        return output;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(channelId);
        dest.writeString(serverId);
        dest.writeString(name);
        dest.writeString(desc);
        dest.writeString(custom);
        dest.writeInt(inviteMode);
        dest.writeByte((byte) (isDefault ? 1 : 0));
        dest.writeInt(type);
        dest.writeTypedList(channelUsers);
        dest.writeStringList(modetators);
    }
}
