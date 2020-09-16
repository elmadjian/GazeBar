import sys
import subprocess
import socket
import numpy as np
from pynput.keyboard import Key, Controller, KeyCode
from threading import Thread
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QUrl, QObject, Signal, Slot


class ToolbarManager(QObject):

    update_position = Signal(int, int)

    def __init__(self):
        QObject.__init__(self)
        self.stop = False
        subprocess.Popen(['./stream/streamer.exe'])
        self.sock = self.create_connection('127.0.0.1', 9998)
        self.stream_thread = None
        self.keyboard = Controller()
        self.tools = self._populate_tools()
        self.curr_key = None

    def create_connection(self, ip, port):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind((ip, port))
        return sock

    def stream_data(self):
        self.stream_thread = Thread(target=self._stream_loop, args=())
        self.stream_thread.start()

    def _stream_loop(self):
        while not self.stop:
            data,_ = self.sock.recvfrom(1024)
            data = data.decode().replace(',','.')
            coord = data.split('~')
            x, y = float(coord[1]), float(coord[2])
            self.update_position.emit(x,y)

    def _populate_tools(self):
        tools = {
            "brush": 'b',
            "bucket": 'f',
            "crop": 'c',
            "geo": [Key.ctrl, Key.alt, '.'],
            "select": [Key.ctrl, 'r'],
            "eraser": ['b','e'],
            "move": 't',

            "brush1": [Key.ctrl, Key.alt, KeyCode.from_vk(97)],
            "brush2": [Key.ctrl, Key.alt, KeyCode.from_vk(98)],
            "brush3": [Key.ctrl, Key.alt, KeyCode.from_vk(99)],
            "brush4": [Key.ctrl, Key.alt, KeyCode.from_vk(100)],
            "brush5": [Key.ctrl, Key.alt, KeyCode.from_vk(101)],
            "brush6": [Key.ctrl, Key.alt, KeyCode.from_vk(102)],
            "brush7": [Key.ctrl, Key.alt, KeyCode.from_vk(103)],

            "geo1": [Key.ctrl, Key.alt, '.'],
            "geo2": [Key.ctrl, Key.alt, ';'],
            "geo3": '',
            "geo4": '',
            "geo5": '',

            "selection1": [Key.ctrl, 'r'],
            "selection2": 'j',
            "selection3": '',
            "selection4": [Key.ctrl, Key.alt, ']']

        }
        return tools

    @Slot(str)
    def update_tool(self, tool_id):
        #pass
        if self.curr_key == "eraser":
            self.keyboard.press('e')
            self.keyboard.release('e')
        self.curr_key = tool_id
        key = self.tools[tool_id]
        if len(key) == 1:
            self.keyboard.press(key)
            self.keyboard.release(key)
        else:
            for k in key:
                self.keyboard.press(k)
            for k in reversed(key):
                self.keyboard.release(k)




#==========================================
if __name__=='__main__':
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    toolbar_manager = ToolbarManager()
    toolbar_manager.stream_data()
    
    engine.rootContext().setContextProperty("toolbarManager", toolbar_manager)
    engine.load(QUrl("painting_tool.qml"))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
