---
title: Markdown简介
date: 2018-11-08 20:16:56
lastmod: 2019-01-22
tags:
- Markdown
---


## **什么是 Markdown?**

Markdown 是一种轻量级且易使用的标记语言，通过对标题、正文、加粗、链接等主要文本格式的预设编码，帮用户在写作中有效避免频繁的格式调整，获得更加流畅沉浸的写作体验。

![哈哈哈](./Markdown-mark.svg.png)

<!-- more -->

***
### Markdown VS 富文本

基于 Markdown 写作，是属于**纯文本**写作。「纯文本」写作和「富文本」写作是对立的，我们来区分一下：

#### **「富文本」写作 **

你平时在**Word**上写作，就属于富文本写作。修改文字的大小、修改文字颜色、调整各种格式只需要点一下鼠标就行。富文本写作最大的特点是：**所见即所得**，你把格式调整成什么样子，就会直接显示出什么样的效果。

然而，富文本的格式排版过于繁杂，以致于你不得不花费大量时间在这上面，而忽略了写作本身。

同时，富文本存在着**多平台转换不方便**的问题，假如你在 Word 上写好了文档，格式也调好了，复制粘贴到其他写作平台的时候发现：**格式全乱啦**；即使是转发给其他人也可能因为 Word 版本的不同而导致显示的差别很大。（如果你有过去打印店打印文档的经历的话，相信体会很深吧）富文本一般需要使用专用软件打开（如Word）。

#### **「Markdown」写作**

基于 **Markdown** 写作，就是纯文本写作。它允许人们使用纯文本格式来编写文档。如果你想设置某段文字的格式，只需要使用一些简单的符号来代表即可。所以**文字和格式都是纯文本**。能够用普通的文本编辑器打开。

Markdown正好处在富文本的对立面，由于其简洁的特性，导致其格式只有寥寥几种，功能上也远不如富文本编辑器。

------

**Markdown 的优点**

- 纯文本所以**兼容性**极强，可以用所有文本编辑器打开

- 让你更**专注于文字**而不是排版

- 格式**转换方便**，Markdown 文本你可以轻松转换为 html、电子书等

- Markdown 的标记语法有**极好的可读性**

****

**Markdown的主要用途**

* 博客（自建、简书、CSDN等等）
* 笔记，随笔等
* Github


## 编辑器推荐

* **Typora** Markdown也能所见即所得！



## 基本语法

Markdown语法主要分为如下几大部分： **标题**，**段落**，**区块引用**，**代码区块**，**强调**，**列表**，**分割线**，**链接**，**图片**，**反斜杠 \\**，**行内引用**。

#### 1. 标题

使用`#`，可表示1-6级标题。

> \# 一级标题
> \## 二级标题
> \### 三级标题
> \#### 四级标题
> \##### 五级标题
> \###### 六级标题

效果：

> # 一级标题
>
> ## 二级标题
>
> ### 三级标题
>
> #### 四级标题
>
> ##### 五级标题
>
> ###### 六级标题

#### 2. 段落

段落的前后要有空行，所谓的空行是指没有文字内容。若想在段内强制换行的方式是使用**两个以上**空格加上回车（引用中换行省略回车）。

#### 3. 区块引用

在段落的每行或者只在第一行使用符号`>`,还可使用多个嵌套引用，如：

> \> 区块引用
> \>> 嵌套引用

效果：

> 区块引用
>
> > 嵌套引用

#### 4. 代码区块

1）代码区块的建立是在每行加上4个空格或者一个制表符（如同写代码一样）。如
普通段落：

int main()
{
printf("Hello, Markdown.");
}

代码区块：


	int main()
	{
		printf("Hello, Markdown.");
	}

**注意**:需要和普通段落之间存在空行。 

2）在代码区块的前后加上  \`\`\`

> \`\`\`
> hello,world
> \`\`\`

效果为：

```
hello，world
```



#### 5. 强调

在强调内容两侧分别加上`*`或者`_`，如：

> \*斜体\*，\_斜体\_
> \**粗体\**，\__粗体\__

效果：

> *斜体*，*斜体*
> **粗体**，**粗体**

#### 6. 列表

使用`·`、`+`、或`-`标记无序列表，如：

> -（+*） 第一项 -（+*） 第二项 - （+*）第三项

**注意**：标记后面最少有一个_空格_或_制表符_。若不在引用区块中，必须和前方段落之间存在空行。

效果：

> - 第一项
> - 第二项
> - 第三项

有序列表的标记方式是将上述的符号换成数字,并辅以`.`，如：

> 1 . 第一项
> 2 . 第二项
> 3 . 第三项

效果：

> 1. 第一项
> 2. 第二项
> 3. 第三项

#### 7. 分割线

分割线最常使用就是三个或以上`*`，还可以使用`-`和`_`。

> \***

效果：

> ***



#### 8. 链接

使用 **\[]()** 在[]内输入链接的名称，()内输入链接的地址。 

> \[我的博客](https://cjc7373.github.io)

效果：

> [我的博客](https://cjc7373.github.io)

#### 9. 图片

添加图片的形式和链接相似，只需在链接的基础上前方加一个`！`。

#### 10. 反斜杠`\`

相当于**反转义**作用。使符号成为普通符号。

#### 11. 行内引用

在字符之间加上\`，起到标记作用，相当于行内引用。如：

> \`Too young\`

效果：

> `Too young`

## 拓展语法

#### 1.表格

````
| 一个普通标题 | 一个普通标题 | 一个普通标题 |
| ------ | :------: | ------: |
| 短文本 | 中等文本 | 稍微长一点的文本 |
| 稍微长一点的文本 | 短文本 | 中等文本 |
````
`------`用作标题和内容的分隔符，`:`用来控制对齐方式，上述表格的效果如下：

| 一个普通标题 | 一个普通标题 | 一个普通标题 |
| ------ | :------: | ------: |
| 短文本 | 中等文本 | 稍微长一点的文本 |
| 稍微长一点的文本 | 短文本 | 中等文本 |

