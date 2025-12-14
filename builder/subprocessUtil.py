import subprocess
import threading


class Subprocess:
    process: subprocess.Popen | None
    executeableFound: bool

    def __init__(self, command: list[str]) -> None:
        try:
            self.process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            self.executeableFound = True
        except FileNotFoundError:
            self.executeableFound = False

    def executeableExists(self) -> bool:
        return self.executeableFound

    def read(self) -> str:
        if self.process:
            out, err = self.process.communicate()
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
