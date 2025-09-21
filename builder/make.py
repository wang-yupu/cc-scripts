#
import json
import logging
import shutil
from dataclasses import dataclass
from pathlib import Path

import builder.subprocessUtil as su
from builder.ensureEnviroment import Version
from enum import Enum


@dataclass
class Metadata:
    name: str
    description: str
    version: Version


class BuildStatus(Enum):
    NoMain = 0,
    Failed = 1,
    Success = 999


class BuildStep:
    state: BuildStatus

    def __init__(self, scriptDir: Path, script: str, buildDir: Path, distDir: Path) -> None:
        # 检查是否存在那个脚本
        scriptRoot = scriptDir / Path(script)
        if not scriptRoot.exists():
            logging.fatal("目标脚本不存在")
            quit(1)
        scriptMeta = scriptRoot / "meta.json"
        scriptMain = scriptRoot / "Main.hx"

        meta = Metadata(script, f"Missing description for: {script}", Version(0, 0, 0))
        if not scriptMeta.exists():
            logging.warning("目标脚本缺少元数据文件，将自动补全元数据")
        else:
            try:
                metaRaw: dict[str, str] = json.loads(scriptMeta.read_text())
                meta.name = metaRaw.get("name", script)
                meta.description = metaRaw.get("description", f"Missing description for: {script}")
                meta.version = Version.fromString(metaRaw.get("version", "0.0.0"))
            except:
                logging.warning("目标脚本元数据文件读取失败，将自动补全元数据")
        if not scriptMain.exists():
            logging.fatal("目标脚本没有`Main.hx`")
            self.state = BuildStatus.NoMain
            return

        buildBase = buildDir / script
        if not buildBase.exists():
            buildBase.mkdir()
        steps: list[tuple[list[str], str]] = [
            (["haxe", "-cp", 'src/scripts', '-cp', 'src/libs', '--lua', str(buildBase/"a.lua"), '-D', 'lua-vanilla', '-dce', 'full', '-main', f'{script}.Main'], "Haxe -> Lua"),
            (["echo", "d"], "捆绑多个Lua文件"),
            (["luasrcdiet", str(buildBase/"a.lua"), '-o', str(buildBase/"final.lua"), "--opt-locals", "--opt-whitespace", '--opt-eols', '--opt-numbers', '--opt-strings'], "简化Lua文件"),
        ]

        for step in steps:
            logging.info(f"正在进行: {step[1]}")
            r = su.Subprocess(step[0])
            v = r.read()
            if r.getReturn() != 0:
                logging.error(f"构建步骤失败（返回值不为0: {r.getReturn()}）")
                print(v)
                self.state = BuildStatus.Failed
                return

        finalFile = (buildBase/"final.lua")
        distFile = (distDir/f"{script}_{meta.version}.lua")
        shutil.copyfile(finalFile, distFile)

        self.state = BuildStatus.Success
