# 环信超级社区（Circle）示例项目

## 简介

环信超级社区（Circle）是一款基于环信 IM 打造的类 Discord 实时社区应用场景方案，支持社区（Server）、频道（Channel） 和子区（Thread） 三层结构。一个 App 下可以有多个社区，同时支持陌生人/好友单聊。用户可创建和管理自己的社区，在社区中设置和管理频道将一个话题下的子话题进行分区，在频道中根据感兴趣的某条消息发起子区讨论，实现万人实时群聊，满足超大规模用户的顺畅沟通需求。
该仓库包含了使用环信即时通讯 IM Web SDK 实现超级社区的示例项目。

## 项目结构

```
.
├── README.md
├── config
├── jsconfig.json
├── package-lock.json
├── package.json
├── public
├── scripts
├── src
│   ├── App.js
│   ├── App.less
│   ├── App.test.js
│   ├── assets //静态资源
│   ├── components //基础组件
│   ├── index.css
│   ├── index.js
│   ├── layout //页面入口
│   │   ├── Channel //频道相关页面
│   │   │   ├── InviteUser //邀请用户加入频道
│   │   │   ├── SideBar // 频道列表及当前server展示页面
│   │   │   └──  index.js //频道页面入口
│   │   ├── Contacts
│   │   │   ├── SideBar 联系人列表页面
│   │   │   └──  index.js //联系人页面入口
│   │   ├── Main
│   │   │   ├── ScrollBar //社区列表页面
│   │   │   ├── ServerForm //创建、编辑社区
│   │   │   └── index.js //主页面入口
│   │   ├── Server
│   │   │   ├── SideBar //广场菜单页面
│   │   │   └──  index.js //广场页面入口
│   │   └── UserInfo
│   │       ├── SideBar //用户信息页面
│   │       └──  index.js //用户信息页面入口
│   ├── routes //路由
│   ├── setupTests.js
│   ├── store //数据管理
│   │   └── models
│   │       ├── app.js //app 数据管理
│   │       ├── channel.js //频道数据管理
│   │       ├── contact.js //联系人数据管理
│   │       ├── server.js //社区数据管理
│   │       └── thread.js //子区数据管理
│   ├── utils sdk及公用方法
│   └── views //页面组件
│       ├── Channel
│       │   ├── components 频道聊天页面组件
│       │   └── index.js //频道聊天页面
│       ├── Chat
│       │   ├── components //联系人聊天页面组件
│       │   └── index.js //联系人聊天页面
│       ├── ContactsOperation
│       │   └── index.js //联系人页面
│       ├── Login
│       │   └── login.js //登录页面
│       ├── ServerSquare
│       │   └── index.js //广场页面
│       ├── Thread
│       │   ├── components //子区页组件
│       │   └── index.js //子区页面
│       └── UserInfo
│           └── index.js //更新用户信息

```


## 运行项目

1、克隆项目  
```bash
git clone https://github.com/easemob/Circle-Demo-Web.git
```

2、安装依赖
```bash
npm install
```

3、设置appKey
在"/src/utils/WebIM.js"文件中设置你的appKey。

4、运行项目

```bash
npm start
```
## 反馈
如果你有任何问题或建议，可以通过 issue 的形式反馈。

## 参考文档

产品概述及开发文档：
https://docs-im.easemob.com/ccim/circle/overview

## 代码许可
示例项目遵守 MIT 许可证。

# 模拟器游戏直播

## 项目介绍

用户可以通过建立直播房间(video-开头), 与朋友一起玩游戏, 并且可以通过直播功能, 将游戏直播到网上, 让更多的人观看, 主要代码在`StreamHandler`中.

## 直播和语音

rtc功能是基于 Agora.io 的 SDK 实现的. 

一个房间中可以有多个用户, 每个用户都可以通过 rtc 进行语音通话(接听房间中用户语言流, 发布自己本地语音流).

也可以通过直播功能, 将自己的游戏直播到网上, 直播流每个房间同一时刻只能存在一个, 通过向房间中发送自定义上下播消息实现. 当房间中不存在直播流时, 用户才可以选择将本地视频流发布到房间中, 作为直播流.

## nes 游戏

基于[RustNESEmulator](https://github.com/xxrlzzz/RustNESEmulator)项目, 将Rust编写的nes模拟器通过wasm编译到web端. 渲染结果输入到canvas中.

TODO: 1. 支持双人联机(观看端发送控制数据, 实现联机), 2.游戏视频流优化(分辨率适配), 3. 房间流管理优化(在线流发现)

效果图

![image](./public/result.png)
