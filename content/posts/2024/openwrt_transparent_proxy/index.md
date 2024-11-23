---
title: OpenWrt 搭建透明代理
date: 2024-11-24
lastmod: 2024-11-24
tags:
- Networking
---

openclash、shellclash 之类的方案感觉都太复杂了。我的需求只是给 chromecast 用上代理，所以想找一个简单的方案。

经过一番摸索，发现 Macvlan 很适合我，具体步骤如下：

- 创建一个 macvlan 设备

  ```openwrt
  config device
          option type 'macvlan'
          option ifname 'br-lan'
          option mode 'bridge'
          option name 'br-lanmac0'
          option ipv6 '1'
  ```

  注意这里需要选择启用 ipv6，否则 br-lan 不会下发 RA，导致局域网内设备没有 v6 地址，具体原因还不清楚。

- 创建一个接口绑定到这个设备

  ```openwrt
  config interface 'clash'
          option proto 'static'
          option device 'br-lanmac0'
          option ipaddr '192.168.2.2'
          option netmask '255.255.255.0'
          option gateway '192.168.2.1'
          option defaultroute '0'
  ```

  IP 地址分配一个在局域网段下的，网关填 lan 地址。注意关闭默认路由，否则会把 PPPoE 的路由给删了，导致局域网内设备连不上网，具体原因也不清楚。

- 下载 mihomo （原 clash-meta）二进制，配置 tun 绑定到之前的设备上

  ```yaml
  tun:
    enable: true
    stack: system
    auto-route: true
    auto-redirect: true
    include-interface:
    - br-lanmac0
  ```

- 写入 init 脚本到 `/etc/init.d/clash`，以便开机自启

  ```bash
  #!/bin/sh /etc/rc.common
   
  START=99
   
  start() {        
          export HOME=/root
          nohup /root/clash/clash > /root/clash/log.txt &
          # commands to launch application
  }                 
   
  stop() {          
          # commands to kill application 
                  killall clash
  }
  
  ```

  启用脚本 `/etc/init.d/clash enable`。

- 在需要代理的设备上指定网关为 `192.168.2.2`

然后，就没有然后了。它工作！具体为什么能工作呢，咱也不知道...