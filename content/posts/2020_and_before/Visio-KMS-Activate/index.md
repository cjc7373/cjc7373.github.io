---
title: 使用KMS激活Visio
date: 2018-12-01 23:11:38
lastmod: 2018-12-01 
tags:
- KMS
- Office
---


## 题记

如果你懒的话当然可以用KMSpico等工具一键激活，但博主不想电脑里多个启动项，并且博主的电脑预装了Office2013家庭与学生版，用此类工具可能出现不可预知的后果，所以打算自己动手激活Visio。

<!-- more -->

## 转换Visio版本

我在[MSDN我告诉你](http://msdn.itellyou.cn/?lang=zh-cn)和某非著名PT站上并没有找到Visio的VL（批量授权）版本，然而KMS激活需要VL版，所以第一步是转换Visio的版本。

复制以下代码，保存为.bat文件并用管理员身份运行：

```shell
if exist "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" cd /d "%ProgramFiles%\Microsoft Office\Office16"
if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" cd /d "%ProgramFiles(x86)%\Microsoft Office\Office16"
cscript ospp.vbs /rearm
for /f %%x in ('dir /b ..\root\Licenses16\visio???vl_kms*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
for /f %%x in ('dir /b ..\root\Licenses16\visio???vl_mak*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
```

以上命令的作用分别为：

* 打开Office的安装目录（Visio也属于Office的一部分）
* 重置零售激活
* 安装KMS和MAK许可证（转换版本）

题外话：转换Office和Project版本同理。

Office：

```
cscript ospp.vbs /rearm
for /f %%x in ('dir /b ..\root\Licenses16\proplusvl_kms*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
for /f %%x in ('dir /b ..\root\Licenses16\proplusvl_mak*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
```

Project：

```
cscript ospp.vbs /rearm
for /f %%x in ('dir /b ..\root\Licenses16\project???vl_kms*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
for /f %%x in ('dir /b ..\root\Licenses16\project???vl_mak*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%%x" >nul
```

再跑下题，为什么要用批处理呢，因为这段命令直接在cmd里执行会出错，博主没学过Shell无法理解。（留下了没有知识的泪水）



## 设置KMS密钥及服务器

打开Office的安装目录，也就是代码里的`%ProgramFiles%\Microsoft Office\Office16\`（64位）或者`%ProgramFiles(x86)%\Microsoft Office\Office16\`（32位）。

按住Shift+右键，选择在此处打开PowerShell，输入：

```powershell
cscript ospp.vbs /inpkey:PD3PC-RHNGV-FXJ29-8JK7D-RJRJK
```

来安装KMS密钥。注意以上命令中的KMS密钥只适用与Visio2016，其他版本可到[微软官方文档](https://docs.microsoft.com/zh-cn/DeployOffice/vlactivation/gvlks)中查询。

然后设置KMS服务器，博主用的是网上找的，以后尝试一下自己搭一个：

```
cscript ospp.vbs /sethst:xxx.xxx
```

由于不保证可用性，服务器名称已略去。

指令Office立即连接KMS服务器进行激活：

```
cscript ospp.vbs /act
```

完成！

## 参考资料

[https://03k.org/kms.htm](https://03k.org/kms.html)

[https://segmentfault.com/a/1190000015697457](https://segmentfault.com/a/1190000015697457)

[https://blog.csdn.net/ywd1992/article/details/79412991](https://blog.csdn.net/ywd1992/article/details/79412991)