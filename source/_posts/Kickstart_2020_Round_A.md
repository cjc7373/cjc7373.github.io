---
title: Kickstart 2020 Round A 题解
date: 2020-03-26 19:00:00
tags:
	- 算法
---

第一次打Kickstart，体验还是很不错的。

<!-- more -->

[比赛链接](https://codingcompetitions.withgoogle.com/kickstart/round/000000000019ffc7)

迟了几分钟进比赛，发现前十已经两题AC了。

## Allocation

`1/0 Accepted`

签到题，排序后从大到小输出即可。

## Plates

`2/0 TLE, WA`

N叠盘子，每叠K个，每个盘子有一个beauty值，从中取P个，但对于每叠只能从上到下取，求beauty值最大为多少。

先写了一个每次取最大的，WA，发现不对，然后去做第三题了。后又写了个dfs，TLE了。当时心态有点崩，因为TOP 10基本是两分钟AC，想到DP，但没有深入想。

官方题解是对于每一叠盘子，先预处理前n个的beauty值和sum，然后对于每一个状态`dp[i][j]`，即在前i叠盘子和取j个盘子时能取到的最大值，有状态转移方程`dp[i][j] = max(dp[i][j], sum[i][x]+dp[i-1][j-x])`。循环求dp即可。

```python

if __name__=='__main__':
    t = int(input())
    for i in range(1, t+1):
        out = "Case #{}: ".format(i)
        n, k, p = [int(i) for i in input().split()]
        a = []
        sum = []
        for i in range(n):
            a.append([int(i) for i in input().split()])
            sum.append([0])
            s = 0
            for j in a[i]:
                s += j
                sum[i].append(s)
        cur = [0 for i in range(n)]
        dp = [[0] * (p+1) for i in range(n)]
        dp[0] = sum[0] + [0] * (p-k)
        for i in range(1, n):
            for j in range(1, p+1):
                for x in range(min(j+1, k+1)):
                    dp[i][j] = max(dp[i][j], sum[i][x] + dp[i-1][j-x])
        ans = 0
        for i in range(n):
            ans = max(ans, dp[i][p])
        out += str(ans)
        print(out)
```

## Workout

`2/1 Accepted`

给一个递增的数列，插入K个值，求每两个值的差的最小值。

这道题和我校2017新生赛的一题类似，对结果二分即可。

## Bundling

`Not Attempted`

把N个字符串分成K组，每组的分数为最长公共前缀的长度，求全局最高分。

直接进行分组比较困难，我们可以考虑每组的分数同时也是共同前缀的个数。那么对于每个前缀，若有p个单词拥有这个前缀，则这个前缀会给结果贡献`p // K`分。由此求字符串中的每个前缀和拥有这个前缀的字符串数即可。

使用前缀树可很容易求得。一开始我的做法是递归这棵树，用了两种写法都RE了，Google了一圈找到测试数据会导致爆栈，故采用了list来模拟栈遍历。

```python
if __name__=='__main__':
    t = int(input())
    for i in range(1, t+1):
        out = "Case #{}: ".format(i)
        n, k = [int(i) for i in input().split()]
        tree = {'pre_num': 0}
        for i in range(n):
            word = input()
            cur = tree
            for c in word:
                cur = cur.setdefault(c, {'pre_num': 0})
                cur['pre_num'] += 1
        stack = [tree]
        s = 0
        while len(stack):
            node = stack.pop()
            s += node['pre_num'] // k
            for i in node:
                if i == 'pre_num': continue
                stack.append(node[i])
        out += str(s)
        print(out)

```

