package io.agora.home.bean;

import java.util.ArrayList;
import java.util.List;

import io.agora.home.utils.TreeNodeDefault;
import io.agora.home.utils.TreeNodeIcon;
import io.agora.home.utils.TreeNodeId;
import io.agora.home.utils.TreeNodeName;
import io.agora.home.utils.TreeNodePid;

public class Node {

    @TreeNodeId
    private String id = "";
    /**
     * 根节点pId为0
     */
    @TreeNodePid
    private String pId = "";
    @TreeNodeName
    private String name;

    /**
     * 当前的级别
     */
    private int level;

    /**
     * 是否展开
     */
    private boolean isExpand = true;

    @TreeNodeIcon
    private int icon;
    //自定义属性，是否默认频道
    @TreeNodeDefault
    private boolean isDefault = false;

    /**
     * 下一级的子Node
     */
    private List<Node> children = new ArrayList<Node>();

    /**
     * 父Node
     */
    private Node parent;


    public Node() {
    }

    public Node(String id, String pId, String name) {
        super();
        this.id = id;
        this.pId = pId;
        this.name = name;
    }

    public int getIcon() {
        return icon;
    }

    public void setIcon(int icon) {
        this.icon = icon;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getpId() {
        return pId;
    }

    public void setpId(String pId) {
        this.pId = pId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public boolean isExpand() {
        return isExpand;
    }

    public List<Node> getChildren() {
        return children;
    }

    public void setChildren(List<Node> children) {
        this.children = children;
    }

    public Node getParent() {
        return parent;
    }

    public void setParent(Node parent) {
        this.parent = parent;
    }

    /**
     * 是否为跟节点
     *
     * @return
     */
    public boolean isRoot() {
        return parent == null;
    }

    /**
     * 判断父节点是否展开
     *
     * @return
     */
    public boolean isParentExpand() {
        if (parent == null)
            return false;
        return parent.isExpand();
    }

    /**
     * 是否是叶子界点
     *
     * @return
     */
    public boolean isLeaf() {
        return children.size() == 0;
    }

    /**
     * 获取level
     */
    public int getLevel() {
        return parent == null ? 0 : parent.getLevel() + 1;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean aDefault) {
        isDefault = aDefault;
    }

    /**
     * 设置展开
     *
     * @param isexpand
     */
    public void setExpand(boolean isExpand) {
        this.isExpand = isExpand;
        if (!isExpand) {

            for (Node node : children) {
                node.setExpand(isExpand);
            }
        }
    }

}
