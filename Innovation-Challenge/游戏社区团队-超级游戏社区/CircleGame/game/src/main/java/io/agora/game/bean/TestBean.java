package io.agora.game.bean;

public class TestBean {
//    addCacheTime=2022-12-11T19:37:29+08:00
    private String addCacheTime;

    public String getAddCacheTime() {
        return addCacheTime;
    }

    public void setAddCacheTime(String addCacheTime) {
        this.addCacheTime = addCacheTime;
    }

    @Override
    public String toString() {
        return "TestBean{" +
                "addCacheTime='" + addCacheTime + '\'' +
                '}';
    }
}
