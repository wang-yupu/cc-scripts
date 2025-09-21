# 构建工具
import logging
import pathlib

import builder.argparser as argparse
import builder.CUDWatchdog as cw
import builder.ensureEnviroment as enviroment
import builder.loggerUtil as loggerUtil
import builder.luaDependenciesChecker as ldc
import builder.make as make

LUA_DEPENDENCIES = [
    "nbt"
]

LUA_MODULES_DIR = pathlib.Path("./lua_modules")
BUILD_DIR = pathlib.Path("./build")
DIST_DIR = pathlib.Path("./dist")
SCRIPTS_DIR = pathlib.Path("./src/scripts")
LIBS_DIR = pathlib.Path("./src/libs")
WATCHDOG_WATCH_DIR = pathlib.Path("./src")


def build(script: str) -> bool:
    make.BuildStep(SCRIPTS_DIR, script, BUILD_DIR, DIST_DIR)
    return True


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
    logging.log(25, f"开始构建 :: {args.script}")
    loopMode = args.debug
    if loopMode:
        wd = cw.CUDWatchdog(WATCHDOG_WATCH_DIR)
        logging.info("启动循环构建模式")
        while True:
            logging.info("正在构建")
            build(args.script)
            logging.log(25, "构建成功")
            wd.wait()
            logging.info("检测到文件有修改")
    else:
        build(args.script)

    logging.log(25, "构建成功")
