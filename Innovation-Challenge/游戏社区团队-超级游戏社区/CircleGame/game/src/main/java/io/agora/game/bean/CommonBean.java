package io.agora.game.bean;

public class CommonBean<T> {

    private String error;
    private T post;
    private T listElements;
    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public T getPost() {
        return post;
    }

    public void setPost(T post) {
        this.post = post;
    }

    public T getListElements() {
        return listElements;
    }

    public void setListElements(T listElements) {
        this.listElements = listElements;
    }

    //    private String code;
//    private String msg;
//    private T data;
//
//    public String getCode() {
//        return code;
//    }
//
//    public void setCode(String code) {
//        this.code = code;
//    }
//
//    public String getMsg() {
//        return msg;
//    }
//
//    public void setMsg(String msg) {
//        this.msg = msg;
//    }
//
//    public T getData() {
//        return data;
//    }
//
//    public void setData(T data) {
//        this.data = data;
//    }
}
