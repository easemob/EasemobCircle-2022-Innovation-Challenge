# CT超级社区

[体验地址](http://121.37.205.80:3000/)

## 简介

CT超级社区是一款基于环信 IM 打造的类 Discord 实时社区应用场景方案，支持社区（Server）、频道（Channel） 和子区（Thread） 三层结构。一个 App 下可以有多个社区，同时支持陌生人/好友单聊。用户可创建和管理自己的社区，在社区中设置和管理频道将一个话题下的子话题进行分区，在频道中根据感兴趣的某条消息发起子区讨论，实现万人实时群聊，满足超大规模用户的顺畅沟通需求。

CT超级社区基于基础的实时聊天场景以外，为自己的社区安装插件，通过丰富的插件功能可以提升社区体验。但由于时间问题，目前插件系统提供对外的开发功能上并不是很多。目前引入的插件仅通过硬编码把插件的路径配置在前端代码中。目前实现的插件有：投票、社区签到、打卡分享、代码分享、机器人。下面再作详述。


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


## 运行本项目

1. 克隆项目
```bash
git clone https://github.com/Circle-Web/Circle-Demo-Web.git
```

2. 安装依赖
```bash
pnpm install
```

3. 设置appKey
- 在`/src/utils/WebIM.js`文件中设置你的`appKey`。

4. 运行项目
```bash
npm start
```

## 运行插件项目
[插件项目的地址](https://github.com/Circle-Web/Circle-Web-Plugins)
1. 克隆项目
```bash
git clone 
```
2. 安装依赖
```bash
pnpm install
```
3. 运行项目
```base
pnpm dev:sign
```

## 运行插件系统项目
[插件系统web端和server端的地址](https://github.com/Circle-Web/app-server-list)

- server端：
1. 克隆项目
```bash
git clone 
```
2. 安装依赖
```bash
npm install
```
3. 安装mysql并创建一个数据库
4. 设置yml配置
- 复制`dev.yml`重命名为`dev-temp.yml`
- 然后配置相应的内容，比如数据库、环信IM、七牛云等
5. 运行项目
```bash
npm start dev
```

## 主要功能介绍

### 体验入口
因为插件系统原计划是跟社区绑定的, 所以必须要选择某一个社区后才会出现入口, 选择社区后进入频道可看到最右上角有一个入口

### 社区打卡分享
该插件配置了各种打卡的数据，用户可以通过插件分享自己的打卡任务，比如学习打卡，上班打卡等。
- 操作方式：
  - 用户打开插件，然后选择相应分享内容，点击发送按钮，即可分享到社区中
![](readmeimage/share.gif)

### 投票功能
社区中的人都可以在不同频道发起投票，支持多选操作以及查看历史发起投票的记录查询。创建者可以在插件中发送投票卡片消息到聊天中，其他用户点击卡片即可以跳转到对应的投票详情里，进行投票。
- 操作方式：
  - 用户打开插件，填写好投票内容，选项内容等，点击“发起投票”按钮即可在该频道中创建投票。
  - 发起人也可以查看历史记录，选择重新分享到频道中。
  - 投票基本完成后，发起人可以结束投票。
![](readmeimage/vote1.gif)
![](readmeimage/vote2.gif)

### 社区签到
在签到插件中，用户可以在当前社区进行签到，查看连续签到的排名情况。
![](readmeimage/sign.gif)

### 代码分享
通过选择插件上提供的编程语言类型，编写代码，也可以对代码格式化，最后点击分享代码即可发到我们的频道中。
![](readmeimage/code.gif)

### 机器人
- 频道内置机器人
  - 用户通过特定命令会触发频道自动创建内置机器人，也可以让管理员事先触发创建，机器人拥有查询天气等功能，比如在频道中发送`#天气查询：广州`这样的关键词，即可有机器人查询并发送到当前频道。如此，便可以做很多内置机器人的互动功能了，时间关系所以本项目目前并没有实现很多功能。
![](readmeimage/robot-search.gif)
- 外置拓展机器人
  - 社区所有者/管理员通过插件可以给不同频道安装不同的机器人（机器人和频道是一对一绑定的），然后服务端会返回一个webhook调用。管理员可以通过利用webhook去实现一些功能，比如将其他渠道的消息通过Webhook的方式推送至频道中。然后也可以把它分享给频道的一些普通成员去使用，注意这是比较隐私的数据，最好分享给值得信赖的成员~当然如果误发了，插件也提供重置功能，点击重置地址便会重新生成一个新的webhook。
![](readmeimage/robot1.gif)
![](readmeimage/robot2.gif)
## 代码许可
CT超级社区项目遵守 MIT 许可证。