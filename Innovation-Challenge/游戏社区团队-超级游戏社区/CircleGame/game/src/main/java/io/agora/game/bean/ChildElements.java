package io.agora.game.bean;

import com.stx.xhb.xbanner.entity.SimpleBannerInfo;

import java.util.List;

public class ChildElements extends SimpleBannerInfo {
    private int id;
    private String title;
    private List<String> thumbnailUrls;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<String> getThumbnailUrls() {
        return thumbnailUrls;
    }

    public void setThumbnailUrls(List<String> thumbnailUrls) {
        this.thumbnailUrls = thumbnailUrls;
    }

    @Override
    public String toString() {
        return "ChildElements{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", thumbnailUrls=" + thumbnailUrls +
                '}';
    }

    @Override
    public Object getXBannerUrl() {
        return thumbnailUrls.get(0);
    }
}
