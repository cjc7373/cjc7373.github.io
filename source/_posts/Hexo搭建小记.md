---
title: Hexo搭建小记
date: 2018-10-13 20:10:18
tags:
- Hexo
---

> 身为一个懒人，又不会写网页，也只能用用博客生成器了。

<!-- more -->

## 为什么选择Hexo

其实也没啥特别的理由。一开始想把博客搭在自己的服务器上，然而感觉维护太麻烦了，正好觉得Github Pages很不错，就决定用了。Github Pages只支持静态页面，WordPress之类的就不能用了，于是~~随手找了几个静态博客生成器，~~ 随手一查就找到了Hexo。

## Hexo搭建过程

Hexo的官方文档有中文，这点很赞。虽然官方文档讲的不是很清楚..然而搭建还是比较简单的，加上Google了几篇教程，很快就把Hexo搭起来了。

身为一个博客生成器，当然不能让我们接触到代码了。所以Hexo的基本配置均在`_config.yml`这个配置文件中。配置采用YAML语法，看看官方文档也就差不多了解了。基本上无需过多配置就搭建完成了。

## Hexo主题

Hexo有许多主题，个人采用了官方推荐的 [NexT.Pisces](https://github.com/iissnan/hexo-theme-next)主题，整体风格还是比较简洁的（然而用这个主题的实在是太多了...随便一个Hexo博客就是Next主题）。

同时主题内已集成了许多第三方服务，如Google Analysis、DISQUS等，只要改改配置文件就能配置完成，还是相当简单的。

## Hexo图片插入指引

直接用Markdown语法引用图片会导致图片在首页无法显示，官网给出了一个解决方案，就是利用内置的插件，形式如下：

```
{% asset_path slug %}
```

然而这个方法会破环原生Markdown语法，对编辑者的预览等造成不便。

很奇怪官方为什么要采用这种方法。

更好的解决方案是安装[**hexo-asset-image**](https://github.com/CodeFalling/hexo-asset-image)这个插件。进入博客目录，使用如下命令安装插件：

```
npm install https://github.com/CodeFalling/hexo-asset-image --save
```

安装完成后，即可使用原生Markdown语法插入图片。

## To Do

##### 已实现功能

* 评论，采用DISQUS
* 数据统计，采用Google Analytics
* 图片显示在首页
* 搜索引擎收录，Google Search Console
* 首页文章不显示全部
* git配置，`hexo g -d`一条命令部署

##### 待实现功能

* 使用Travis CI自动生成及部署
* 更多的自定义操作
* 文章访问量统计
* 在自己的服务器也部署博客，然后用 CI 实现自动部署
* 使用 CDN 加速 Github Pages 的访问
* 评论点击加载

## 参考文章

[hexo中完美插入本地图片](http://etrd.org/2017/01/23/hexo%E4%B8%AD%E5%AE%8C%E7%BE%8E%E6%8F%92%E5%85%A5%E6%9C%AC%E5%9C%B0%E5%9B%BE%E7%89%87/)

[为HEXO博客中每篇文章的浏览量统计](https://gaodaxiu0406.github.io/2017/08/21/%E4%B8%BAHEXO%E5%8D%9A%E5%AE%A2%E4%B8%AD%E6%AF%8F%E7%AF%87%E6%96%87%E7%AB%A0%E7%9A%84%E6%B5%8F%E8%A7%88%E9%87%8F%E7%BB%9F%E8%AE%A1/)

[Hexo官方文档](https://hexo.io/zh-cn/docs/)

[NexT使用文档](https://theme-next.iissnan.com/)

[theme-next!Hexo网站的一次华丽升级](http://moweide.com/2017/08/27/hexo_next_started/)