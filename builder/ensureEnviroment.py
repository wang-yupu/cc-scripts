import logging
import re
from dataclasses import dataclass
from functools import total_ordering
import sys

import builder.subprocessUtil as su


@total_ordering
@dataclass
class Version:
    major: int
    minor: int
    patch: int

    @classmethod
    def fromString(cls, vr: str) -> 'Version':
        v: list[int] = list(map(int, vr.split(".")))
        v.extend([0, 0, 0])
        r = Version(v[0], v[1], v[2])
        return r

    def __eq__(self, other):
        if not isinstance(other, Version):
            if isinstance(other, str):
                other = Version.fromString(other)
            return NotImplemented
        return self.major == other.major and self.minor == other.minor and self.patch == other.minor

    def __lt__(self, other):
        if not isinstance(other, Version):
            if isinstance(other, str):
                other = Version.fromString(other)
            return NotImplemented
        return self.major < other.major and self.minor < other.minor and self.patch < other.minor

    def __str__(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"

    def __repr__(self) -> str:
        return str(self)


class EnviromentChecker:
    @classmethod
    def getVersion(cls, content: str) -> Version | None:
        pattern = r"\d+\.\d+\.\d+"
        match = re.search(pattern, content)
        if match:
            return Version.fromString(match.group(0))
        return None

    @classmethod
    def checkSingle(cls, command: list[str], required: Version) -> tuple[bool, Version | None | str]:
        v:Version | None = None
        content:str | None = None
        if command[0].startswith('DO_SPECIAL_CHECK'):
            if command[0] == "DO_SPECIAL_CHECK_PYTHON":
                v = Version(*map(int, tuple(sys.version_info)[0:3]))
                content = str(v)
        else:
            proc = su.Subprocess(command)
            if not proc.executeableExists():
                return False, None
            content = proc.read()
            v = EnviromentChecker.getVersion(content)
        if v is None:
            return True, content
        if v < required:
            return False, v
        return True, v

    @classmethod
    def check(cls) -> bool:
        logging.info("正在检查环境")
        items: list[tuple[list[str], Version, str]] = [
            (['lua', '-v'], Version(5, 4, 0), "Lua"),
            (['luarocks', '--version'], Version(3, 12, 0), "LuaRocks"),
            (['haxe', '--version'], Version(4, 3, 0), "Haxe 编译器"),
            (['luabundler', '--version'], Version(1, 2, 0), "LuaBundler"),
            (['luasrcdiet', '--version'], Version(1, 0, 0), "LuaSrcDiet"),
            (['python', '--version'], Version(3, 12, 0), "Python"),
            (['DO_SPECIAL_CHECK_PYTHON'], Version(3, 12, 0), "Python(Running)")
        ]

        failed = False
        for i in items:
            passed, v = EnviromentChecker.checkSingle(i[0], i[1])
            if passed:
                if v is None or isinstance(v, str):
                    logging.warning(f"{i[2]} - 可执行，但是无法解析版本 :: {v}")
                else:
                    logging.info(f"{i[2]} - 通过 :: {v}")
            else:
                failed = True
                if v is None:
                    logging.error(f"{i[2]} - 找不到")
                else:
                    logging.error(f"{i[2]} - 过旧的版本 :: {v}")

        return not failed
