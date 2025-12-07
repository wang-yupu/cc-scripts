
# wangyupu 的 **CC:Tweaked** 脚本仓库

> **Warning**
> 一切都是WIP，任何API随时可能改动

此仓库存储了我给CC:T写的各种小脚本，以及：对CC API的抽象调用与GUI库和构建工具链。

## 脚本列表

- `example` 用于演示和驱动开发，不在仓库提供
- `ae2_spatial_manager` 可视化快速切换多个空间元件
- `monitor_example` 演示SGUI库
- `clock` 红石时钟
- `fmt_example` 假多线程演示

## 构建脚本
<!--
> 所有脚本都在`cct-scripts.wangyupu.com`下提供原始版本和安装器版本。

安装器: `https://cct-scripts.wangyupu.com/scripts/<脚本名>/installer.lua`
`startup.lua`: `https://cct-scripts.wangyupu.com/scripts/<脚本名>/startup.lua`
-->

### 安装工具链软件

#### 通过包管理器

##### Arch Linux

`sudo pacman -Syu haxe lua luarocks python nodejs`

#### 然后你需要做

`luarocks install luasrcdiet`
`npm install -g luabundler` / `pnpm i -g luabundler`
`pip install -r requirements.txt`

> 注：确保`luasrcdiet`、`luabundler`和`luarocks`都能被执行（可执行文件在PATH中）
