package io.agora.game.bean;

public class GameContentBean {
    private String addCacheTime;
    private String title;
    private ShareInfo shareInfo;

    public String getAddCacheTime() {
        return addCacheTime;
    }

    public void setAddCacheTime(String addCacheTime) {
        this.addCacheTime = addCacheTime;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public ShareInfo getShareInfo() {
        return shareInfo;
    }

    public void setShareInfo(ShareInfo shareInfo) {
        this.shareInfo = shareInfo;
    }

    public class ShareInfo {
        public String contentUrl;
        public String thumbnailUrl;

        public String getContentUrl() {
            return contentUrl;
        }

        public void setContentUrl(String contentUrl) {
            this.contentUrl = contentUrl;
        }

        public String getThumbnailUrl() {
            return thumbnailUrl;
        }

        public void setThumbnailUrl(String thumbnailUrl) {
            this.thumbnailUrl = thumbnailUrl;
        }
    }
}
