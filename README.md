
# wangyupu 的 **CC:Tweaked** 脚本仓库

此仓库存储了我给CC:T写的各种小脚本，其中还包含一个对基本API进行抽象的包，以及一个工具链。

## 构建脚本

> 所有脚本都在`cct-scripts.wangyupu.com`下提供压缩版本和无压缩版本和安装器版本。

### 安装工具链软件

#### 通过包管理器

##### Arch Linux

`sudo pacman -Syu haxe lua luarocks python node`

#### 然后你需要做

`luarocks install uasrcdiet`
`npm install -g luabundler` / `pnpm i -g luabundler`

## 工具链介绍

Lua的语法有点怪，因此选择了[Haxe](https://haxe.org/)编译为Lua后
