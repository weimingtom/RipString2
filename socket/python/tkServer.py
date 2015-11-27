# -*- coding:utf-8 -*-
# file: server.py

import Tkinter
import threading
import socket

class ListenThread(threading.Thread):
	def __init__(self, edit, server):
		threading.Thread.__init__(self)
		self.edit = edit
		self.server = server
	def run(self):
		while 1:
			try:
				client, addr = self.server.accept()
				self.edit.insert(Tkinter.END, '连接来自：%s:%d' % addr)
				data = client.recv(1024)
				self.edit.insert(Tkinter.END, '收到数据：%s \n' % data)
				client.send('I GOT: %s' % data)
				client.close()
				self.edit.insert(Tkinter.END, '关闭客户端\n')
			except:
				self.edit.insert(Tkinter.END, '关闭连接\n')
				break
class Control(threading.Thread):
	def __init__(self, edit):
		threading.Thread.__init__(self)
		self.edit = edit
		self.event = threading.Event()
		self.event.clear()
	def run(self):
		server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		server.bind(('', 1051))
		server.listen(1)
		self.edit.insert(Tkinter.END, '正在等待连接\n')
		self.lt = ListenThread(self.edit, server)
		self.lt.setDaemon(True)
		self.lt.start()
		self.event.wait()
		server.close()
	def stop(self):
		self.event.set()
class Window:
	def __init__(self, root):
		self.root = root
		self.butlisten = Tkinter.Button(root, text = '开始监听', command = self.Listen)
		self.butlisten.place(x = 20, y = 15)
		self.butclose = Tkinter.Button(root, text = '停止监听', command = self.Close)
		self.butclose.place(x = 120, y = 15)
		self.edit = Tkinter.Text(root)
		self.edit.place(y = 50)
	def Listen(self):
                # self.edit.insert(Tkinter.END, '开始监听\n')
		self.ctrl = Control(self.edit)
		self.ctrl.setDaemon(True)
		self.ctrl.start()
	def Close(self):
                # self.edit.insert(Tkinter.END, '停止监听\n')
		self.ctrl.stop()
root = Tkinter.Tk()
window = Window(root)
root.mainloop()
