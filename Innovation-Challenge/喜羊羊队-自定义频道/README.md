# 环信超级社区（Circle）示例项目

## 简介

环信超级社区（Circle）是一款基于环信 IM 打造的类 Discord 实时社区应用场景方案，支持社区（Server）、频道（Channel） 和子区（Thread） 三层结构。一个 App 下可以有多个社区，同时支持陌生人/好友单聊。用户可创建和管理自己的社区，在社区中设置和管理频道将一个话题下的子话题进行分区，在频道中根据感兴趣的某条消息发起子区讨论，实现万人实时群聊，满足超大规模用户的顺畅沟通需求。
该仓库包含了使用环信环信Circle SDK 实现超级社区的示例项目。

## 项目结构
项目采用组件化方式开发，各模块功能独立，架构如图所示：
![环信超级社区](https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/Circle/Android/%E7%8E%AF%E4%BF%A1%E8%B6%85%E7%BA%A7%E7%A4%BE%E5%8C%BA.jpg "环信超级社区")
各模块位置如下：
| 模块 | 位置 |
| --- | --- |
|  登录| Circle/login|
|  聊天| Circle/chat |
|  首页| Circle/home |
|  广场 | Circle/ground |
|  联系人| Circle/contacts |
|  我的| Circle/mine |


## 运行项目

1、克隆项目
```bash
git clone git@github.com:easemob/Circle-Demo-Android.git
```

2、安装apk
```bash
adb install circle-release.apk
```
3、打开工程项目

推荐Android Studio 版本：Android Studio Chipmunk | 2021.2.1 Patch 1 及以上

Java版本：Java8及以上

gradle版本：distributionUrl=https\://services.gradle.org/distributions/gradle-7.4.2-bin.zip

打开方式：
打开Android Studio->File->New->Import Project->选择Circle-Demo-Android工程根目录

4、设置appKey

在工程"local.properties"文件中设置你的appKey。
示例：
```bash
circle_appkey=easemob-demo#xxxx
```
开通配置环信即时通讯 IM 服务：
https://docs-im.easemob.com/ccim/config

5、运行项目

直接点击Android Studio 运行按钮

## 反馈
如果你有任何问题或建议，可以通过 issue 的形式反馈。

## 参考文档

demo下载地址：
https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/circle-release.apk

sdk下载地址：
https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/easemob-sdk-3.9.5.2.zip

产品概述及开发文档：
https://docs-im.easemob.com/ccim/circle/overview


