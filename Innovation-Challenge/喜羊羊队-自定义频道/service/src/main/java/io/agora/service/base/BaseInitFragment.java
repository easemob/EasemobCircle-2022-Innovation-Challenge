package io.agora.service.base;


import androidx.annotation.NonNull;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.FragmentTransaction;

import io.agora.common.base.BaseFragment;
import io.agora.service.callbacks.OnResourceParseCallback;
import io.agora.service.net.Resource;

//预留扩展类
public abstract class BaseInitFragment<T extends ViewDataBinding> extends BaseFragment<T> {
    private BaseFragment mCurrentFragment;

    protected void replace(BaseFragment fragment, int containerId, String tag) {
        if (mCurrentFragment != fragment) {
            FragmentTransaction t = getChildFragmentManager().beginTransaction();
            if (mCurrentFragment != null) {
                t.hide(mCurrentFragment);
            }
            mCurrentFragment = fragment;
            if (!fragment.isAdded()) {
                t.add(containerId, fragment, tag).show(fragment).commit();
            } else {
                t.show(fragment).commit();
            }
        }
    }

    public <T> void parseResource(Resource<T> response, @NonNull OnResourceParseCallback<T> callback) {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity)mContext).parseResource(response, callback);
        }
    }

    public void showLoading() {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity)mContext).showLoading();
        }

    }

    public void showLoading(String message) {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity)mContext).showLoading(message);
        }
    }

    public void dismissLoading() {
        if(mContext != null&&mContext instanceof BaseInitActivity) {
            ((BaseInitActivity)mContext).dismissLoading();
        }
    }
}
