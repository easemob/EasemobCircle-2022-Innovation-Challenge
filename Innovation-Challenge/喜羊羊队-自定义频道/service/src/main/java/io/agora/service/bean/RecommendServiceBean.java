package io.agora.service.bean;


import java.util.List;

import io.agora.service.db.entity.CircleServer;

public class RecommendServiceBean {
    private Integer code;
    private Integer count;
    private List<Servers> servers;

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public List<Servers> getServers() {
        return servers;
    }

    public void setServers(List<Servers> servers) {
        this.servers = servers;
    }

    public static class Servers {
        private String name;
        private String owner;
        private String description;
        private String custom;
        private List<CircleServer.Tag> tags;
        private Long created;
        private String server_id;
        private String icon_url;
        private Integer tag_count;
        private String default_channel_id;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getOwner() {
            return owner;
        }

        public void setOwner(String owner) {
            this.owner = owner;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getCustom() {
            return custom;
        }

        public void setCustom(String custom) {
            this.custom = custom;
        }

        public List<CircleServer.Tag> getTags() {
            return tags;
        }

        public void setTags(List<CircleServer.Tag> tags) {
            this.tags = tags;
        }

        public Long getCreated() {
            return created;
        }

        public void setCreated(Long created) {
            this.created = created;
        }

        public String getServer_id() {
            return server_id;
        }

        public void setServer_id(String server_id) {
            this.server_id = server_id;
        }

        public String getIcon_url() {
            return icon_url;
        }

        public void setIcon_url(String icon_url) {
            this.icon_url = icon_url;
        }

        public Integer getTag_count() {
            return tag_count;
        }

        public void setTag_count(Integer tag_count) {
            this.tag_count = tag_count;
        }

        public String getDefault_channel_id() {
            return default_channel_id;
        }

        public void setDefault_channel_id(String default_channel_id) {
            this.default_channel_id = default_channel_id;
        }

        @Override
        public String toString() {
            return "Servers{" +
                    "name='" + name + '\'' +
                    ", owner='" + owner + '\'' +
                    ", description='" + description + '\'' +
                    ", custom='" + custom + '\'' +
                    ", tags=" + tags +
                    ", created=" + created +
                    ", server_id='" + server_id + '\'' +
                    ", icon_url='" + icon_url + '\'' +
                    ", tag_count=" + tag_count +
                    ", default_channel_id='" + default_channel_id + '\'' +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "RecommendServiceBean{" +
                "code=" + code +
                ", count=" + count +
                ", servers=" + servers +
                '}';
    }
}
