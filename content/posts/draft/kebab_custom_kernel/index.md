---
title: 为 LineageOS 编译自定义内核
date: 2025-10-21
lastmod: 2025-10-21
draft: true
tags:
- Android
---

## 问题

在我的一加 8T 更新到 LineageOS 23 之后，总是会出现随机的死机（freeze），表现为屏幕卡死，触屏、按键无反应。此时只能通过长按音量上+电源键强制重启。一天之中能出现个三四次。

在使用 adb logcat 抓取日志后发现，死机前后通常伴随着 kernel 的 oom killer 启动。至于其他信息我也看不懂。

在 LineageOS Discord 频道中询问过后，一位开发者给出了 `adb shell settings put global cached_apps_freezer disabled` 这样一条指令，似乎是禁用 Android 的缓存进程冻结机制。这个设置有一点用，使问题的出现频率降到了大概一天一次，但是问题还在。

在 issue tracker 中，已经有人报过了 [issue](https://gitlab.com/LineageOS/issues/android/-/issues/9475)，一位开发者在某个回复中称 “since I have no idea what introduced this issue I started git bisect for the last git merge”。综合上述信息问题应该和内核有关。在等待其结果的同时我决定自行开始 git bisect。

## 编译内核

我可以编译整个系统，里面当然包含了内核。然而根据[官方 wiki](https://wiki.lineageos.org/devices/kebab/build/variant1/) 编译整个系统大约需要 300 GB 的硬盘空间。于是我打算只编译内核。在查找了几篇博客后发现这事并不复杂。

首先需要下载工具链，也就是交叉编译所需的 gcc 和 clang。一些博客指出较新的内核只需要 clang 即可，为了确保没有问题我两个都下了。LineageOS 预编译了这几个工具链供大家使用，可以在 LineageOS/android 仓库的 [snippets/lineage.xml](https://github.com/LineageOS/android/blob/lineage-23.0/snippets/lineage.xml) 文件中查找 android_prebuilts 开头的仓库，其中下面几个是我们所需的仓库：

- android_prebuilts_clang_kernel_linux-x86_clang-r416183b
- android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9
- android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9

注意确认对应的分支和 lineage.xml 中的 revision 匹配。

TODO：什么是 defconfig？https://stackoverflow.com/questions/41885015/what-exactly-does-linux-kernels-make-defconfig-do

运行如下脚本：

```bash
BASEDIR=$(PWD)/../

make mrproper
mkdir -p out

make \
  O=out \
  ARCH=arm64 \
  vendor/kona-perf_defconfig vendor/oplus.config

GCCDIR=$BASEDIR/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9
GCCDIR32=$BASEDIR/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9
CLANGDIR=$BASEDIR/android_prebuilts_clang_kernel_linux-x86_clang-r416183b

make \
  O=out \
  ARCH=arm64 \
  PATH=$CLANGDIR/bin:$GCCDIR/bin:$PATH \
  LD_LIBRARY_PATH=$CLANGDIR/lib \
  LLVM=1 \
  CROSS_COMPILE=$GCCDIR/bin/aarch64-linux-android- \
  CROSS_COMPILE_ARM32=$GCCDIR32/bin/arm-linux-androideabi- \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  -j$(nproc)

```

编译完成后，运行如下脚本打包 boot.img：

```bash
set -x
echo "clean up"
rm boot-new.img
rm -r out

IMG_FORMAT=$(unpack_bootimg --boot_img boot.img --format mkbootimg)
echo "Image format: \"$IMG_FORMAT\""

unpack_bootimg --boot_img boot.img
cp /home/cjc/Github/3rd/lineageos/android_kernel_oneplus_sm8250/out/arch/arm64/boot/Image out/kernel

eval "mkbootimg $IMG_FORMAT -o boot-new.img"

```



## 参考

- [编译LineageOS以及自定义内核（LOS 21.0）](https://faint.day/zh/blog/build-lineageos-custom-kernel/)
- [Android 搞机之编译 lineageOS 内核](https://bitibiti.com/2023/10/24/Android%20%E6%90%9E%E6%9C%BA%E4%B9%8B%E7%BC%96%E8%AF%91%20lineageOS%20%E5%86%85%E6%A0%B8/)
- [用 Nix 编译自定义 Android 内核](https://lantian.pub/article/modify-computer/build-custom-android-kernel-with-nix.lantian/)
- [davidgarland/lineageos_simple_kernel_build.md (gist)](https://gist.github.com/davidgarland/ae6da821016fde4c877973ddd3f8f116) (以及文中引用的一篇博客)
- https://github.com/osm0sis/mkbootimg/ (AUR 中下载)