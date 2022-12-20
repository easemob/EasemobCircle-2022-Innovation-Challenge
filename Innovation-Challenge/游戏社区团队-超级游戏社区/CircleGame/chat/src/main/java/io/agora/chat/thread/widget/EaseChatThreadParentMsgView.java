package io.agora.chat.thread.widget;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.databinding.DataBindingUtil;

import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.easeui.EaseIM;
import com.hyphenate.easeui.domain.EaseUser;
import com.hyphenate.easeui.interfaces.OnMessageItemClickListener;
import com.hyphenate.easeui.provider.EaseFileIconProvider;
import com.hyphenate.easeui.provider.EaseUserProfileProvider;
import com.hyphenate.easeui.ui.EaseShowBigImageActivity;
import com.hyphenate.easeui.ui.EaseShowNormalFileActivity;
import com.hyphenate.easeui.ui.EaseShowVideoActivity;
import com.hyphenate.easeui.utils.EaseCommonUtils;
import com.hyphenate.easeui.utils.EaseCompat;
import com.hyphenate.easeui.utils.EaseDateUtils;
import com.hyphenate.easeui.utils.EaseFileUtils;
import com.hyphenate.easeui.utils.EaseImageUtils;
import com.hyphenate.easeui.utils.EaseSmileUtils;
import com.hyphenate.easeui.utils.EaseUserUtils;
import com.hyphenate.easeui.utils.EaseVoiceLengthUtils;
import com.hyphenate.easeui.widget.chatrow.EaseChatRowVoicePlayer;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.TextFormater;

import java.util.Date;

import io.agora.chat.R;
import io.agora.chat.databinding.EaseLayoutChatThreadParentMsgBinding;

public class EaseChatThreadParentMsgView extends ConstraintLayout {
    private static final String TAG = EaseChatThreadParentMsgView.class.getSimpleName();
    private EaseLayoutChatThreadParentMsgBinding binding;
    private OnMessageItemClickListener itemClickListener;
    private EMMessage message;
    private EaseChatRowVoicePlayer voicePlayer;
    private AnimationDrawable voiceAnimation;

    public EaseChatThreadParentMsgView(@NonNull Context context) {
        this(context, null);
    }

