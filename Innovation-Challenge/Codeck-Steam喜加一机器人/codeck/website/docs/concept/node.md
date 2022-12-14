---
sidebar_position: 1
title: 节点 Node
---

`codeck`的编程基础是`节点(Node)`，每个节点可以被分成**输入**和**输出**两部分。这两部分都是由 `端点(pin)` 组成的，同时 `端点(pin)` 根据行为可以被分为 `执行端点(Exec Pin)` 和 `数据端点(Port Pin)`

![Node](./img/node.png)

如上图所示是一个比较完整的节点构成。其中左边是输入右边是输出，圆形为数据端点用于连接数据，五边形为执行端点用于描述节点与节点之间的关系。一般标准执行节点是描述生成代码的先后顺序

以所示 `Loop节点` 为例，其生成代码格式应当如下:

```js
[1]
for (let [5] = 0; [5] < [3]; [5]++) {
  [4]
}
[2]
```

其中中括号中的数字分别代表不同端点。可以很明显看到：
- 1,2,4 是执行端点，表示代码的占位
- 3,5 是数据端点，表示代码的变量
