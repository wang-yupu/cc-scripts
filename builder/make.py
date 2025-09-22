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


class ReplaceTo(Enum):
    current = 1
    sthInBuildBase = 2


class BuildStep:
    state: BuildStatus
    size: int
    finalFileName: str

    def __init__(self, scriptDir: Path, script: str, buildDir: Path, distDir: Path, minify=True) -> None:
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
        current = ""
        steps: list[tuple[list[str | ReplaceTo | tuple[ReplaceTo, str]], str, str]] = [
            (["haxe", "-cp", 'src/scripts', '-cp', 'src/libs', '--lua', (ReplaceTo.sthInBuildBase, "haxe.lua"), '-D', 'lua-vanilla', '-dce', 'full', '-main', f'{script}.Main'], "Haxe -> Lua", "haxe.lua"),
            (["echo", "d"], "捆绑多个Lua文件", "haxe.lua"),
        ]
        if minify:
            steps.append((["luasrcdiet", ReplaceTo.current, '-o', (ReplaceTo.sthInBuildBase, "minify.lua"), "--opt-locals", "--opt-whitespace", '--opt-eols'], "简化Lua文件", 'minify.lua'),)

        for step in steps:
            logging.info(f"正在进行: {step[1]} (使用 '{current}')")
            cmds: list[str] = []
            for i in step[0]:
                if isinstance(i, str):
                    cmds.append(i)
                elif isinstance(i, ReplaceTo):
                    match i:
                        case ReplaceTo.current:
                            cmds.append(str(buildBase/current))
                        case _:
                            logging.fatal("错误的构建命令定义！(4)")
                            quit(1)
                elif isinstance(i, tuple):
                    if len(i) < 2:
                        logging.fatal("错误的构建命令定义！(1)")
                        quit(1)
                    if isinstance(i[0], ReplaceTo) and isinstance(i[1], str):
                        match i[0]:
                            case ReplaceTo.sthInBuildBase:
                                cmds.append(str(buildBase/i[1]))
                            case _:
                                logging.fatal("错误的构建命令定义！(3)")
                                quit(1)
                    else:
                        logging.fatal("错误的构建命令定义！(2)")
                        quit(1)
            logging.info(f"命令: {' '.join(cmds)}")
            logging.info(f"将输出文件: {step[2]}")

            r = su.Subprocess(cmds)
            v = r.read()
            if r.getReturn() != 0:
                logging.error(f"构建步骤失败（返回值不为0: {r.getReturn()}）")
                print(v)
                self.state = BuildStatus.Failed
                return
            current = step[2]

        finalFile = (buildBase/current)
        distFile = (distDir/f"{script}_{meta.version}.lua")
        shutil.copyfile(finalFile, distFile)

        self.size = finalFile.stat().st_size
        self.state = BuildStatus.Success
        self.finalFileName = current
