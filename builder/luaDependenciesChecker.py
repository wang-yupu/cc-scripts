#
import logging
from pathlib import Path

import builder.subprocessUtil as su
from builder.ensureEnviroment import Version


class LuaDependenciesChecker:
    def __init__(self, luaMoudlesDir: Path, luaDependencies: list[str], luaVersion: Version) -> None:
        logging.info("正在检查Lua依赖")
        currentLuaMoudlesDir = luaMoudlesDir / Path("share/lua") / Path(f"{luaVersion.major}.{luaVersion.minor}")
        if not currentLuaMoudlesDir.is_dir():
            logging.error(f"{currentLuaMoudlesDir} 不是一个目录")
            quit(1)
        logging.info(f"Lua库路径: {currentLuaMoudlesDir}")

        unfoundedLuaMoudles = set()
        unfoundedLuaMoudles.update(luaDependencies)
        for m in currentLuaMoudlesDir.glob("*.lua"):
            if m.stem in unfoundedLuaMoudles:
                unfoundedLuaMoudles.remove(m.stem)
        if len(unfoundedLuaMoudles) != 0:
            logging.warning("缺少依赖")
            for m in unfoundedLuaMoudles:
                su.Subprocess(['luarocks', 'install', m, '--tree', './lua_modules'])
        else:
            logging.log(25, "全部依赖皆检查通过")
