# Pili Player

Pili Player 是一个面向 **MeeGo Harmattan** 的 Bilibili 客户端，使用 Qt/QML 和 C++ 编写。项目保留了原版 Harmattan 应用的界面与播放器实现，并包含登录、搜索、视频/番剧浏览、收藏、历史记录、直播及评论等功能模块。

> 本项目是非官方开源软件，与哔哩哔哩（Bilibili）及其关联公司没有隶属、赞助或授权关系。Bilibili 是其各自权利人的商标。

## 项目状态

这是一个面向旧设备和旧版 Qt 运行时的历史项目。现代 Linux/Windows 环境通常不能直接运行生成的程序；构建需要对应的 Harmattan SDK、Qt 4/QML 1 和设备/交叉编译工具链。网络接口也可能因 Bilibili 服务端变更而失效。

## 目录结构

- `src/`：C++ 网络、播放器和 Qt Multimedia 适配代码
- `qml/`：QML 界面、组件和 JavaScript API 封装
- `kmplayer++/`、`kmplayer++_src/`：播放器相关组件
- `i18n/`：翻译源文件和编译后的翻译文件
- `qtc_packaging/`：Qt Creator 使用的 Debian/Harmattan 打包模板

## 构建

1. 安装与目标设备匹配的 Harmattan SDK（包括 Qt 4、Qt Mobility、qmake、交叉编译器和 `zlib1g-dev`）。
2. 在 SDK 环境中打开 `ppsh.pro`，选择 Harmattan 目标并执行 qmake/构建：

   ```sh
   qmake ppsh.pro
   make
   ```

3. 如需生成 Debian 包，请在 Qt Creator 中启用影子构建，并使用 Harmattan 目标下的“创建Deb包”部署步骤。打包模板位于 `qtc_packaging/debian_harmattan/`。

   生成的 `.deb` 文件应在目标设备上安装，并使用与该设备匹配的运行时库。

## 使用与隐私

程序通过 Bilibili 的公开网页/API 获取内容。登录凭据和本地浏览数据由应用自身的旧版实现管理；使用前请阅读并遵守 Bilibili 的服务条款、隐私政策及所在地法律。项目维护者不保证接口持续可用，也不对第三方内容负责。

## 版权与许可证

Pili Player 主体代码版权声明如下：

```text
Copyright (C) 2014 karin <beyondk2000@gmail.com>
```

主体代码以 **GNU General Public License v2.0 or later（GPL-2.0-or-later）** 发布。完整许可证文本和 Debian 版权记录请参阅 [`qtc_packaging/debian_harmattan/copyright`](qtc_packaging/debian_harmattan/copyright)；源码树中第三方组件的作者、许可证和来源请参阅 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。第三方文件中的原有版权头和许可证条款必须保留，不能被本项目的主许可证声明替代。

提交修改时请在相应文件中保留原作者信息，并按 GPL 要求标注修改内容和日期。除许可证明确授予的权利外，本项目不授予任何商标、品牌或 Bilibili 内容的使用权。

## 免责声明

本软件按“现状”提供，不附带任何明示或暗示的保证。使用本软件访问网络服务、处理账号数据或播放第三方内容所产生的风险由使用者自行承担。

## 相关链接

- 原始项目：<https://github.com/glKarin/ppsh>
- GNU GPL：<https://www.gnu.org/licenses/gpl-2.0.html>
- 第三方声明：[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)
