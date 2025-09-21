import logging
import random
import time


def initLogger(enableFileLog=False, debug=True):
    # 初始化日志
    old_factory = logging.getLogRecordFactory()

    def record_factory(*args, **kwargs):
        record = old_factory(*args, **kwargs)
        record.attach = ''
        if record.levelno == 10:
            record.color = '\033[36m'
            record.levelname = 'DEBUG'
        elif record.levelno == 20:
            record.color = '\033[0m'
            record.levelname = 'INFO'
        elif record.levelno == 30:
            record.color = '\033[33m'
            record.levelname = 'WARN'
        elif record.levelno == 40:
            record.color = '\033[31m'
            record.levelname = 'ERROR'
        elif record.levelno == 50:
            record.color = '\033[1;30;41m'
            record.levelname = 'FATAL'
        elif record.levelno == 0:
            record.color = '\033[35m'
            record.levelname = '???'
        elif record.levelno == 25:
            record.color = '\033[32m'
            record.levelname = 'SUCCESS'
        else:
            record.color = "\033[95m"
            record.levelname = '???'
        return record

    logging.setLogRecordFactory(record_factory)

    logger = logging.getLogger()
    logger.setLevel(0 if debug else 20)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(0 if debug else 20)
    formatter = logging.Formatter(
        '%(color)s[%(levelname)s][%(asctime)s] %(message)s \033[0m%(attach)s', datefmt='%Y-%m-%d %H:%M:%S')
    file_formatter = logging.Formatter(
        '[%(levelname)s][%(asctime)s] %(message)s %(attach)s', datefmt='%Y-%m-%d %H:%M:%S')
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    if enableFileLog:
        currentTime = time.strftime('%Y%m%d_%H%M%S', time.localtime(time.time()))
        file_handler = logging.FileHandler(f"{currentTime}_{hex(random.randint(0, 8192)).replace('0x', '')}.log")
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)

    return logger
