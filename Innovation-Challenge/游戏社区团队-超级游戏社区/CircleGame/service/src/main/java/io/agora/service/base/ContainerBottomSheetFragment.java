package io.agora.service.base;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

import com.hyphenate.easeui.widget.EaseTitleBar;

import java.util.Stack;

import io.agora.service.R;
import io.agora.service.callbacks.BottomSheetChildHelper;
import io.agora.service.callbacks.BottomSheetContainerHelper;
import io.agora.service.databinding.FragmentContainerBinding;


/**
 * 底部弹框fragment的进一步实现，包括对弹窗中标题栏的管理和内部子fragment的切换逻辑封装
 */
public abstract class ContainerBottomSheetFragment extends BaseBottomSheetFragment implements BottomSheetContainerHelper {
    protected FragmentContainerBinding baseBinding;
    protected BottomSheetChildHelper currentChild;

    public FragmentContainerBinding getBaseBinding() {
        return baseBinding;
    }

    protected Stack<BottomSheetChildHelper> childStack = new Stack<>();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        baseBinding = FragmentContainerBinding.inflate(inflater);
        return baseBinding.getRoot();
    }

    @Override
    public void startFragment(@NonNull Fragment fragment, @Nullable String tag) {
        if (!(fragment instanceof BottomSheetChildHelper)) {
            throw new IllegalArgumentException("only ButtomSheetChildFragment can be started here ");
        }
        if (TextUtils.isEmpty(tag)) {
            tag = fragment.getClass().getSimpleName();
        }
        getChildFragmentManager()
                .beginTransaction()
                .replace(R.id.fl_container, fragment, tag)
                .addToBackStack(null)
                .commit();
        childStack.add((BottomSheetChildHelper) fragment);
        currentChild = (BottomSheetChildHelper) fragment;
        fragment.getLifecycle().addObserver(new LifecycleEventObserver() {
            @Override
            public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
                if(event== Lifecycle.Event.ON_START) {
                    initTileBar();
                }
            }
        });
    }

    private void initTileBar() {
        if (!showTitle()||!isAdded()) {
            return;
        }
        baseBinding.titlebar.setRightLayoutVisibility(View.VISIBLE);
        baseBinding.titlebar.getRightText().setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        baseBinding.titlebar.getTitle().setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        baseBinding.titlebar.setOnBackPressListener(new EaseTitleBar.OnBackPressListener() {
            @Override
            public void onBackPress(View view) {
                back();
            }
        });

        if (currentChild != null&&((Fragment)currentChild).isAdded()) {
            baseBinding.titlebar.getTitle().setText(getString(R.string.group_create_title));
            baseBinding.titlebar.getRightText().setText(R.string.circle_save);
            baseBinding.titlebar.getRightText().setVisibility(View.GONE);
            baseBinding.titlebar.getRightText().setTextColor(ContextCompat.getColor(requireContext(), R.color.gray_979797));
            baseBinding.titlebar.setLeftImageResource(R.drawable.back_arrow_bold);
            baseBinding.titlebar.setLeftLayoutVisibility(View.GONE);
            currentChild.onContainerTitleBarInitialize(baseBinding.titlebar);
        }
    }

    @Override
    protected void initView() {
        super.initView();
        // set child fragment
        Fragment childFragment = getChildFragment();
        startFragment(childFragment, childFragment.getClass().getSimpleName());
    }

    @Override
    public void onStart() {
        super.onStart();
        initTileBar();
    }

    @Override
    protected void initListener() {
        super.initListener();
    }

    public void back() {
        if (getChildFragmentManager().getBackStackEntryCount() > 1) {
            getChildFragmentManager().popBackStack();
            childStack.pop();
            currentChild = childStack.peek();
            initTileBar();
        } else {
            hide();
        }
    }

    /**
     * Provider child fragment, should not be null.
     *
     * @return
     */
    protected abstract @NonNull
    Fragment getChildFragment();

    /**
     * Whether to show titleBar
     *
     * @return
     */
    protected boolean showTitle() {
        return true;
    }
}
