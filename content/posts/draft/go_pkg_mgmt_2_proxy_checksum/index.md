---
title: Go 包管理（二）镜像和工作区
date: 2025-10-11
draft: true
tags:
- Golang
- Package Management
---

## // indirect

这是上篇博客中的一个遗留问题。

按照我们对于 MVS 的理解，我们只需要记录当前模块的所有直接依赖，但是为什么在 `go.mod` 文件中还能看见大量的 `require example.com/foo // indirect` 的语句呢？这里 indirect 指的就是模块的间接依赖。答案是在 1.16 之前，除非需要一个和 MVS 解析到的版本不同的版本，才需要给间接依赖加上 `require` 指令。但是在 1.17 及之后，需要它来提供一些额外信息。

这便是[懒模块加载](https://go.googlesource.com/proposal/+/master/design/36460-lazy-module-loading.md)，其核心思想是，假设当前项目的依赖链是 main -> A -> B -> C，那么解析依赖时，只需读取 A  的 go.mod 文件即可发现 A 的依赖是 B 和 C，而无需再去读取 B 的 go.mod 了。

## 镜像和校验数据库

`go get` 的原始设计是去中心化的，如上一篇博客所述，发布一个模块依赖 VCS 的 tag 功能，`go get` 会直接从模块路径下载模块。这和其他几乎所有编程语言都不同——它们都有中心化的仓库，如 PyPI, npm, crates.io 等等。但去中心化也带来了一些问题：

- 没有一个统一的地方查找包的信息。比如 godoc.org 无法在一个包更新之后就更新在它上面的文档
- 没法校验模块的完整性，比如遭受了中间人攻击，或者模块没有被完整下载。又或者服务器遭受了攻击，导致原始文件被替换成了包含恶意代码的版本。go.sum 中存储了已有模块的 hash，但是在下载新模块时，hash 是未知的
- 有的服务器可能很慢，或者宕机
- 随着时间的流逝有的服务器可能不可用了（类似 link rotting）
- 直接从 VCS 拉取代码也可能很慢

为了解决这些问题，go team 在 2019/08 发布了模块镜像（Module Mirror）和校验数据库（Checksum Database）。这两个系统都是 Google 运营的。显然，这是在去中心化的设计中加入了一些中心化的成分，但这也是不得不做的妥协。

模块镜像允许 go 下载特定版本的代码（zip 文件）或者元数据（版本列表，go.mod 文件等），这样在依赖解析阶段只需下载元数据，而不必下载整个代码库。模块镜像会在第一次被请求一个模块的时候去源地址下载这个模块，之后，它会永久缓存这个模块。

校验数据库实际上是一个巨大的 go.sum 文件，go 从模块镜像下载模块之后会请求校验数据库获取模块的 hash。这样 go 就从信任“首次使用”变成了信任校验数据库。那我们真的能信任校验数据库吗？Russ Cox 在[博客](https://research.swtch.com/tlog)中设计了一种数据结构来实现这一点，其有以下几条关键的性质：

- 它是一个 append-only log，假设长度为 N
- 给定一条记录 R，它能够在 O(lg N) 时间内验证 R 在 log 中
- 对于 client 中任何已经记录的 R，它能够在 O(lg N) 时间验证 R 是当前 log 的前缀
- 一个审计者可以高效地遍历整个 log

其核心的数据结构——学过区块链的小伙伴可能已经猜到了——正是 [Merkle Tree](https://en.wikipedia.org/wiki/Merkle_tree)。Merkle Tree 并不能保证 log 不被篡改，然而，一旦任何过往的 log 被改动，将很容易被外界观察到。

下面简单介绍一下 `go get` 的具体流程。

如果在 `GOPROXY=direct` 模式下，go 会直接从源仓库下载模块（[文档](https://go.dev/ref/mod#vcs-find)）。go 会首先请求模块地址加上一个 `?go-get=1` 查询字符串。比如 `golang.org/x/mod` 这个模块，go 会 GET `https://golang.org/x/mod?go-get=1`。

服务器必须返回一个 HTML 文档，包含一个如下格式的 meta tag：

```html
<meta name="go-import" content="root-path vcs repo-url [subdirectory]">

/* for example */
<meta name="go-import" content="golang.org/x/mod git https://go.googlesource.com/mod">
```

go 在 parse 这个 tag 之后，便会使用相应的 VCS 去对应仓库下载代码。稍微翻了一下源码发现，如果是 git 的话会使用 `git clone -- {repo} {dir}` clone 整个仓库，所以还是比较费时的。

而在使用模块镜像的情况下

## Workspaces

go.work:
`use` directive tells that a module should be main modules when doing a build. 

## Issues
