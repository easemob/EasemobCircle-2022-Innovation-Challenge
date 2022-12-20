package io.agora.contacts.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import com.blankj.utilcode.util.ConvertUtils;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.easeui.widget.EaseTitleBar;
import com.jeremyliao.liveeventbus.LiveEventBus;

import java.util.ArrayList;
import java.util.List;

import io.agora.contacts.R;
import io.agora.contacts.databinding.FragmentContactsBinding;
import io.agora.contacts.model.ContactsViewModel;
import io.agora.contacts.notification.NotificationMsgFragment;
import io.agora.service.base.BaseInitFragment;
import io.agora.service.global.Constants;
import io.agora.service.utils.CircleUtils;

public class ContactsFragment extends BaseInitFragment<FragmentContactsBinding> implements EaseTitleBar.OnRightClickListener {

    private ContactsViewModel mViewModel;
    private int[] titles = {R.string.contacts_tab_online, R.string.contacts_tab_all, R.string.contact_tab_requests};
    private ArrayList<BaseInitFragment> fragments = new ArrayList();
    private View redDot;

    @Override
    protected int getResLayoutId() {
        return R.layout.fragment_contacts;
    }

    @Override
    protected void initConfig() {
        super.initConfig();
        mViewModel = new ViewModelProvider(this).get(ContactsViewModel.class);

        mViewModel.getConversationObservable().observe(getViewLifecycleOwner(), conversation -> {
            initRedDot(conversation);
        });

        initListener();
    }

    @Override
    protected void initView(Bundle savedInstanceState) {
        super.initView(savedInstanceState);
        mBinding.toolbarContact.setRightImageResource(io.agora.service.R.drawable.circle_invite);
        TextView leftTitle = mBinding.toolbarContact.getLeftTitle();
        leftTitle.setText(getString(R.string.contacts_myfriends));
        leftTitle.setTextColor(ContextCompat.getColor(mContext, R.color.white));
        leftTitle.setVisibility(View.VISIBLE);
    }


    @Override
    protected void initData() {
        super.initData();
        fragments.add(new OnlineContactListFragment());
        fragments.add(new ContactListFragment());
        fragments.add(new NotificationMsgFragment());
        setupWithViewPager();
        mViewModel.getMsgConversation();
    }


    private void setupWithViewPager() {
        mBinding.vpFragment.setOffscreenPageLimit(ViewPager2.OFFSCREEN_PAGE_LIMIT_DEFAULT);
        // set adapter
        mBinding.vpFragment.setAdapter(new FragmentStateAdapter(getChildFragmentManager(), getLifecycle()) {
            @NonNull
            @Override
            public Fragment createFragment(int position) {
                return fragments.get(position);
            }

            @Override
            public int getItemCount() {
                return titles.length;
            }
        });
        // set TabLayoutMediator
        TabLayoutMediator mediator = new TabLayoutMediator(mBinding.tabLayout, mBinding.vpFragment, new TabLayoutMediator.TabConfigurationStrategy() {
            @Override
            public void onConfigureTab(@NonNull TabLayout.Tab tab, int position) {
                tab.setCustomView(R.layout.layout_custom_tab_contact);
                TextView title = tab.getCustomView().findViewById(R.id.tv_tab_title);
                if (position == 0) {
                    title.setBackgroundResource(R.drawable.contact_tab_bg);
                } else if (position == 2) {
                    redDot = tab.getCustomView().findViewById(R.id.tv_tab_green);
                }
                title.setText(titles[position]);
            }
        });
        // setup with viewpager2
        mediator.attach();
    }

    public boolean isNofificationMsgFragmentVisiable() {
        boolean isParentVisiable = getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.RESUMED);
        return mBinding.tabLayout.getSelectedTabPosition() == 2 && isParentVisiable;
    }

    protected void initListener() {
        mBinding.toolbarContact.setOnRightClickListener(this);
        //new GroupContainerFragment().show(getChildFragmentManager(),"GroupContainerFragment");
        mBinding.tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                if (tab.getCustomView() != null) {
                    TextView title = tab.getCustomView().findViewById(R.id.tv_tab_title);
                    title.setBackgroundResource(R.drawable.contact_tab_bg);
                    ViewGroup.LayoutParams layoutParams = title.getLayoutParams();
                    layoutParams.height = ConvertUtils.dp2px(28);
                    title.setGravity(Gravity.CENTER);
                }
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {

            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });
        mBinding.vpFragment.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                mBinding.toolbarContact.setVisibility(View.VISIBLE);
            }
        });

//        LiveEventBus.get(Constants.USERINFO_CHANGE).observe(getViewLifecycleOwner(), this::loadData);
//        LiveEventBus.get(Constants.GROUP_CHANGE).observe(getViewLifecycleOwner(), this::loadData);
//        LiveEventBus.get(Constants.PRESENCES_CHANGED).observe(getViewLifecycleOwner(), this::loadData);
//        LiveEventBus.get(Constants.CHAT_ROOM_CHANGE).observe(getViewLifecycleOwner(), this::loadData);
        LiveEventBus.get(Constants.CONTACT_CHANGE).observe(getViewLifecycleOwner(), this::loadData);
        LiveEventBus.get(Constants.NOTIFY_CHANGE).observe(getViewLifecycleOwner(), this::loadData);

    }

    private void loadData(Object o) {
        mViewModel.getMsgConversation();
    }

    private void initRedDot(EMConversation conversation) {
        int visiable;
        List<EMMessage> inviteMessages = CircleUtils.filterInviteNotification(conversation.getAllMessages());
        int unreadMsgCount = conversation.getUnreadMsgCount();
        if (!isNofificationMsgFragmentVisiable() && unreadMsgCount > 0 && inviteMessages.size() > 0) {
            visiable = View.VISIBLE;
        } else {
            visiable = View.GONE;
        }
        redDot.setVisibility(visiable);
        LiveEventBus.get(Constants.SHOW_RED_DOT).post(visiable == View.VISIBLE);
    }

    @Override
    public void onRightClick(View view) {
        switch (mBinding.tabLayout.getSelectedTabPosition()) {
            case 0:
            case 1:
            case 2:
                //跳转到添加好友页面
                Intent intent = new Intent(mContext, AddFriendActivity.class);
                startActivity(intent);
                break;
        }
    }
}