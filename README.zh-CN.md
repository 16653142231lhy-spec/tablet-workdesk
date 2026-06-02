# Tablet Workdesk

Tablet Workdesk 把 Android 平板变成一个轻量 Linux 办公/开发桌面。

它使用 Termux、Debian proot、TigerVNC、noVNC 和 AVNC/Chrome。目标用户是预算有限、手里有 Android 平板和键盘，但暂时没有完整笔记本电脑的学生或开发者。

## 这个项目解决什么

- 在 Android 平板上启动一个可重复安装的 Debian + XFCE 桌面。
- 提供 `office` 这样的日常命令，尽量减少手动配置。
- 默认使用 VNC/noVNC/AVNC 路线，避免部分设备上 Termux:X11 输入不稳定的问题。
- 默认只监听本机 `127.0.0.1`，降低 VNC 暴露风险。
- 默认 pin noVNC 和 websockify 的上游版本，减少“今天能装、明天坏掉”的问题。
- 支持 `standard` 和 `minimal` 安装 profile。

## 安装

完整英文安装说明见 [docs/INSTALL.md](docs/INSTALL.md)。

如果你在 Windows 电脑上有 ADB：

```powershell
.\scripts\deploy-to-tablet.ps1 -OpenTermux
```

然后在 Termux 中运行：

```sh
bash /sdcard/Download/tw.sh
```

低容量设备可以尝试最小安装：

```sh
TABLET_WORKDESK_PROFILE=minimal bash /sdcard/Download/tw.sh
```

也可以手动把 `scripts/install-tablet-workdesk.sh` 放到平板的 `/sdcard/Download/tw.sh`，再运行同一条命令。

## 日常使用

启动桌面：

```sh
office
```

停止：

```sh
office-stop
```

查看状态：

```sh
office-status
```

直接 VNC 备用路线：

```sh
office-vnc
```

卸载命令包装和应用状态：

```sh
office-uninstall
```

## 当前状态

这是项目的早期公开版本。现在最需要的是：

- 真实设备兼容报告。
- 低内存设备的安装 profile。
- 更完整的故障排查文档。
- 截图和短视频演示。

如果你在自己的设备上试过，欢迎提交 device report issue。
