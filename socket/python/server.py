#!c:/python26/python.exe
# -*- coding: utf-8 -*-

import socket
import threading
import SocketServer
import time
from inspect import getargspec
import ConfigParser
from Queue import *

# 数据输入
class NetHandler(SocketServer.StreamRequestHandler):
    def w(self,text, noCR = 0):
        if noCR:
            self.wfile.write(text)
        else:
            self.wfile.write(text + "\n\r")
    def handle(self):
        self.w(cfg.get('strings','welcome'));
        self.w(cfg.get('strings','warning'));
        player = Player(self)
        players[self.client_address] = player
        while(1):
            data = self.rfile.readline()
            if not data:
                break
            q.put(RPCMessage(player, data))

# 信号编集
class NetMarshall(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    #def handle_error(self, request, client_address):
        #print("Some shit went down from %s" % (client_address,))
    def close_request(self, request, client_address):
        request.close()
        players[client_address].disconnect()
        del players[client_address]
    def process_request_thread(self, request, client_address):
        try:
            self.finish_request(request, client_address)
            self.close_request(request, client_address)
        except:
            self.handle_error(request, client_address)
            self.close_request(request, client_address)

# 模拟RPC
class RPCMessage:
    def __init__(self,player,message):
        self.player = player
        self.message = message.strip().lower().split(' ',1)
        if len(self.message) == 1:
            self.message = [self.message[0], 0]
        self.funcs = {
            'help': self.rpc_help
            }
        self.afuncs = {
            'create':self.rpc_create,
            'login':self.rpc_login
            }
        self.rfuncs = {
            'logout':self.rpc_logout,
            'join':self.rpc_join,
            'say':self.rpc_say
            }
        self.sfuncs = {
            }
    def rpc_say(self, args):
        if not args:
            self.player.net.w("You must say something to be heard.")
            return
        if self.player.room == -1:
            self.player.net.w("You must be in a room to say something.")
            return
        rooms[self.player.room].w("%s>> %s" % (self.player.character.name,args))
    def rpc_join(self, args):
        room = int(args)-1
        max_rooms = int(cfg.get('game','rooms'))-1
        if room > max_rooms or room < 0:
            self.player.net.w("Invalid room choice. Max room number is %s." % (cfg.get('game','rooms')))
            return
        self.player.room = room
        rooms[room].join(self.player)
        self.player.net.w(cfg.get('game',args))
        chars = ''
        for play in rooms[room].players:
            chars += str(play) + ', '
        self.player.net.w("You see: \r\n%s" % chars)
    def rpc_logout(self, args):
        self.player.logout()
        self.player.net.w("You are now logged out.")
    def rpc_create(self, args):
        args = str(args).split(' ',1)
        if len(args) == 1:
            self.player.net.w("CREATE takes two arguments, NAME and PASSWORD seperated by a space\r\nex: CREATE name password")
            return
        if args[0] in characters:
            self.player.net.w("\"%s\" is already taken :(" % (args[1]))
        self.player.character = Character(args[0],args[1])
        characters[args[0]] = self.player.character
        self.player.net.w("You have created %s! The first step is always the hardest." % self.player.character.name)
    def rpc_login(self, args):
        args = str(args).split(' ',1)
        if len(args) == 1:
            self.player.net.w("Login takes two arguments, NAME and PASSWORD seperated by a space\r\nex: LOGIN name password")
            return
        if args[0] in characters:
            character = characters[args[0]]
            if character.password == args[1]:
                self.player.character = character
                if character.loggedIn:
                    character.loggedIn.net.w("!!!! You are being logged out due to another user signing into this character!!!!")
                    character.loggedIn.logout()
                character.loggedIn = self.player
                self.player.net.w("You are now logged into %s. Please JOIN a room." % character.name)
            else:
                self.player.net.w("The password supplied does not match the name \"%s\"." % (args[1]))
                return
        else:
            self.player.net.w("\"%s\" does not exist! Why don't you CREATE it?" % (args[1]))
            return
    def rpc_help(self, args):
        if args:
            if args in self.funcs or args in self.afuncs or args in self.rfuncs or args in self.sfuncs:
                self.player.net.w(cfg.get('rpc',args))
            else:
                self.player.net.w("I don't think the %s command exists." % (args.upper()))
        else:
            rpcs = 'FULL ACCESS>>  '
            for rpc in self.funcs.keys():
                rpcs += rpc + ', '
            rpcs.strip(',')
            rpcs += "\n\rANONYMOUS ONLY>>  "
            for rpc in self.afuncs.keys():
                rpcs += rpc + ', '
            rpcs.strip(',')
            rpcs += "\n\rLOGGED IN ONLY>>  "
            for rpc in self.rfuncs.keys():
                rpcs += rpc + ', '
            rpcs.strip(',')
            self.player.net.w("The following commands are available:\n\r%s\n\rType HELP {COMMAND} to get more info" % rpcs)
    def execute(self):
        if self.message[0] in self.funcs:
            #print(getargspec(self.funcs[self.message[0]]))
            self.funcs[self.message[0]](self.message[1])
        elif self.message[0] in self.afuncs:
            if not self.player.character:
                self.afuncs[self.message[0]](self.message[1])
            else:
                self.player.net.w("You may only use %s when not logged in. Please LOGOUT if you want to use this command." % self.message[0].upper())
        elif self.message[0] in self.rfuncs:
            if self.player.character:
                self.rfuncs[self.message[0]](self.message[1])
            else:
                self.player.net.w("You may only use %s when logged in. Please either LOGIN or CREATE to use this command." % self.message[0].upper())
        else:
            self.player.net.w("I did not understand your command: %s" % (self.message[0]))

# 玩家用户            
class Player:
    character = 0
    room = -1
    def __init__(self,net):
        self.net = net
    def disconnect(self):
        if self.character:
            self.logout()
    def logout(self):
        if self.room:
            rooms[self.room].leave(self)
        self.character.loggedIn = 0
        self.character = 0

# 角色        
class Character:
    loggedIn = 0
    def __init__(self, name, password, accessLevel = 0):
        self.wins = 0
        self.name = name
        self.password = password
        self.accessLevel = accessLevel

# 房间结构
class Room:
    players = {}
    def __init__(self,description):
        self.description = description
    def leave(self,player):
        del self.players[player.character.name]
        self.w("%s has left the room." % (player.character.name))
    def join(self,player):
        self.w("%s has joined the room." % (player.character.name),player.character.name)
        self.players[player.character.name] = player
    def w(self,message,exclude = ''):
        for player in self.players:
            if player != exclude: self.players[player].net.w(message)

# 全局数据和服务线程启动
if __name__ == "__main__":
    cfg = ConfigParser.SafeConfigParser()
    cfg.read('game.cfg')
    HOST, PORT = cfg.get('net','host'), int(cfg.get('net','port'))
    characters = {
        cfg.get('admin','name'):Character(cfg.get('admin','name'), cfg.get('admin','password'), 9)
    }
    players = {}
    rooms = []
    numRooms = int(cfg.get('game','rooms'))
    c = 0
    while c < numRooms:
        rooms.append(Room(cfg.get('game',str(c+1))))
        c+=1
    q = Queue()
    server = NetMarshall((HOST, PORT), NetHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.setDaemon(True)
    server_thread.start()
    print "Server loop running in thread:", server_thread.name
    while(1):
        rpc = q.get(1)
        rpc.execute()
