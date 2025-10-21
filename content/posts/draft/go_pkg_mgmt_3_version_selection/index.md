---
title: Go 包管理（一）版本选择问题
date: 2024-01-01
draft: true
tags:
- Golang
---

本来我只是打算写一篇博客介绍一下 Go Modules 的，但是看了 Russ Cox 的 [Version SAT](https://research.swtch.com/version-sat) 这篇博客，死去的形式化方法课程突然开始攻击我.. 于是我就想概述一下那篇博客，即为什么版本选择问题是 NP 完全的？

首先，StackOverflow 上[有个问题](https://stackoverflow.com/questions/1857244/what-are-the-differences-between-np-np-complete-and-np-hard)通俗易懂地讲解了 P/NP/NP-hard/NP-complete 之间的关系，推荐阅读。

## NP 完全性的证明

对于一个包管理器，我们假设：

1. 一个包可以声明零个或多个包或他们的特定版本作为其依赖
2. 为了安装一个包，它的所有依赖都必须被安装
3. 一个包的每个版本可以有不同的依赖
4. 两个不同版本的包不能被同时安装

上述假设构成了版本选择问题，这是一个 NPC 问题。为了简化这一问题，我们可以改变假设 1，只能声明一个依赖的最小版本；
