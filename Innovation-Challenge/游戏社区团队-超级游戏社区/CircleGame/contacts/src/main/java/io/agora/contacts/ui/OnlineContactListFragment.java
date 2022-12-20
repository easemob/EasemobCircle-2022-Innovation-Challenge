package io.agora.contacts.ui;


import com.hyphenate.chat.EMPresence;

import java.util.List;

import io.agora.service.bean.PresenceData;
import io.agora.service.db.entity.CircleUser;
import io.agora.service.managers.AppUserInfoManager;
import io.agora.service.utils.EasePresenceUtil;

public class OnlineContactListFragment extends ContactListFragment {

    protected void setData(List<CircleUser> datas) {
        filterDatasForOnline(datas);
        mListAdapter.setData(datas);
    }

    private void filterDatasForOnline(List<CircleUser> datas) {
        if (datas == null) {
            return;
        }
        for (int i = 0; i < datas.size(); i++) {
            CircleUser circleUser = datas.get(i);
            EMPresence presence = AppUserInfoManager.getInstance().getPresences().get(circleUser.getUsername());
            if (!EasePresenceUtil.getPresenceString(mContext, presence)
                    .equals(getString(PresenceData.ONLINE.getPresence()))) {
                datas.remove(circleUser);
                i--;
            }
        }
    }
}
