__author__ = 'afathali'
import logging


class log():

    def __init__(self):
        logging.basicConfig(filename='mindcloud.log', filemode='a',
            format='%(levelname)s: %(asctime)s -- %(message)s', level=logging.DEBUG)

    def info(self, msg):
        logging.info(msg)

    def warning(self, msg):
        logging.warning(msg)

    def debug(self, msg):
        logging.debug(msg)

