---
title: 记一次 mpv 异常关闭的调试
date: 2023-12-10
lastmod: 2025-03-24
tags:
- Linux Desktop
---

（EDIT 2025-03-24：这个 Bug 发生的环境是一加 8T+Oxygen OS，在我更换至 LineageOS 之后这个问题没有再出现过了。所以大概率是一加的锅..）

## 查不出的问题

长久以来我都被 mpv 的一个问题所困扰，那就是在正常播放视频时 mpv 有概率会自动退出（通常是按下暂停键的时候）。通过 `-v -v -v` 参数查看详细日志发现 mpv 接收到了 stop 命令：

```bash
[cplayer] Run command: stop, flags=64, args=[flags=""]
```

但是这个命令是谁发的不得而知。一开始怀疑是插件的问题，然而禁用所有插件（`~/.config/mpv/scripts` 目录）后问题依旧。后尝试用 `--no-config` 参数禁用所有配置，发现问题消失，于是尝试注释掉所有 `mpv.conf` 中的配置，发现问题依旧。我还怀疑过是 `pipewire`/`xorg` 的问题，但是并没有搜索到相关信息。

我还观察到 vlc 是不是也会出现播放时自动停止的现象，另外 youtube/bilibili 播放视频时会经常自动跳转到开头。后来证实这其实都是同一个问题导致的..

## 线索

在 mpv 的 issue 中找到了一个问题相同的 [bug report](https://github.com/mpv-player/mpv/issues/11988)，开发者认为这是插件导致的，但是我已经禁用所有插件了，于是我留言询问应该如何排查，有一个人指出了可能和 `mpv-mpris` 有关。

[MPRIS](https://wiki.archlinux.org/title/MPRIS) 是一个 dbus 接口，提供了控制媒体播放器的相应 API，绝大多数应用，包括上述提到的几个，都支持这一接口。mpv 的 mpris 支持通过 `mpv-mpris` 包提供。看到这个名字我恍然大悟，`mpv-mpris` 由系统包管理器安装，因此并没有出现在用户的插件目录下。当即我查看了 `mpv-mpris` 的源码，发现其为 mpv C 拓展，而不是常见的 Lua 拓展。

从[这里](https://github.com/hoyon/mpv-mpris/blob/16fee38988bb0f4a0865b6e8c3b332df2d6d8f14/mpris.c#L602C26-L602C26)可以看到，它在收到 mpris 的 `Stop()` 方法后，会向 mpv 发送 stop 命令，因此我准备加一行日志看看到底是不是 `mpv-mpris` 导致了上述问题。询问了 ChatGPT 之后发现其对于如何在 mpv C 扩展中打印日志完全是在瞎扯.. 后来发现直接用 `printf` 就行.. 从函数签名可以看到其包含了 sender 的信息，于是将其打印。这里我并没有 clone 仓库进行构建，而是直接复制 archlinux 中的 PKGBUILD，先用 `makepkg -o` 下载解压源码，修改后再用 `makepkg -e` 进行构建，这样做的好处是无需关心具体的构建流程以及如何应用构建后的插件，build 完直接装就行。

在复现问题之后发现果然是 `mpv-mpris` 调用了 stop 命令，日志为：

```bash
mpris: sender: :1.41, _object_path: /org/mpris/MediaPlayer2, interface_name: org.mpris.MediaPlayer2.Player, method_name: Stop, parameters: ()
```

继续询问 ChatGPT 如何从 `:1.41` 这个标识符得到发送者的进程，这次它倒没有瞎扯，告诉我 dbus 包含一个内省方法：

```bash
$ dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID string:":1.41"
method return time=1702192468.323155 sender=org.freedesktop.DBus -> destination=:1.2850 serial=3 reply_serial=2
   uint32 1688
```

再用 ps 等命令查看，发现该进程为 kdeconnect。直接上 bugs.kde.org 搜索得到一个类似的 [bug report](https://bugs.kde.org/show_bug.cgi?id=476123)，不过除了作者没有人回应。

翻找源码发现大概是在 [mpriscontrolplugin.cpp#L284](https://invent.kde.org/network/kdeconnect-kde/-/blob/master/plugins/mpriscontrol/mpriscontrolplugin.cpp#L284) 调用的 mpris Stop 方法，去掉注释重新编译后查看日志发现如下条目：

```text
kdeconnect.core: TCP connection done (i'm the existing device)
kdeconnect.core: Starting server ssl (I'm the client TCP socket)
kdeconnect.core: Socket successfully established an SSL connection
kdeconnect.core: It is a known device "xxxx"
kdeconnect.plugin.mpris: Calling action "Stop" in "org.mpris.MediaPlayer2.mpv"
kdeconnect.plugin.notification: Not found noti by internal Id:  "0|org.kde.kdeconnect_tp|-1850276765|null|10264"
kdeconnect.plugin.mpris: MPRIS service "org.mpris.MediaPlayer2.mpv" just went offline
kdeconnect.plugin.mpris: Mpris removePlayer "org.mpris.MediaPlayer2.mpv" -> "mpv"
```

基本能够确认是从这里进行调用的了。根据函数推断该函数是处理配对的其他设备发送的请求，出问题时我配对的设备只有我的安卓手机，所以问题应该出在安卓端。看了眼 kdeconnect-android 的源码，看不懂啊... 本次 debug 到此结束。

由于 vlc/chromium 同样实现 mpris 接口，所以上面观察到的现象基本可以确认也是 kdeconnect 导致的了。

## 怎么办呢？

目前的 workaround 是关闭 KDE Connect 中的 Multimedia control receiver 插件，drawback 是其他设备无法再控制本机的媒体播放器了，不过我也不怎么用，问题不大。