    public EaseChatThreadParentMsgView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EaseChatThreadParentMsgView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.ease_layout_chat_thread_parent_msg, (ViewGroup) getParent(), false);
        addView(binding.getRoot());
        // set avatar uniformly
        EaseUserUtils.setUserAvatarStyle(binding.avatar);

        setListener();
    }

    private void setListener() {
        binding.avatar.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(itemClickListener != null && message != null) {
                    itemClickListener.onUserAvatarClick(message.getFrom());
                }
            }
        });

        binding.avatar.setOnLongClickListener(new OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if(itemClickListener != null && message != null) {
                    itemClickListener.onUserAvatarLongClick(message.getFrom());
                    return true;
                }
                return false;
            }
        });

        binding.llContent.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(itemClickListener != null && message != null) {
                    itemClickListener.onBubbleClick(message);
                    return;
                }
                clickEvent(message);
            }
        });

        binding.llContent.setOnLongClickListener(new OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if(itemClickListener != null && message != null) {
                    itemClickListener.onBubbleLongClick(v, message);
                    return true;
                }
                return false;
            }
        });
    }

    private void clickEvent(EMMessage message) {
        if(message == null) {
            return;
        }
        EMMessage.Type type = message.getType();
        switch (type) {
            case IMAGE :
                openImage(message);
                break;
            case VIDEO :
                openVideo(message);
                break;
            case LOCATION :
                openLocation(message);
                break;
            case VOICE :
                playVoice(message);
                break;
            case FILE :
                openFile(message);
                break;
        }
    }

    private void openImage(EMMessage message) {
        EMImageMessageBody imgBody = (EMImageMessageBody) message.getBody();
        Intent intent = new Intent(getContext(), EaseShowBigImageActivity.class);
        Uri imgUri = imgBody.getLocalUri();
        EaseFileUtils.takePersistableUriPermission(getContext(), imgUri);
        EMLog.e("Tag", "big image uri: " + imgUri + "  exist: "+EaseFileUtils.isFileExistByUri(getContext(), imgUri));
        if(EaseFileUtils.isFileExistByUri(getContext(), imgUri)) {
            intent.putExtra("uri", imgUri);
        } else{
            // The local full size pic does not exist yet.
            // ShowBigImage needs to download it from the server
            // first
            String msgId = message.getMsgId();
            intent.putExtra("messageId", msgId);
            intent.putExtra("filename", imgBody.getFileName());
        }
        getContext().startActivity(intent);
    }

    private void openVideo(EMMessage message) {
        Intent intent = new Intent(getContext(), EaseShowVideoActivity.class);
        intent.putExtra("msg", message);
        getContext().startActivity(intent);
    }

    private void openLocation(EMMessage message) {

    }

    private void playVoice(EMMessage message) {
        if(voicePlayer == null) {
            voicePlayer = EaseChatRowVoicePlayer.getInstance(getContext());
        }
        if (voicePlayer.isPlaying()) {
            // Stop the voice play first, no matter the playing voice item is this or others.
            voicePlayer.stop();

            // If the playing voice item is this item, only need stop play.
            String playingId = voicePlayer.getCurrentPlayingId();
            if (message.getMsgId().equals(playingId)) {
                return;
            }
        }
        voicePlayer.play(message, new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                // Stop the voice play animation.
                stopVoicePlayAnimation();
            }
        });
        // Start the voice play animation.
        startVoicePlayAnimation();
    }

    private void startVoicePlayAnimation() {
        binding.ivVoice.setImageResource(R.drawable.voice_from_icon);
        voiceAnimation = (AnimationDrawable) binding.ivVoice.getDrawable();
        voiceAnimation.start();
    }

    private void stopVoicePlayAnimation() {
        if (voiceAnimation != null) {
            voiceAnimation.stop();
        }
        binding.ivVoice.setImageResource(R.drawable.ease_chatfrom_voice_playing);
    }

    private void openFile(EMMessage message) {
        EMNormalFileMessageBody fileMessageBody = (EMNormalFileMessageBody) message.getBody();
        Uri filePath = fileMessageBody.getLocalUri();
        EaseFileUtils.takePersistableUriPermission(getContext(), filePath);
        if(EaseFileUtils.isFileExistByUri(getContext(), filePath)){
            EaseCompat.openFile(getContext(), filePath);
        } else {
            // download the file
            getContext().startActivity(new Intent(getContext(), EaseShowNormalFileActivity.class).putExtra("msg", message));
        }
    }

    public void setMessage(EMMessage message) {
        if(message == null) {
            return;
        }
        this.message = message;
        String nickname = message.getFrom();
        do {
            EaseUserProfileProvider userProvider = EaseIM.getInstance().getUserProvider();
            if(userProvider == null) {
                break;
            }
            EaseUser user = userProvider.getUser(message.getFrom());
            if(user == null) {
                break;
            }
            nickname = user.getNickname();
            EaseUserUtils.setUserAvatar(getContext(), message.getFrom(), binding.avatar);
        } while (false);
        binding.name.setText(nickname);
        binding.time.setText(EaseDateUtils.getTimestampString(getContext(), new Date(message.getMsgTime())));
        EMMessage.Type type = message.getType();
        switch (type) {
            case TXT :
                setTxtMessage(message);
                break;
            case IMAGE :
                setImageMessage(message);
                break;
            case VIDEO :
                setVideoMessage(message);
                break;
            case LOCATION :
                setLocationMessage(message);
                break;
            case VOICE :
                setVoiceMessage(message);
                break;
            case FILE :
                setFileMessage(message);
                break;
            case CUSTOM :
                setCustomMessage(message);
                break;
        }
    }

    private void setTxtMessage(EMMessage message) {
        hideAllBubble();
        binding.message.setText(EaseSmileUtils.getSmiledText(getContext(), EaseCommonUtils.getMessageDigest(message, getContext())));
        binding.message.setVisibility(VISIBLE);
    }

    private void setImageMessage(EMMessage message) {
        hideAllBubble();
        EaseImageUtils.showImage(getContext(), binding.image, message);
        binding.bubblePicture.setVisibility(VISIBLE);
    }

    private void setVideoMessage(EMMessage message) {
        hideAllBubble();
        ViewGroup.LayoutParams params = EaseImageUtils.showVideoThumb(getContext(), binding.chattingContentIv, message);
        ViewGroup.LayoutParams bubbleParams = binding.bubbleVideo.getLayoutParams();
        bubbleParams.width = params.width;
        bubbleParams.height = params.height;

        EMVideoMessageBody videoBody = (EMVideoMessageBody) message.getBody();

        if (videoBody.getDuration() > 0) {
            String time;
            if(videoBody.getDuration() > 1000) {
                time = EaseDateUtils.toTime(videoBody.getDuration());
            }else {
                time = EaseDateUtils.toTimeBySecond(videoBody.getDuration());
            }
            binding.chattingLengthIv.setText(time);
        }

        if (videoBody.getVideoFileLength() > 0) {
            String size = TextFormater.getDataSize(videoBody.getVideoFileLength());
            binding.chattingSizeIv.setText(size);
        }

        binding.bubbleVideo.setVisibility(VISIBLE);
    }

    private void setLocationMessage(EMMessage message) {
        hideAllBubble();
    }

    private void setVoiceMessage(EMMessage message) {
        hideAllBubble();
        EMVoiceMessageBody voiceBody = (EMVoiceMessageBody) message.getBody();
        int len = voiceBody.getLength();
        int padding = 0;
        if (len > 0) {
            padding = EaseVoiceLengthUtils.getVoiceLength(getContext(), len);
            binding.tvLength.setText(voiceBody.getLength() + "\"");
            binding.tvLength.setVisibility(View.VISIBLE);
        } else {
            binding.tvLength.setVisibility(View.INVISIBLE);
        }
        binding.ivVoice.setImageResource(R.drawable.ease_chatfrom_voice_playing);
        binding.tvLength.setPadding(padding, 0, 0, 0);
        binding.bubbleVoice.setVisibility(VISIBLE);
    }

    private void setFileMessage(EMMessage message) {
        hideAllBubble();
        EMNormalFileMessageBody fileMessageBody = (EMNormalFileMessageBody) message.getBody();
        binding.tvFileName.setText(fileMessageBody.getFileName());
        binding.tvFileSize.setText(TextFormater.getDataSize(fileMessageBody.getFileSize()));
        setFileIcon(fileMessageBody.getFileName());
        binding.tvFileState.setText("");
        binding.bubbleFile.setVisibility(VISIBLE);
    }

    private void setCustomMessage(EMMessage message) {
        hideAllBubble();
    }

    private void setFileIcon(String fileName) {
        EaseFileIconProvider provider = EaseIM.getInstance().getFileIconProvider();
        if(provider != null) {
            Drawable icon = provider.getFileIcon(fileName);
            if(icon != null) {
                binding.ivFileIcon.setImageDrawable(icon);
            }
        }
    }

    private void hideAllBubble() {
        binding.message.setVisibility(GONE);
        binding.bubbleVoice.setVisibility(GONE);
        binding.bubblePicture.setVisibility(GONE);
        binding.bubbleVideo.setVisibility(GONE);
        binding.bubbleFile.setVisibility(GONE);
        binding.bubbleBigExpression.setVisibility(GONE);
    }

    public ImageView getAvatarView() {
        return binding.avatar;
    }

    public TextView getUsernameView() {
        return binding.name;
    }

    public TextView getTimeView() {
        return binding.time;
    }

    public ViewGroup getBubbleParent() {
        return binding.llContent;
    }

    public void setBottomDividerVisible(boolean visible) {
        binding.viewBottomDivider.setVisibility(visible ? VISIBLE : GONE);
    }

    /**
     * Set thread parent message's click listener
     * @param itemClickListener
     */
    public void setOnMessageItemClickListener(OnMessageItemClickListener itemClickListener) {
        this.itemClickListener = itemClickListener;
    }
}
