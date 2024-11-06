---
title: The 2022 Python Language Summit
date: 2022-05-23
---

每年, 在 PyCon US 的前夕, 30 多位 Python 的核心开发者将会聚集起来召开 Python 语言峰会. 今年的会议在 5/11 召开, 让我们来看看今年讨论了什么吧. 有关会议的详情可在 [PSF Blog](https://pyfound.blogspot.com/2022/05/the-2022-python-language-summit_01678898482.html) 中找到.

## CPython 的 issue 和 PR 积压
首先祝贺一下前不久 [bpo](https://bugs.python.org) 正式退休了, Python 的 issue tracker 迁移到了 Github, 无论是易用性还是审美上来说都是一件好事.

随着 Python 的流行, issues 和 PRs 也开始累积起来了, 在 2022/05/07 时, CPython 有着 7,027 个 open issues 和 1,471 个 PRs. Python 开发者们向来对关闭一个 issue 持谨慎态度. 以低质量的功能请求 (feature requests) 为例, 我们可以粗略地把它们分为三类:
- 没有任何意义的, 或显然有不利影响的, 它们能被轻易地关闭
- 会增加维护成本, 但似乎有点好处的, 对于它们的意见通常会很摇摆
- 每个人都觉得是好的, 但没人愿意真正去实现它.. 这些 issues 通常会存在很久, 如 [BPO-539907](https://github.com/python/cpython/issues/36387), 一个存在了二十年的 issue.

开发者 Katriel 认为, 把这些 issues 留在 issue tracker 上是有害的, 增加了整个项目的维护成本. 有关这一论断, 一种极端的做法是关闭所有不活跃的 issues, 当然这是不可取的, 可以参看 [GitHub stale bot considered harmful](https://drewdevault.com/2021/10/26/stalebot.html).

与会者们认为这一问题没有简单的答案, 但增加 triage 的人力显然是一种办法, CPython triage 团队目前在逐渐壮大, 这是好事. PEP 594 计划移除一些年久失修的标准库, 这也能缓解一些问题.

## 没有 GIL 的 Python
GIL 是 CPython 中一个臭名昭著的特性, 它也被开发者们翻来覆去地讨论了. 今年, 这一传统得到延续, 开发者 Sam Gross 讨论了 [nogil](https://github.com/colesbury/nogil), 一个移除 GIL 的 Proof of Concept.

移除 GIL 意味着为了保证线程安全, 需要加入许多 locks, 这非常困难, 而且会影响单线程性能.

Gross 希望能在 Python 3.12 中加入一个编译选项来禁用 GIL. 与会者对其表示了支持, 但许多问题还有待考虑, 如这一巨大的更改如何合并入主线, 其对第三方库的影响, 对于 CPython 开发的影响等.

我个人感觉移除 GIL 还是不太现实的..

## 每个解释器一个 GIL
在 1997 年, CPython 加入了 `PyInterpreterState` 结构体, 这使得多个解释器能运行在一个进程中.

然而, 多个解释器之间并不是完全隔离的, 许多共享的全局变量通过 GIL 来实现互斥访问. 开发者 Eric Snow 希望每个解释器能有一个自己的 GIL 来解决这一问题, 这同样能够使子解释器之间实现真正的并行. 到目前为止, 仍然存在着约 1200 个全局变量.
Snow 认为这一工作和 Gross 的移除 GIL 不是互斥的, "这些工作不管在哪里都是一个好主意", 他说.

目前子解释器只能通过 C-API 使用, [PEP 554](https://peps.python.org/pep-0554/) 提出了在 Python 中使用子解释器, 然而该 PEP 仍处于草案状态.

我表示并不是很懂子解释器的意义所在... 或许是方便共享数据? 多进程之间通信是要求一个对象可序列化的..

## Faster Python
好消息! 好消息! Python 3.11 相比于 3.10 会有平均 25% 的性能提升!

一年之前, 微软出钱, 组建了 Faster CPython 团队, 由开发者 Mark Shannon 和 Python 之父~~廖雪峰~~ Guido van Rossum 领导来做性能优化. Shannon 分享了他们接下来的计划.
第一个问题是测量. 我们首先要知道 Python 在哪些地方慢, 为什么慢, 才能做针对性的性能优化. 为此, 我们需要更多的~~跑分~~基准测试 (benchmarks), Shannon 希望更多人能去贡献 [pyperformance](https://github.com/python/pyperformance) 项目.

3.11 的很大一部分改进来自于 PEP 659, "专门化的自适应解释器", 简而言之是在执行时用更快的字节码去替代原有的字节码. PEP 659 仍有待继续推进.

Shannon 也谈到了 JIT, "每个人都想要一个 JIT 编译器, 即使这毫无意义", 像 [pyjion](https://github.com/tonybaloney/Pyjion) 这样的项目用第三方库的形式把 JIT 带到了 CPython 中, 然而在 CPython 中本身集成 JIT 可能要等到 3.13 之后了.

## Python 和浏览器
在过去两年间, 60 多个和 WebAssembly 相关的 PR 合入了主线. 如今, `main` 分支已经能够成功交叉编译成 wasm 了.
WebAssembly 是一种低级的类汇编语言, 能够达到和原生机器代码相近的性能. 而 wasm 是机器无关的.

这一 feature 仍然是高度实验性的, 许多模块在 wasm 下是不可用的.
除了 CPython 之外, 一众第三方项目如 PyScript, Pyodide 已经能更好地支持 wasm 了.

## 在语法中应用 f-strings
在 Python 3.6 中引入的 f-strings 迅速成为了大家最喜爱的新 features 之一.

`f"Interpolating an arbitrary expression into a string: {1 + 1}."`

在运行时, 大括号中的表达式会被执行, 然后 `str()` 会被调用, 最后的结果会被插入合适的位置.

然而, f-strings 目前的实现是 1,400 行 C 代码, 和其他 Python 代码的 Parsing 逻辑完全分离. 这带来了可维护性上的问题和许多隐藏的 bug.

Python 3.9 带来了全新的 PEG parser, 能够实现许多复杂的 parsing. 开发者 Pablo Galindo Salgado 希望能把 f-strings 的 parsing 结合到 CPython 的语法中.

比如以下问题:
```bash
>>> my_list_of_strings = ['a', 'b', 'c']
>>> f'Here is a list: {"\n".join(my_list_of_strings)}'
  File "<stdin>", line 1
    f'Here is a list: {"\n".join(my_list_of_strings)}'
                                                      ^
SyntaxError: f-string expression part cannot include a backslash
```
在新方案下将会不存在.

## 从 Cinder 合并回上游
在 2021 年 5 月, Instagram 团队开源了 Cinder, 这是 CPython 的一个以性能为目标的 fork. Cinder 包括了 "协程的及早求值", 一个 JIT 编译器, 利用了 type hints 的"实验性的字节码编译器"等 features. (我一直以为 type hints 完全是静态检查, 翻了翻 PEP 发现运行时类型检查以及可能的利用类型进行性能优化是可以接受的)

Instagram 的工程师 Itamar Ostricher 分享了 async 和协程相关的更改, 并希望这些更改能合并回上游.
一个例子:
```python
import asyncio


async def IO_bound_function():
    """This function could finish immediately... or not!"""
    # Body of this function here


async def important_other_task():
    await asyncio.sleep(5)
    print('Task done!')


async def main():
    await asyncio.gather(
        IO_bound_function(),
        important_other_task()
    )
    print("All done!")


if __name__ == "__main__":
    asyncio.run(main)    
```

如果 `IO_bound_function` 能立即返回的话, 创建一个协程就毫无意义了. Ostricher 的团队扩展了 [vectorcall](https://docs.python.org/3/c-api/call.html#the-vectorcall-protocol) 协议, 使得被调用者能够知道这次调用是否被调用者 `await` 了. 这意味着 `awaitables` (可被 `await` 的对象) 能够被*及早求值*, 多余的协程不会被创建了. Ostricher 的团队在重度使用 `async` 的场景下观察到了 ~5% 的性能提升.

这个改动能否被合入主线呢? 一个重要的问题是公平性. 如果某些 `awaitables` 能被及早求值, 那么可能会使事件循环中的优先级发生改变, 可能会造成不向后兼容的更改. 同时, 其对于 3.11 中 asyncio *task groups* 的影响也尚不明确.

## 达到永恒
在 Python 中, 任何东西是一个对象. 所有对象都维护了自己的引用计数, 以便进行垃圾回收. 这就意味着不可变对象在 C 的层次上是可变的, 这会影响 CPU 和内存性能. 例如 `None` 对象经常被使用, 对其引用计数的更改也非常多.

[PEP 683](https://peps.python.org/pep-0683/) 提出了 "永恒的对象 (Immortal objects)", 它们的运行时状态不会改变, 即引用计数不会到达 0, 也不会被垃圾回收.

这是一个 CPython 内部的 feature, 即公开 API 不会改变.
与会者们提出了一些怀疑, 比如它的好处是否只是潜在的, 以及改变引用计数的语义会带来第三方库的兼容性问题. 目前该 PEP 仍处于草案状态.

我并没有理解这个 PEP 的好处在哪.. 目前的实现在回归测试中导致了 ~2% 的性能损失..

## 尾巴
本次会议很大程度上讨论了 Python 的性能改善, 然而大多数变化是琐碎且渐进的, 想要看到某个改动带来的性能飞跃似乎不太可能 ~~(除了 GIL)~~. 我们希望去年 Language Summit 上 Guido 吹下的牛── 4 年里将 CPython 的性能提升 5 倍──能够实现吧.	