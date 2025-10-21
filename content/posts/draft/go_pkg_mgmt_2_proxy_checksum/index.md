---
title: Go 包管理（一）入门和设计原则
date: 2024-01-06
draft: true
tags:
- Golang
- Package Management
---

go.work:
`use` directive tells that a module should be main modules when doing a build. 

go.sum Trust on **your** first use

- 区分"内部"依赖和"共享"依赖
  - 只要一个依赖没有被导出到公开接口，那么它就是内部的
  - 内部依赖允许不同版本存在
  - https://www.thefeedbackloop.xyz/thoughts-on-dependency-hell-is-np-complete/ （这里也讲了一些 npm 的方式）

- https://stephencoakley.com/2019/04/24/how-rust-solved-dependency-hell
  - 介绍了 rust 的 semver 
  - 以及用 name managing 来允许不同版本的依赖

## Workspaces

## Issues
