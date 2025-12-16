#
import json
import logging
import shutil
from dataclasses import dataclass
from pathlib import Path
import re
from typing import Optional

import builder.subprocessUtil as su
from builder.ensureEnviroment import Version
from enum import Enum


def replaceAllNonASCII(s: str) -> str:
    return re.sub(r'[^\x00-\x7F]', '?', s)


@dataclass
class Metadata:
    name: str
    description: str
    version: Version
    enableFMT: bool
    nameEN: str
    descriptionEN: str


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

    def __init__(self, scriptDir: Path, script: str, buildDir: Path, distDir: Path, minify: int = 2, bundle=True, debugLogs=True, hcServerPort=-1) -> None:
        self._scriptDir = scriptDir
        self._script = script
        self._buildDir = buildDir
        self._distDir = distDir
        self._doMinify = minify
        self._doBundle = bundle
        self._debugLogs = debugLogs
        self._hcServerPort = hcServerPort

        try:
            self._checkBasics()
            self._processMetadata()
            self._processSteps()
            self._runCommands()
            self._doFinal()
        except Exception as error:
            logging.error(f"构建出现内部错误: {error}")
            self.state = BuildStatus.Failed
            return

    _script: str
    _scriptDir: Path
    _scriptMain: Path
    _scriptMeta: Path
    _buildDir: Path
    _distDir: Path
    _buildBase: Path

    _steps: list[tuple[list[str | ReplaceTo | tuple[ReplaceTo, str]], str, str, Optional[bool]]]
    _meta: Metadata
    _doBundle: bool
    _doMinify: int
    _debugLogs: bool
    _hcServerPort: int

    _madeFileName: str

    def _checkBasics(self):
        # 检查是否存在那个脚本
        scriptRoot = self._scriptDir / Path(self._script)
        if not scriptRoot.exists():
            logging.fatal("目标脚本不存在")
            raise Exception()
        self._scriptMeta = scriptRoot / "meta.json"
        self._scriptMain = scriptRoot / "Main.hx"

        self._buildBase = self._buildDir / self._script
        if not self._buildBase.exists():
            self._buildBase.mkdir()

    def _processMetadata(self):
        self._meta = Metadata(self._script, f"Missing description for: {self._script}", Version(0, 0, 0), False, self._script, f"Missing description for: {self._script}")
        if not self._scriptMeta.exists():
            logging.warning("目标脚本缺少元数据文件，将自动补全元数据")
        else:
            try:
                metaRaw: dict[str, str] = json.loads(self._scriptMeta.read_text())
                self._meta.name = metaRaw.get("name", self._script)
                self._meta.description = metaRaw.get("description", f"Missing description for: {self._script}")
                self._meta.version = Version.fromString(metaRaw.get("version", "0.0.0"))
                self._meta.enableFMT = bool(metaRaw.get("fmt", False)) if isinstance(metaRaw.get("fmt", ""), bool) else False
                # 处理两个英语字段
                if not metaRaw.get("nameEN", None):
                    self._meta.nameEN = replaceAllNonASCII(self._meta.name)
                else:
                    r: str = metaRaw.get("nameEN", self._script)
                    if not r.isascii():
                        logging.warning("脚本元数据的nameEN字段包含非ASCII字符，已自动转换")
                    self._meta.nameEN = replaceAllNonASCII(r)
                if not metaRaw.get("descriptionEN", None):
                    self._meta.descriptionEN = replaceAllNonASCII(self._meta.description)
                else:
                    r: str = metaRaw.get("descriptionEN", self._script)
                    if not r.isascii():
                        logging.warning("脚本元数据的descriptionEN字段包含非ASCII字符，已自动转换")
                    self._meta.descriptionEN = replaceAllNonASCII(r)
            except:
                logging.warning("目标脚本元数据文件读取失败，将自动补全元数据")
        if not self._scriptMain.exists():
            logging.fatal("目标脚本没有`Main.hx`")
            self.state = BuildStatus.NoMain
            return

    def _processSteps(self):
        self._steps = []
        haxeGenericArgs = [
            "-cp", "src/scripts",
            "-cp", "src/libs",
            '--lua', (ReplaceTo.sthInBuildBase, "haxe.lua"),
            '-D', 'lua-vanilla',
            "-dce", 'full',

        ]
        if self._debugLogs:
            haxeGenericArgs.extend(["-D", "debug"])
        haxeMetaArgs = []
        haxeMetaFields = {
            "version_major": self._meta.version.major,
            "version_minor": self._meta.version.minor,
            "version_patch": self._meta.version.patch
        }

        for k, v in haxeMetaFields.items():
            haxeMetaArgs.append("-D")
            haxeMetaArgs.append(f"{k}={v}")
        haxeGenericArgs.extend(haxeMetaArgs)
        if self._hcServerPort >= 0:
            haxeGenericArgs.extend(["--connect", str(self._hcServerPort)])
        if self._meta.enableFMT:
            self._steps.append((["haxe", *haxeGenericArgs, '-main', f'fmt.FMTMain', '-D', f'fmtmain={self._script}.Main'], "Haxe -> Lua", "haxe.lua", False))
        else:
            self._steps.append((["haxe", *haxeGenericArgs, '-main', f'{self._script}.Main'], "Haxe -> Lua", "haxe.lua", False))
        if self._doBundle:
            self._steps.append((["luabundler", "bundle", ReplaceTo.current, "-o", (ReplaceTo.sthInBuildBase, "bundled.lua"), "-p", "src/native"], "捆绑多个Lua文件", "bundled.lua", False))
        if self._doMinify == 2:
            self._steps.append((["luasrcdiet", ReplaceTo.current, '-o', (ReplaceTo.sthInBuildBase, "minify.lua"), "--opt-locals", "--opt-whitespace", '--opt-eols', '--noopt-binequiv', '--noopt-srcequiv'], "简化Lua文件", 'minify.lua', False),)
        if self._doMinify == 1:
            self._steps.append((["luamin", "-f", ReplaceTo.current], "简化Lua文件", 'minify.lua', True),)

    def _runCommands(self):
        current: str = ""
        for step in self._steps:
            if current:
                logging.info(f"正在进行: {step[1]} (使用 '{current}')")
            else:
                logging.info(f"正在进行: {step[1]} (首个步骤)")
            cmds: list[str] = []
            for i in step[0]:
                if isinstance(i, str):
                    cmds.append(i)
                elif isinstance(i, ReplaceTo):
                    match i:
                        case ReplaceTo.current:
                            cmds.append(str(self._buildBase/current))
                        case _:
                            logging.fatal("错误的构建命令定义！(4)")
                            raise Exception()
                elif isinstance(i, tuple):
                    if len(i) < 2:
                        logging.fatal("错误的构建命令定义！(1)")
                        raise Exception()
                    if isinstance(i[0], ReplaceTo) and isinstance(i[1], str):
                        match i[0]:
                            case ReplaceTo.sthInBuildBase:
                                cmds.append(str(self._buildBase/i[1]))
                            case _:
                                logging.fatal("错误的构建命令定义！(3)")
                                raise Exception()
                    else:
                        logging.fatal("错误的构建命令定义！(2)")
                        raise Exception()
            logging.info(f"命令: {' '.join(cmds)}")
            logging.info(f"将输出文件: {step[2]} {'(启用stdout重定向)' if step[3] else ''}")

            redir = None
            if step[3]:
                redir = (self._buildBase / step[2]).open("w+")

            r = su.Subprocess(cmds, redir)
            v = r.read()
            if r.getReturn() != 0:
                logging.error(f"构建步骤失败（返回值不为0: {r.getReturn()}）")
                print(v)
                self.state = BuildStatus.Failed
                raise Exception()
            current = step[2]

        self._madeFileName = current
        logging.info(f"构建流程结束，输出文件: {self._madeFileName}")

    def _doFinal(self):
        finalFile = (self._buildBase/self._madeFileName)
        distFile = (self._distDir/f"{self._script}_{self._meta.version}.lua")
        shutil.copyfile(finalFile, distFile)

        self.size = finalFile.stat().st_size
        self.state = BuildStatus.Success
        self.finalFileName = self._madeFileName
