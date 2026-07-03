# 在这里安装 [SideInstaller](https://frizzlem.github.io/SideInstaller/)

<img width="589" height="1209" alt="29EF8C23-3D7A-42CB-B95F-F1D11461442F_1_201_a" src="https://github.com/user-attachments/assets/600987fd-e294-4e6f-86ee-59a181bd2010" />

SideStore 和 LiveContainer 目前仍然是 iOS 上最实用的侧载方案之一，但传统安装方式往往需要电脑。SideInstaller 的目标就是把这条链路搬到手机端：在 iPhone / iPad 上直接完成配对、签名、安装，不再强依赖 PC。

这个分支额外做了两件事：
- 去掉“必须 LocalDevVPN”的硬编码限制，改为支持任意**能把 `10.7.0.1` 环回到本机**的后端；
- 将主要用户界面汉化，方便直接使用。

## 要求
- 一台 iPhone / iPad（项目原始目标为 iOS 27）
- Wi‑Fi 或热点网络
- 任意可将 `10.7.0.1` 回环到本机的后端，例如：LocalDevVPN、clashmi、anywhere

## 使用方法
1. 先启用任意可用的环回后端，确保 `10.7.0.1:49152` 能回到本机
2. 打开安装页并用任意可用证书安装 SideInstaller
3. 安装完成后打开 SideInstaller
4. 登录你的 Apple ID
5. 点击“安装 SideStore”或“安装 SideStore + LiveContainer”
6. 按提示完成配对、签名与安装

## 安全性
SideInstaller 的核心逻辑仍然是本地执行，源码公开可审计。Apple ID 凭据用于本地签名流程，不是为了创建云端账户或做数据收集。你可以直接查看源码确认实际行为。
