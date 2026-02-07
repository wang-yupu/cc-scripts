import subprocess
import threading


class Subprocess:
    process: subprocess.Popen | None
    executeableFound: bool

    def __init__(self, command: list[str], stdout=None) -> None:
        try:
            self.process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE if stdout is None else stdout,
                stderr=subprocess.PIPE,
                text=True
            )
            self.executeableFound = True
        except FileNotFoundError:
            self.executeableFound = False

    def executeableExists(self) -> bool:
        return self.executeableFound

    def read(self) -> str:
        if not self.executeableFound:
            raise Exception("No executeable found!")
        if self.process:
            out, err = self.process.communicate()
            out = "" if out is None else out
            return out+err
        else:
            raise Exception("No process!")

    def getReturn(self) -> int:
        if self.process:
            return self.process.returncode
        else:
            raise Exception("No process!")


class backgroundSubprocess(Subprocess):
    def __init__(self, command: list[str]) -> None:
        threading.Thread(target=self.run, args=(command,)).start()

    def run(self, command: list[str]):
        super().__init__(command)
