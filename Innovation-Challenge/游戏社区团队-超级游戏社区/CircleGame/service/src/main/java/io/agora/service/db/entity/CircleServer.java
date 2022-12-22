package io.agora.service.db.entity;


import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.PrimaryKey;
import androidx.room.TypeConverters;

import com.hyphenate.chat.EMCircleServer;
import com.hyphenate.chat.EMCircleTag;
import com.hyphenate.chat.adapter.EMACircleServer;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import io.agora.service.db.converter.CircleChannelConverter;
import io.agora.service.db.converter.TagConverter;

@Keep
@Entity(tableName = "circle_server")
@TypeConverters({TagConverter.class, CircleChannelConverter.class})
public class CircleServer implements Parcelable, Serializable {

    @PrimaryKey
    @NonNull
    public String serverId;
    public String defaultChannelID;
    public String name;
    public String icon;
    public String desc;
    public String custom;
    public String owner;
    public List<Tag> tags;
    //以下为demo层扩展的属性
    public List<CircleChannel> channels;
    public List<String> modetators;
    public boolean isRecommand;
    public boolean isJoined;

    @Ignore
    protected CircleServer(Parcel in) {
        serverId = in.readString();
        defaultChannelID = in.readString();
        name = in.readString();
        icon = in.readString();
        desc = in.readString();
        custom = in.readString();
        owner = in.readString();
        tags = in.createTypedArrayList(Tag.CREATOR);
        channels = in.createTypedArrayList(CircleChannel.CREATOR);
        modetators = in.createStringArrayList();
        isRecommand = in.readByte() != 0;
        isJoined = in.readByte() != 0;
    }

    public static final Creator<CircleServer> CREATOR = new Creator<CircleServer>() {
        @Override
        public CircleServer createFromParcel(Parcel in) {
            return new CircleServer(in);
        }

        @Override
        public CircleServer[] newArray(int size) {
            return new CircleServer[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(serverId);
        dest.writeString(defaultChannelID);
        dest.writeString(name);
        dest.writeString(icon);
        dest.writeString(desc);
        dest.writeString(custom);
        dest.writeString(owner);
        dest.writeTypedList(tags);
        dest.writeTypedList(channels);
        dest.writeStringList(modetators);
        dest.writeByte((byte) (isRecommand ? 1 : 0));
        dest.writeByte((byte) (isJoined ? 1 : 0));
    }


    @Keep
    @Entity
    public static class Tag implements Serializable, Parcelable {
        @PrimaryKey
        @NonNull
        public String id;
        public String name;
        public String serverId;

        public Tag(String id, String name, String serverId) {
            this.id = id;
            this.name = name;
            this.serverId = serverId;
        }

        @Ignore
        public Tag(EMCircleTag tag) {
            this.id = tag.getId();
            this.name = tag.getName();
        }

        @Ignore
        public static List<Tag> EMTagsConvertToTags(List<EMCircleTag> emTags) {
            List<Tag> tags = new ArrayList<>();
            if (emTags != null) {
                for (EMCircleTag emTag : emTags) {
                    tags.add(new Tag(emTag));
                }
            }
            return tags;
        }

        @Ignore
        protected Tag(Parcel in) {
            id = in.readString();
            name = in.readString();
            serverId = in.readString();
        }

        public static final Creator<Tag> CREATOR = new Creator<Tag>() {
            @Override
            public Tag createFromParcel(Parcel in) {
                return new Tag(in);
            }

            @Override
            public Tag[] newArray(int size) {
                return new Tag[size];
            }
        };

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(id);
            dest.writeString(name);
            dest.writeString(serverId);
        }
    }

    @Ignore
    public CircleServer() {
    }

    public CircleServer(@NonNull String serverId, String defaultChannelID, String name, String icon, String desc, String custom, String owner, List<Tag> tags, List<CircleChannel> channels, List<String> modetators, boolean isRecommand, boolean isJoined) {
        this.serverId = serverId;
        this.defaultChannelID = defaultChannelID;
        this.name = name;
        this.icon = icon;
        this.desc = desc;
        this.custom = custom;
        this.owner = owner;
        this.tags = tags;
        this.channels = channels;
        this.modetators = modetators;
        this.isRecommand = isRecommand;
        this.isJoined = isJoined;
    }

    @Ignore
    public CircleServer(EMCircleServer emCircleServer) {
        this.serverId = emCircleServer.getServerId();
        this.name = emCircleServer.getName();
        this.defaultChannelID = emCircleServer.getDefaultChannelID();
        this.icon = emCircleServer.getIcon();
        this.desc = emCircleServer.getDesc();
        this.custom = emCircleServer.getExt();
        this.owner = emCircleServer.getOwner();
        List<EMCircleTag> tags = emCircleServer.getTags();
        List<Tag> tagList = new ArrayList<>();
        if (tags != null) {
            for (int i = 0; i < tags.size(); i++) {
                tagList.add(new Tag(tags.get(i).getId(), tags.get(i).getName(), serverId));
            }
        }
        this.tags = tagList;

    }

    @Ignore
    public static List<EMCircleServer> converToEMCirlceServerList(List<CircleServer> input) {
        if (input == null || input.isEmpty()) {
            return null;
        }
        List<EMCircleServer> output = new ArrayList<>();
        ArrayList<String> tagList = new ArrayList<>();
        for (CircleServer circleServer : input) {
            EMCircleServer emCircleServer = new EMCircleServer(new EMACircleServer());
            emCircleServer.setServerId(circleServer.serverId);
            emCircleServer.setName(circleServer.name);
            emCircleServer.setIcon(circleServer.icon);
            emCircleServer.setDesc(circleServer.desc);
            emCircleServer.setExt(circleServer.custom);
            emCircleServer.setOwner(circleServer.owner);
            tagList.clear();
            for (int i = 0; i < circleServer.tags.size(); i++) {
                Tag tag = circleServer.tags.get(i);
                tagList.add(tag.name);
            }
            emCircleServer.setTags(tagList);
            output.add(emCircleServer);
        }
        return output;
    }

    @Ignore
    public static List<CircleServer> converToCirlceServerList(List<EMCircleServer> input) {
        if (input == null) {
            return null;
        }
        List<CircleServer> output = new ArrayList<>();
        for (EMCircleServer emCircleServer : input) {
            CircleServer circleServer = new CircleServer(emCircleServer);
            output.add(circleServer);
        }
        return output;
    }
}
