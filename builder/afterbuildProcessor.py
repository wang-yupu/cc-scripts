#
import json
import logging
from pathlib import Path
from dataclasses import dataclass
import shutil


@dataclass
class AfterbuildConfig:
    ccDir: Path
    filename: str
    computerID: int


class AfterBuildProcessor:
    config: AfterbuildConfig

    def __init__(self, config: Path, computerID: int) -> None:
        if not config.exists():
            logging.fatal("Afterbuild配置不存在")
            quit(1)
        cfg: dict[str, str] = json.loads(config.read_text())
        if not cfg.get("ccDir") and cfg.get("name"):
            logging.fatal("Afterbuild配置缺少字段，需要字段: `ccDir`与`name`")
            quit(1)
        self.config = AfterbuildConfig(Path(cfg.get("ccDir", "")), cfg.get("name", ""), computerID)

    def process(self, script: str, buildDir: Path) -> None:
        logging.info("正在复制代码")
        src = buildDir / script / "final.lua"
        dest = self.config.ccDir / "computer" / str(self.config.computerID) / self.config.filename
        destDir = self.config.ccDir / "computer" / str(self.config.computerID)

        if not destDir.exists():
            destDir.mkdir()

        shutil.copyfile(src, dest)
        logging.info(f"成功将代码从 {src} 复制到 {dest}")
