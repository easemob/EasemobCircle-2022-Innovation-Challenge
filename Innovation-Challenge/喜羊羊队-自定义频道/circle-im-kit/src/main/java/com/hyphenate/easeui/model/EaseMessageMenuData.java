package com.hyphenate.easeui.model;

import static com.hyphenate.easeui.model.EaseDefaultEmojiconDatas.emojis;

import com.hyphenate.easeui.R;
import com.hyphenate.easeui.domain.EaseEmojicon;

import java.util.HashMap;
import java.util.Map;


public class EaseMessageMenuData {

    private static final int[] REACTION_ICONS = new int[]{
            R.drawable.ee_1,
            R.drawable.ee_2,
            R.drawable.ee_3,
            R.drawable.ee_4,
            R.drawable.ee_5,
            R.drawable.ee_6,
            R.drawable.ee_7,
            R.drawable.ee_8,
            R.drawable.ee_9,
            R.drawable.ee_10,
            R.drawable.ee_11,
            R.drawable.ee_12,
            R.drawable.ee_13,
            R.drawable.ee_14,
            R.drawable.ee_15,
            R.drawable.ee_16,
            R.drawable.ee_17,
            R.drawable.ee_18,
            R.drawable.ee_19,
            R.drawable.ee_20,
            R.drawable.ee_21,
            R.drawable.ee_22,
            R.drawable.ee_23,
            R.drawable.ee_24,
            R.drawable.ee_25,
            R.drawable.ee_26,
            R.drawable.ee_27,
            R.drawable.ee_28,
            R.drawable.ee_29,
            R.drawable.ee_30,
            R.drawable.ee_31,
            R.drawable.ee_32,
            R.drawable.ee_33,
            R.drawable.ee_34,
            R.drawable.ee_35,
            R.drawable.ee_36,
            R.drawable.ee_37,
            R.drawable.ee_38,
            R.drawable.ee_39,
            R.drawable.ee_40,
            R.drawable.ee_41,
            R.drawable.ee_42,
            R.drawable.ee_43,
            R.drawable.ee_44,
            R.drawable.ee_45,
            R.drawable.ee_46,
            R.drawable.ee_47
    };
    public static String[] REACTION_FREQUENTLY_ICONS_IDS = new String[]{
            emojis[40],
            emojis[43],
            emojis[37],
            emojis[36],
            emojis[15],
            emojis[10]
    };

    public static final int[] MENU_ITEM_IDS = {R.id.action_chat_copy,R.id.action_chat_thread,R.id.action_chat_reply,  R.id.action_chat_delete, R.id.action_chat_recall};
    public static final int[] MENU_TITLES = {R.string.ease_action_copy,R.string.ease_action_thread,R.string.ease_action_reply,  R.string.ease_action_delete, R.string.ease_action_recall};
    public static final int[] MENU_ICONS = {R.drawable.ease_menu_copy,R.drawable.ease_menu_thread,R.drawable.ease_chat_item_menu_reply,  R.drawable.ease_chat_item_menu_delete, R.drawable.ease_menu_recall};


    public static final String EMOTICON_MORE_IDENTITY_CODE = "emoji_more";

    private static final EaseEmojicon REACTION_MORE = createMoreEmoticon();

    private static EaseEmojicon createMoreEmoticon() {
        EaseEmojicon data = new EaseEmojicon();
        data.setIdentityCode(EMOTICON_MORE_IDENTITY_CODE);
        data.setIcon(R.drawable.ee_reaction_more);
        return data;
    }

    public static EaseEmojicon getReactionMore() {
        return REACTION_MORE;
    }

    private static final Map<String, EaseEmojicon> REACTION_DATA_MAP = createReactionDataMap();

    private static Map<String, EaseEmojicon> createReactionDataMap() {
        Map<String, EaseEmojicon> emojiconsMap = new HashMap<>(REACTION_ICONS.length);
        EaseEmojicon emojicon;
        String id;
        for (int i = 0; i < REACTION_ICONS.length; i++) {
            emojicon = new EaseEmojicon(REACTION_ICONS[i], "", EaseEmojicon.Type.NORMAL);
            id = emojis[i];
            emojicon.setIdentityCode(id);
            emojiconsMap.put(id, emojicon);
        }
        return emojiconsMap;
    }

    public static Map<String, EaseEmojicon> getReactionDataMap() {
        return REACTION_DATA_MAP;
    }


}
