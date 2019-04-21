---
title: Arch Linux 安装小记
date: 2019-3-24 20:12:51
tags:
- Linux
---

## 前言

以前我也装过双系统，很遗憾，可能是知识水平不够的缘故，也有笔记本坑爹的原因，装过 Ubuntu，Manjaro，Deepin，Fedora 等众多发行版，要么启动时候卡死，要么根本无法引导，于是作罢。如今开始学习 Linux，便有了重拾双系统的念头。

这篇博客将记录 Arch 安装与配置全过程。最终目标是 Arch 能成为我的主力系统替代 Windows。

<!-- more -->

下面列出笔记本的配置，以供参考。

| 部件     | 型号                                        |
| -------- | ------------------------------------------- |
| CPU      | Intel i5-7300HQ                             |
| 内存     | 16G                                         |
| 硬盘     | 128G NVME SSD + 1T 机械                     |
| 显卡     | GeForce GTX 1050 Ti + Intel HD Graphics 630 |
| 无线网卡 | Reltek RTL8822BE                            |
| 触摸板   | Synaptics                                   |



## 基本安装

安装参考了 [以官方Wiki的方式安装ArchLinux](https://www.viseator.com/2017/05/17/arch_install/) 和 官方Wiki的 [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。在未安装图形界面前，基本一切顺利。

题外话：说起无线网卡，之前装 Ubuntu 的时候，没有驱动，需要手动安装。不过内核从 4.x 某个版本之后，加入了对我这个网卡的驱动，现在无需配置即可使用了。

由于固态的空间不足，故没有分配交换文件（感觉也用不掉 16G 内存）。

在配置`sudo`时，使用`visudo`命令编辑配置文件，然而这个 vi编辑器有毒，许多操作都无法执行，感觉是个 bug。

## 图形界面

~~众所周知~~，Linux社区似乎对于 Nvidia+Intel 双显卡不怎么友好，在我安装过的数个发行版中（包括 Ubuntu, Debian, Manjaro, Deepin），基本都出现了启动黑屏/在Logo处冻结的情况，本次安装 Arch Linux，同样遇到了此问题。

由于我准备使用双系统，所以并不准备安装 Nvidia 驱动，仅安装了 Intel 的显卡驱动。

在装完 Xorg，KDE，sddm 之后，我尝试启动图形界面，成功卡在了 KDE 加载的地方。在随后的尝试中，我发现连 `screenfetch`, `lspci` 这样的命令都会导致系统/虚拟控制台（tty）无响应。一开始觉得是内核的问题，因为 Arch 默认安装了 5.0 内核，遂降级至 4.20，问题依旧。

搜索发现问题可能与N卡的开源驱动 `Nouveau`有关，（我寻思我也没装nouveau啊），于是创建 `/etc/modprobe.d/blacklist.conf`，并在文件中写入`blacklist nouveau`，执行 `update-initramfs -u`（大概是更新内核配置？）。顺便安装`bbswitch`把N卡给禁了。

重启问题解决，于是又把内核升到 5.0.2，重启卡在命令行界面（甚至没有见到 sddm）。于是进 live cd，回滚 4.20，重启问题解决。至今不明原因。

话说以后可以试试 Wayland？

### 目前遇到的问题

* 为什么任务栏有两个音量图标？

## 必要软件

* Arch Linux CN 源，包含了许多 AUR 中的软件。第一次加入源的时候不知道要安装 keyring，导致安装包时卡在了  GPG 签名校验那一步。我还寻思为什么 Arch 的签名老出锅。。（BTW：为什么需要 keyring？）
* Shadowsocks，装完命令行版的 Shadowsocks，根据 Wiki 描述，应用 `ss-local`启动，然而`commend not found`，未能解决，于是又装了 Shadowsocks-qt5。
* Chrome，ArchCN 源中有。
* 字体，不安装中文字体许多中文字是框框（然而为什么不是所有呢），我选择了`wqy-microhei`，然而系统自带的英文字体也很丑。。找时间换掉。
* 中文输入法

