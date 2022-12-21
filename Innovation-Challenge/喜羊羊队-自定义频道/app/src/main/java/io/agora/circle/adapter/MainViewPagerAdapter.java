package io.agora.circle.adapter;


import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import java.util.List;

import io.agora.common.base.BaseFragment;

public class MainViewPagerAdapter extends FragmentStateAdapter {
   private final List<BaseFragment> fragments;

   public MainViewPagerAdapter(@NonNull FragmentActivity fragmentActivity, List<BaseFragment> fragments) {
      super(fragmentActivity);
      this.fragments=fragments;
   }

   @NonNull
   @Override
   public Fragment createFragment(int position) {
      return fragments.get(position);
   }

   @Override
   public int getItemCount() {
      return fragments.size();
   }
}
