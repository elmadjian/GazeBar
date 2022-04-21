import sys
import os
import subprocess
import socket
import numpy as np
import argparse
from pynput.keyboard import Key, Controller, KeyCode
from pynput.mouse import Listener
from threading import Thread
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QUrl, QObject, Signal, Slot


class ToolbarManager(QObject):

    update_position = Signal(int, int)
    update_selection = Signal()

    def __init__(self):
        QObject.__init__(self)
        self.mode = self.get_mode()
        self.stop = False
        if self.mode != 'manual':
            if os.name == 'nt':
                subprocess.Popen(['./stream/streamer.exe'])
            else:
                subprocess.Popen(['./stream/streamer'])
        self.sock = self.create_connection('127.0.0.1', 9998)
        self.stream_thread = None
        if self.mode == 'gazetouch':
            self.stream_thread_two = None
        self.keyboard = Controller()
        self.tools = self._populate_tools()
        self.curr_key = None
        self.w, self.h = 1920, 1080

    def get_mode(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('-m',
                            '--mode',
                            default='gazeflow',
                            required=False,
                            choices=['gazeflow', 'dwell', 'gazetouch', 'manual'])
        return parser.parse_args().mode

    def create_connection(self, ip, port):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind((ip, port))
        return sock

    def stream_data(self):
        if self.mode != 'manual':
            self.stream_thread = Thread(target=self._stream_loop, args=())
            self.stream_thread.start()
        if self.mode == 'manual':
            self.stream_thread = Thread(target=self._mouse_loop, args=())
            self.stream_thread.start()
        if self.mode == 'gazetouch':
            self.stream_thread_two = Thread(target=self._gazetouch_loop, args=())
            self.stream_thread_two.start()

    def _on_mouse_move(self, x, y):
        self.update_position.emit(x, y)

    def _on_mouse_click(self, x, y, button, pressed):
        if pressed:
            self.update_selection.emit()

    def _mouse_loop(self):
        with Listener(
            on_move=self._on_mouse_move,
            on_click=self._on_mouse_click
            ) as listener:
            listener.join()

    def _gazetouch_loop(self):
        with Listener(on_click=self._on_mouse_click) as listener:
            listener.join()

    def _stream_loop(self):
        while not self.stop:
            if os.name == 'nt':
                x,y = self._stream_windows()
            else:
                x,y = self._stream_linux()
            self.update_position.emit(x,y)

    def _stream_linux(self):
        data,_ = self.sock.recvfrom(256)
        data = data.decode('ascii', 'replace').split('\n')
        coord = data[0].split('~')
        if len(coord) == 3:
            x, y = float(coord[1]), float(coord[2])
            return int(self.w * x), int(self.h * y)
        return 0,0

    def _stream_windows(self):
        data,_ = self.sock.recvfrom(1024)
        data = data.decode().replace(',','.')
        coord = data.split('~')
        return float(coord[1]), float(coord[2])


    def _populate_tools(self):
        return {
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
            "geo2": [Key.ctrl, ':'],
            "geo3": [Key.ctrl, '='],
            "geo4": [Key.ctrl, '|'],
            "geo5": [Key.ctrl, "'"],

            "selection1": [Key.ctrl, 'r'],
            "selection2": 'j',
            "selection3": [Key.ctrl, '}'],
            "selection4": [Key.ctrl, '{'],

            'no_mouse': [Key.ctrl, '\\'],
        }

    @Slot(str)
    def update_tool(self, tool_id):
        if self.curr_key == "eraser":
            self.keyboard.press('e')
            self.keyboard.release('e')
        self.curr_key = tool_id
        print("GOT:", tool_id)
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
    mode = toolbar_manager.mode
    if mode == 'manual':
        engine.load(QUrl("painting_tool_manual.qml"))
    elif mode == 'dwell':
        engine.load(QUrl("painting_tool_dwell.qml"))
    elif mode == 'gazeflow':
        engine.load(QUrl("painting_tool_gazeflow.qml"))
    elif mode == 'gazetouch':
        engine.load(QUrl("painting_tool_gazetouch.qml"))
    else:
        sys.exit(-1)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
