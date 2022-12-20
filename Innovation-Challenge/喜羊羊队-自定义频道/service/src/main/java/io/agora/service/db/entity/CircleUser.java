package io.agora.service.db.entity;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.Index;

import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.easeui.domain.EaseUser;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.agora.service.managers.AppUserInfoManager;


@Keep
@Entity(tableName = "circle_user", primaryKeys = {"username"},
        indices = {@Index(value = {"username"}, unique = true)})
public class CircleUser implements Serializable, Parcelable {
    public int roleID;
    public int inviteState;//0 :没有状态 1：邀请中
    public boolean isMuted;//是否处于被禁言状态
    @NonNull
    public String username;
    public String nickname="";
    /**
     * initial letter from nickname
     */
    public String initialLetter="";
    /**
     * user's avatar
     */
    public String avatar;

    /**
     * contact 0: normal, 1: black ,3: no friend
     */
    public int contact;

    /**
     * the timestamp when last modify
     */
    public long lastModifyTimestamp;

    /**
     * the timestamp when set initialLetter
     */
    public long modifyInitialLetterTimestamp;

    /**
     * user's email;
     */
    public String email;

    /**
     * user's phone;
     */
    public String phone;

    /**
     * user's gender;
     */
    public int gender;

    /**
     * user's birth;
     */
    public String sign;

    /**
     * user's birth;
     */
    public String birth;

    /**
     * user's ext;
     */
    public String ext;

    @Ignore
    public CircleUser() {
    }

    public CircleUser(int roleID, int inviteState, boolean isMuted, String username, String nickname, String initialLetter, String avatar, int contact, long lastModifyTimestamp, long modifyInitialLetterTimestamp, String email, String phone, int gender, String sign, String birth, String ext) {
        this.roleID = roleID;
        this.inviteState = inviteState;
        this.isMuted = isMuted;
        this.username = username;
        this.nickname = nickname;
        this.initialLetter = initialLetter;
        this.avatar = avatar;
        this.contact = contact;
        this.lastModifyTimestamp = lastModifyTimestamp;
        this.modifyInitialLetterTimestamp = modifyInitialLetterTimestamp;
        this.email = email;
        this.phone = phone;
        this.gender = gender;
        this.sign = sign;
        this.birth = birth;
        this.ext = ext;
    }

    @Ignore
    public CircleUser(String username) {
        this.username = username;
    }

    protected CircleUser(Parcel in) {
        roleID = in.readInt();
        inviteState = in.readInt();
        isMuted = in.readByte() != 0;
        username = in.readString();
        nickname = in.readString();
        initialLetter = in.readString();
        avatar = in.readString();
        contact = in.readInt();
        lastModifyTimestamp = in.readLong();
        modifyInitialLetterTimestamp = in.readLong();
        email = in.readString();
        phone = in.readString();
        gender = in.readInt();
        sign = in.readString();
        birth = in.readString();
        ext = in.readString();
    }

    public static final Creator<CircleUser> CREATOR = new Creator<CircleUser>() {
        @Override
        public CircleUser createFromParcel(Parcel in) {
            return new CircleUser(in);
        }

        @Override
        public CircleUser[] newArray(int size) {
            return new CircleUser[size];
        }
    };

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public int getInviteState() {
        return inviteState;
    }

    public void setInviteState(int inviteState) {
        this.inviteState = inviteState;
    }

    public boolean isMuted() {
        return isMuted;
    }

