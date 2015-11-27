# -*- coding:utf-8 -*-
# file: client.py

import Tkinter
import socket

class Window:
        def __init__(self, root):
                label1 = Tkinter.Label(root, text = 'IP')
                label2 = Tkinter.Label(root, text = 'Port')
                label3 = Tkinter.Label(root, text = 'Data')
                label1.place(x = 5, y = 5)
                label2.place(x = 5, y = 30)
                label3.place(x = 5, y = 55)
                self.entryIP = Tkinter.Entry(root)
                self.entryIP.insert(Tkinter.END, '127.0.0.1')
                self.entryIP.place(x = 40, y = 5)
                self.entryPort = Tkinter.Entry(root)
                self.entryPort.insert(Tkinter.END, '1051')
                self.entryPort.place(x = 40, y = 30)
                self.entryData = Tkinter.Entry(root)
                self.entryData.insert(Tkinter.END, 'Hello')
                self.entryData.place(x = 40, y = 55)
                self.Recv = Tkinter.Text(root)
                self.Recv.place(y = 105)
                self.send = Tkinter.Button(root, text = '发送数据', command = self.Send)
                self.send.place(x = 40, y = 80)
        def Send(self):
                #try:
                        ip = self.entryIP.get()
                        port = int(self.entryPort.get())
                        data = self.entryData.get()
                        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                        client.connect((ip, port))
                        client.send(data)
                        rdata = client.recv(1024)
                        self.Recv.insert(Tkinter.END, 'Server:' + rdata + '\n')
                        client.close()
                #except:
                #        self.Recv.insert(Tkinter.END, '发送错误\n')
root = Tkinter.Tk()
window = Window(root)
root.mainloop()

                
