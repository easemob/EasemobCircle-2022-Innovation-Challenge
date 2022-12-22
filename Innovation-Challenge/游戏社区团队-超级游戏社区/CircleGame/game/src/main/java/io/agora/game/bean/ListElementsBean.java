package io.agora.game.bean;

import java.util.List;

public class ListElementsBean {
    private int id;
    private String title;
    private String publishTimeCaption;
    private String contentUrl;
    private List<String> thumbnailUrls;
    private List<ChildElements> childElements;

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

    public List<ChildElements> getChildElements() {
        return childElements;
    }

    public void setChildElements(List<ChildElements> childElements) {
        this.childElements = childElements;
    }

    public String getPublishTimeCaption() {
        return publishTimeCaption;
    }

    public void setPublishTimeCaption(String publishTimeCaption) {
        this.publishTimeCaption = publishTimeCaption;
    }

    public String getContentUrl() {
        return contentUrl;
    }

    public void setContentUrl(String contentUrl) {
        this.contentUrl = contentUrl;
    }

    @Override
    public String toString() {
        return "ListElementsBean{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", thumbnailUrls=" + thumbnailUrls +
                ", childElements=" + childElements +
                '}';
    }
}