    public void setMuted(boolean muted) {
        isMuted = muted;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getInitialLetter() {
        return initialLetter;
    }

    public void setInitialLetter(String initialLetter) {
        this.initialLetter = initialLetter;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public int getContact() {
        return contact;
    }

    public void setContact(int contact) {
        this.contact = contact;
    }

    public long getLastModifyTimestamp() {
        return lastModifyTimestamp;
    }

    public void setLastModifyTimestamp(long lastModifyTimestamp) {
        this.lastModifyTimestamp = lastModifyTimestamp;
    }

    public long getModifyInitialLetterTimestamp() {
        return modifyInitialLetterTimestamp;
    }

    public void setModifyInitialLetterTimestamp(long modifyInitialLetterTimestamp) {
        this.modifyInitialLetterTimestamp = modifyInitialLetterTimestamp;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getGender() {
        return gender;
    }

    public void setGender(int gender) {
        this.gender = gender;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public String getBirth() {
        return birth;
    }

    public void setBirth(String birth) {
        this.birth = birth;
    }

    public String getExt() {
        return ext;
    }

    public void setExt(String ext) {
        this.ext = ext;
    }

    @Ignore
    public static List<CircleUser> parseListEaseUsers(List<EaseUser> users) {
        List<CircleUser> entities = new ArrayList<>();
        if (users == null || users.isEmpty()) {
            return entities;
        }
        CircleUser entity;
        for (EaseUser user : users) {
            entity = parseParent(user);
            entities.add(entity);
        }
        return entities;
    }

    @Ignore
    public static CircleUser parseParent(EaseUser user) {
        CircleUser circleUser = new CircleUser();
        circleUser.setUsername(user.getUsername());
        circleUser.setNickname(user.getNickname());
        circleUser.setAvatar(user.getAvatar());
        circleUser.setInitialLetter(user.getInitialLetter());
        circleUser.setContact(user.getContact());
        circleUser.setEmail(user.getEmail());
        circleUser.setGender(user.getGender());
        circleUser.setBirth(user.getBirth());
        circleUser.setPhone(user.getPhone());
        circleUser.setSign(user.getSign());
        circleUser.setExt(user.getExt());
        return circleUser;
    }

    @Ignore
    public static List<CircleUser> parseListIds(List<String> ids) {
        List<CircleUser> users = new ArrayList<>();
        if (ids == null || ids.isEmpty()) {
            return users;
        }
        for (String id : ids) {
            CircleUser user = AppUserInfoManager.getInstance().getUserInfobyId(id);
            if (user != null) {
                users.add(user);
            }
        }
        return users;
    }

    @Ignore
    public static List<CircleUser> parseStringIds(String[] ids) {
        List<CircleUser> users = new ArrayList<>();
        if (ids == null || ids.length == 0) {
            return users;
        }
        for (String id : ids) {
            CircleUser user = AppUserInfoManager.getInstance().getUserInfobyId(id);
            if (user != null) {
                users.add(user);
            }
        }
        return users;
    }

    @Ignore
    public static List<CircleUser> parseEMUserInfos(Map<String, EMUserInfo> userInfos) {
        List<CircleUser> users = new ArrayList<>();
        if (userInfos == null || userInfos.isEmpty()) {
            return users;
        }
        CircleUser user;
        Set<String> userSet = userInfos.keySet();
        Iterator<String> it = userSet.iterator();
        while (it.hasNext()) {
            String userId = it.next();
            EMUserInfo info = userInfos.get(userId);
            user = new CircleUser();
            user.username = info.getUserId();
            user.setNickname(info.getNickName());
            user.setAvatar(info.getAvatarUrl());
            user.setEmail(info.getEmail());
            user.setGender(info.getGender());
            user.setBirth(info.getBirth());
            user.setSign(info.getSignature());
            user.setExt(info.getExt());
            users.add(user);
        }
        return users;
    }

    @Ignore
    public static CircleUser parseEMUserInfo(EMUserInfo info) {
        if (info == null) {
            return null;
        }
        CircleUser user;
        user = new CircleUser();
        user.setUsername(info.getUserId());
        user.setNickname(info.getNickName());
        user.setAvatar(info.getAvatarUrl());
        user.setEmail(info.getEmail());
        user.setGender(info.getGender());
        user.setBirth(info.getBirth());
        user.setSign(info.getSignature());
        user.setExt(info.getExt());
        return user;
    }

    public String getVisiableName() {
        return TextUtils.isEmpty(getNickname()) ? getUsername() : getNickname();
    }

    public static EaseUser convertoEaseUser(CircleUser circleUser) {
        EaseUser easeUser = new EaseUser();
        if (circleUser != null) {
            easeUser.setUsername(circleUser.getUsername());
            easeUser.setNickname(circleUser.getNickname());
            easeUser.setAvatar(circleUser.getAvatar());
            easeUser.setInitialLetter(circleUser.getInitialLetter());
            easeUser.setContact(circleUser.getContact());
            easeUser.setEmail(circleUser.getEmail());
            easeUser.setGender(circleUser.getGender());
            easeUser.setBirth(circleUser.getBirth());
            easeUser.setPhone(circleUser.getPhone());
            easeUser.setSign(circleUser.getSign());
            easeUser.setExt(circleUser.getExt());
        }
        return easeUser;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(roleID);
        dest.writeInt(inviteState);
        dest.writeByte((byte) (isMuted ? 1 : 0));
        dest.writeString(username);
        dest.writeString(nickname);
        dest.writeString(initialLetter);
        dest.writeString(avatar);
        dest.writeInt(contact);
        dest.writeLong(lastModifyTimestamp);
        dest.writeLong(modifyInitialLetterTimestamp);
        dest.writeString(email);
        dest.writeString(phone);
        dest.writeInt(gender);
        dest.writeString(sign);
        dest.writeString(birth);
        dest.writeString(ext);
    }
}
