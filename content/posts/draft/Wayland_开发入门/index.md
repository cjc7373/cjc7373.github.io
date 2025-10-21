---
title: Wayland 开发入门
date: 2023-11-01
draft: true
tags:
- Desktop Environment
---

起因是我需要一个在 KDE Wayland 下工作的 [ActivityWatch Watcher](https://github.com/ActivityWatch/aw-watcher-window-wayland)，目前的 aw-watcher-window-wayland 使用 rust 编写，依赖了 wayland-rs 这个库。其实现了一个 kwin 不兼容的协议，所以在 kwin 下并不工作，于是我想为它添加一个 kwin 自己的协议，也正好借这个机会学习一波 Rust 和 Wayland。本文的内容基于 [Chapter 4. Wayland Protocol and Model of Operation](https://wayland.freedesktop.org/docs/html/ch04.html) 和 [wayland-book](https://wayland-book.com/introduction.html).

## 设计

Linux 内核提供了对硬件的抽象，以便它们可以在用户空间被操作（Waylnad 混成器正是工作在用户空间）。

## 协议

### 基本原则

Wayland 协议是一个异步的面向对象的协议。任何请求都是对某个对象的方法调用。每个请求包括唯一标识 server 上某个对象的 object ID。每个对象都绑定了一个接口，请求将包含一个 opcode 来标识要调用接口的哪个方法。

协议是基于消息的。一个由 client 发给 server 的消息被称为请求（request），一个 server 发给 client 的消息被称为事件（event）。一个消息包含一些参数，每个参数都有一个特定的类型（见 Wire Format 一节）。

server 向 client 发送事件，每个事件从一个 object 中 emit。事件可以是一个 error。事件包含 object ID 和 event opcode，从它们中 client 可以推断事件的类型。事件可以是对请求的响应（这种情况下请求和事件构成了一个 round trip），或是当 server 状态改变时自发地发送。

- 状态在连接（connect）时广播，事件在状态改变时发送。client 必须监听这些状态变化并缓存状态。没有必要（也没有办法）去查询 server 状态。
- server 会广播一些全局对象，它们会依次广播它们的当前状态

### Wire Format

协议通过一个 UNIX stream socket 发送，其 endpoint 通常叫做 `wayland-0` （虽然其能够通过 `WAYLAND_DISPLAY` 环境变量来改变）。这个 socket 文件默认位于 `$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY`。从 wayland 1.15 开始，协议的实现能够通过设定 `WAYLAND_DISPLAY` 为一个绝对路径来指定任意路径下的 socket。

每个消息以 32 bits 的字来划分，值采用 host 的字节序（如在 x86 上为小端）表示，消息的头部有两个字：

- 第一个字是发送者的 object ID
- 第二个字有两部分，前 16 bits 表示消息的大小（包含头部，即最小为 8），后 16 bits 是事件/请求的 opcode

payload 描述了请求/事件的参数，每个参数总是对齐到 32 bits。当 padding 需要时，padding 字节的值是未定义的。参数中将不会描述值的类型，类型是由 xml 规范中推断的。

参数的类型有：

- `int, uint` 32-bit 有符号/无符号整数
- `fixed` 有符号十进制数（是 IEEE 754 浮点数吗？）
- `string` 前 32-bit 为 uint 表示的长度（包括 null terminator），后接字符串内容，后接 padding。null 值用长度 0 表示
- `object` 32-bit object ID，null 值用 0 表示
- `new_id` 32-bit object ID，其代表了一个新对象的创建。通常来说，新对象使用的接口会从 xml 的推断，但在其未指定的情况下，`new_id` 之后会接一个 `string` 来指定接口的名字，和一个 `uint` 来指定版本
- `array` 前 32-bit 为数组长度，后跟 arrry 的内容，最后是 padding
- `fd` 文件描述符，其不存储在消息中，而在 socket 的辅助数据中（msg_control），选择 UNIX socket 作为底层协议的原因之一就是为了能够传输 fd

### enum

协议可以指定 enums，其关联了特定的枚举值，它们主要是出于描述的目的，在 wire format 中 enums 仅仅是整数类型。但同时它们也能在各个语言的 binding 中促进类型安全或是提供一些上下文。后一种作用只能在不破坏向后兼容的情况下进行，也就是说添加一个 enum 不能 break API。

enum 可以被定义成整数或是 bitfields，这通过 enum 定义中的 bitfield boolean 属性进行区分，如果这个属性为 true，那么这个 enum 将使用位运算来操作。如果是 false 或被省略，那么它就是一串数字。enum 可以被用于 int 或 uint 参数中，然而当其被定义为 bitfield 时，它只能被用于 uint 参数。

### 代码生成

接口、请求和事件定义在 `protocol/wayland.xml` 中，这个 xml 用来生成可用于 client 和 compositor 中的函数的原型。

### 版本

每个接口有对应的版本号，每个 object 实现一个特定的版本。对于全局对象，server 支持的最大版本在 global 中广播，创建的对象的实际版本由传给 `wl_registry.bind()` 的 version 参数决定。

## 通信过程

Object ID 为 1 的对象总是 wayland display 单例对象（singleton），client 通过这个对象来 bootstrap 其他对象。具体而言，我们在建立连接后会请求 display 对象的 `get_registry` 方法，其返回一个 `wl_registry` 对象，该对象通过 `wl_registry::global(name: uint, interface: string, version: uint)` 事件发送当前 compositor 中的支持的所有全局对象。我们再调用 `wl_registry::bind` 方法通过名称（一个 uint）创建一个新对象。

## 实践

aw-watcher-window-wayland 这个项目用了一个老版本的 wayland-rs 库，所以我计划先把它 port 到最新版本。由于这个项目用了一个 kwin 不兼容的 wayland 协议，我还需要启动另一个 compositor 来进行测试，经过测试直接运行 `sway` 或 `weston` 都可以在当前桌面环境下启动一个新的 compositor，好评！

libwayland 这个库包含两部分：libwayland-client 和 libwayland-server，它们包含了对 wire protocol 的实现，一些操作 wayland 数据结构的常用工具，一个简单的事件循环等。

设置 `WAYLAND_DEBUG` 环境变量可以打印出 socket 通信的过程。