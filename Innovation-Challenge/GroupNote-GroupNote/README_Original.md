# 环信超级社区（Circle）示例项目

## 简介

环信超级社区（Circle）是一款基于环信 IM 打造的类 Discord 实时社区应用场景方案，支持社区（Server）、频道（Channel） 和子区（Thread） 三层结构。一个 App 下可以有多个社区，同时支持陌生人/好友单聊。用户可创建和管理自己的社区，在社区中设置和管理频道将一个话题下的子话题进行分区，在频道中根据感兴趣的某条消息发起子区讨论，实现万人实时群聊，满足超大规模用户的顺畅沟通需求。
该仓库包含了使用环信即时通讯 IM iOS SDK 实现超级社区的示例项目。

## 项目结构

| 功能 | 位置 |
| --- | --- |
|  登录注册| LoginViewController.swift |
|  个人信息管理| UserInfoViewController.swift |
|  联系人管理| ContactsViewController.swift |
|  消息管理| MessageViewController.swift |
|  广场 | SquareViewController.swift |


## 运行项目

1、克隆项目  
```bash
git clone git@github.com:easemob/Circle-Demo-IOS.git
```

2、安装依赖
```bash
pod install
```

3、打开工程项目
双击 `discord-ios.xcworkspace`文件打开项目

4、设置appKey
在"AppDelegate.swift"文件中设置你的appKey。

5、运行项目

```bash
command + r
```
## 反馈
如果你有任何问题或建议，可以通过 issue 的形式反馈。

## 参考文档

产品概述及开发文档：
https://docs-im.easemob.com/ccim/circle/overview

## 代码许可
示例项目遵守 MIT 许可证。