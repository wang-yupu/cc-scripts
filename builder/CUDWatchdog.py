import logging
import time
from threading import Event

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer


class CUDWatchdogInternal(FileSystemEventHandler):
    event: Event

    def __init__(self, event: Event) -> None:
        super().__init__()
        self.event = event

    def on_created(self, event):
        if event.is_directory:
            return
        logging.info(f"文件创建: {event.src_path}")
        self.event.set()

    def on_modified(self, event):
        if event.is_directory:
            return
        logging.info(f"文件修改: {event.src_path}")
        self.event.set()

    def on_deleted(self, event):
        if event.is_directory:
            return
        logging.info(f"文件删除: {event.src_path}")
        self.event.set()


class CUDWatchdog():
    event: Event

    def __init__(self, path) -> None:
        self.event = Event()
        self.event.clear()

        self.eventHandler = CUDWatchdogInternal(self.event)
        self.observer = Observer()
        self.observer.schedule(self.eventHandler, path, recursive=True)
        self.observer.daemon = True
        self.observer.start()

    def wait(self) -> None:
        self.event.wait()
        time.sleep(0.4)
        self.event.clear()
