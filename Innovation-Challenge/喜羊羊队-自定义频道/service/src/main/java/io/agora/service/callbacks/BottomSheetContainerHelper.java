package io.agora.service.callbacks;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

/**
 * 底部弹窗父容器的标准实现
 */
public interface BottomSheetContainerHelper {
    void startFragment(@NonNull Fragment fragment, @Nullable String tag);
    void hide();
    void back();
}
