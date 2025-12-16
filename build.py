#!/usr/local/python
# 构建工具
import logging
import pathlib

import builder.argparser as argparse
import builder.CUDWatchdog as cw
import builder.ensureEnviroment as enviroment
import builder.loggerUtil as loggerUtil
import builder.luaDependenciesChecker as ldc
import builder.make as make
import builder.afterbuildProcessor as abp
import builder.subprocessUtil as sp

LUA_DEPENDENCIES = [
    "nbt"
]

LUA_MODULES_DIR = pathlib.Path("./lua_modules")
BUILD_DIR = pathlib.Path("./build")
DIST_DIR = pathlib.Path("./dist")
SCRIPTS_DIR = pathlib.Path("./src/scripts")
LIBS_DIR = pathlib.Path("./src/libs")
WATCHDOG_WATCH_DIR = pathlib.Path("./src")
AFTERBUILD_CONFIG = pathlib.Path("./afterbuild.json")

CC_DEFAULT_SIZE_LIMIT_COMPUTER = 1000000
CC_DEFAULT_SIZE_LIMIT_FLOPPY = 125000
CC_DEFAULT_MAX_UPLOAD_SIZE = 524288


def build() -> tuple[bool, int]:
    m = make.BuildStep(SCRIPTS_DIR, args.script, BUILD_DIR, DIST_DIR, args.minify, not args.disableBundle, args.debugLogs, args.hc_server_port)
    if m.state == make.BuildStatus.Failed:
        return False, 0
    elif m.state == make.BuildStatus.NoMain:
        quit(1)
    if args.runAfterBuild and args.afterBuildID is not None:
        abp.AfterBuildProcessor(AFTERBUILD_CONFIG, args.afterBuildID).process(args.script, BUILD_DIR, m.finalFileName)
    return True, m.size


if __name__ == "__main__":
    # region: 基本
    loggerUtil.initLogger(debug=False)
    args = argparse.ArgumentParser()
    logging.warning("START")

    if not BUILD_DIR.exists():
        BUILD_DIR.mkdir()
    if not DIST_DIR.exists():
        DIST_DIR.mkdir()
    # region: 环境检查
    if not args.skipEnviromentCheck:
        enviromentCheckResult = enviroment.EnviromentChecker.check()
        if not enviromentCheckResult:
            logging.error("环境检查失败！")
            quit(1)
        # endregion
    _, luaVersion = enviroment.EnviromentChecker.checkSingle(["lua", "-v"], enviroment.Version(0, 0, 0))
    if luaVersion is None or isinstance(luaVersion, str):
        logging.error("无法获取Lua版本")
        quit(1)

    # region: Lua依赖
    logging.info("开始构建")
    if not args.skipLuaDependenciesCheck:
        ldc.LuaDependenciesChecker(LUA_MODULES_DIR, LUA_DEPENDENCIES, luaVersion)
    # region: 构建
    # Haxe 编译服务器
    haxeCompilerServerPort: str = args.hc_server_port
    if args.debug and (args.hc_server_port != None):
        if haxeCompilerServerPort.isdigit() and int(haxeCompilerServerPort) >= 0 and int(haxeCompilerServerPort) <= 65535:
            sp.backgroundSubprocess(["haxe", "--wait", haxeCompilerServerPort])
            logging.info("启动 Haxe 编译服务器加速后续构建...")
            args.hc_server_port = int(haxeCompilerServerPort)
        else:
            logging.warning("无效的 Haxe 编译服务器的监听端口端口")
            args.hc_server_port = -1
    logging.log(25, f"开始构建 :: {args.script}")
    loopMode = args.debug
    if loopMode:
        wd = cw.CUDWatchdog(WATCHDOG_WATCH_DIR)
        logging.info("启动循环构建模式")
        while True:
            logging.info("正在构建")
            s, size = build()
            if s:
                logging.log(25, f"构建成功，文件大小 {size}B")
            else:
                logging.warning("构建失败")
            wd.wait()
            logging.info("检测到文件有修改")
    else:
        args.hc_server_port = -1
        s, size = build()
        if s:
            logging.log(25, f"构建成功，文件大小 {size}B")
            if size > CC_DEFAULT_SIZE_LIMIT_COMPUTER*0.9:
                logging.warning(f"构建结果接近或超过默认计算机磁盘大小，可能无法写入计算机")
            if size > CC_DEFAULT_SIZE_LIMIT_FLOPPY*0.95:
                logging.warning(f"构建结果接近或超过默认软盘大小，可能无法写入软盘")
            if size > CC_DEFAULT_MAX_UPLOAD_SIZE*0.9:
                logging.warning(f"构建结果接近或超过默认上传大小限制，可能无法拖动上传")
        else:
            logging.warning("构建失败")
