#see
#1. Beginning Ruby - From Novice to Professional
#http://www.apress.com/9781430223634

require 'gserver'

class ChatServer < GServer
	def initialize(*args)
		super(*args)
		@@client_id = 0
		@@chat = []
	end
	
	protected
	def connecting(client)
		puts "connecting"
		super #·µ»Øtrue
	end
	
	protected
	def disconnecting(clientPort)
		puts "disconnecting"
		super
	end
	
	def serve(io)
		@@client_id += 1
		my_client_id = @@client_id
		my_position = @@chat.size
		io.puts("Welcome to the chat, client #{@@client_id}!\r\n")
		@@chat << [my_client_id, "<joins the chat>"]
		loop do 
			if IO.select([io], nil, nil, 2)
				line = io.gets
				if line =~ /quit/
					@@chat << [my_client_id, "<leaves the chat>"]
					break
				end
				self.stop if line =~ /shutdown/
				@@chat << [my_client_id, line]      
			else
				@@chat[my_position..(@@chat.size - 1)].each_with_index do |line, index|
					io.puts("#{line[0]} says: #{line[1]}\r\n")
				end
				my_position = @@chat.size
			end
		end    
	end
end

server = ChatServer.new(1234)
server.audit = true
server.start

server.join
#loop do
#	break if server.stopped?
#end
