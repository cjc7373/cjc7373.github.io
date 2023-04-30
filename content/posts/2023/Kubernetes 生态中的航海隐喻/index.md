---
title: Kubernetes 生态中的航海隐喻
date: 2023-04-30
---

> Disclaimer: 本文的结论大多是根据名字推断出来的，并没有得到项目开发者的证实。

Kubernetes 在 2014 年 9 月发布，在这之前 Docker 已经大行其道了。Docker 发布于 2013 年，意为码头工人，其 logo 是个鲸鱼驮着一些集装箱。

![File:Docker (container engine) logo.svg](./610px-Docker_(container_engine)_logo.svg.png)

后来这个 Logo 又变得扁平了一点：

![File:Docker logo.svg](./512px-Docker_logo.svg.png)

很显然这个名字和和 Logo 都与集装箱（container，即容器）有关。

Kubernetes 这个名字来源于古希腊语 κυβερνήτης，意为舵手（steersman）/领航员（pilot）/船长（captain）。其 logo 是一个舵轮的形状。身为一个容器编排系统，Kubernetes 负责着一艘船的航向，倒也合理。

{{< figure src="617px-Kubernetes_logo_without_workmark.svg.png" width="200px">}}

值得一提是和 Kubernetes 共享词源 κυβερνήτης 的还有 governor（州长/统治者/主管）和 cybernetics（控制论）。

Helm 官方的 slogan 是 Kubernetes 的包管理器，helm 意为舵轮，logo 和 Kubernetes 类似，也是一个舵轮的形状。

{{< figure src="helm.svg" width="200px">}}

在 Helm 2 时代，helm 还需要一个部署在集群内的组件 tiller 才能工作。tiller 似乎是舵柄的意思，它和舵直接相连。下图展示了一个舵柄和舵轮的区别：

{{< figure src="1280px-Tiller_and_helm_orders.svg.png" width="300px">}}

Argo 项目包含了 CD/Workflows/Rollouts 等一系列项目，总体是和应用交付、CI/CD 相关。在希腊神话中，Argo （阿尔戈号）是一艘船，由伊阿宋等希腊英雄在雅典娜帮助下建成，众英雄乘该船取得金羊毛。此后阿尔戈号作为进献雅典娜的祭品被焚毁，南船座（Argo Navis, or simply Argo）由此而来。Navis 词源为古希腊语，意为船（ship）。但是 Argo 的 logo （应该？）是一只章鱼，很奇怪的联系..

{{< figure src="argo.svg" width="200px">}}

cert-manager，虽然名字和航海没什么关系，但它的 logo 是一个锚..

{{< figure src="cert-manager.svg" width="200px">}}

上面说到 Argo 就是南船座，南船座本来是天空中最大的星座，但在十八世纪被拆分为四个单独的星座，其中之一为船帆座（Vela），所以 Kubevela 的 logo 是一艘帆船。Kubevela 同样属于负责应用交付的组件，和 ArgoCD 在功能上有重叠和互补的地方。

{{< figure src="kube-vela.svg" width="200px">}}

最后要说的是 Harbor，非常直白，就是港口，作为一个 container registry 也很合理，其 logo 是一个灯塔的形状。

{{< figure src="harbor.svg" width="200px">}}
