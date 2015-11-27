require"luaevent"
local socket = require"socket"
local STP = require "StackTracePlus"
debug.traceback = STP.stacktrace

local oldPrint = print
print = function(...)
	oldPrint("[SRV]", ...)
end

-- cannot throw error
local function echoHandler(skt)
	while true do
		local data, ret = luaevent.receive(skt)
		local report = ""
		if data then
			report = report.."(data) "..data
		end
		if ret then
			report = report.."(ret) "..ret
		end
		print(report)
		if data == "quit" or ret == 'closed' then
			break
		end
		luaevent.send(skt, data)
		luaevent.send(skt, "\r\n")
		collectgarbage()
	end
	skt:close()
	print("done")
end

local server = assert(socket.bind("localhost", 20000))
print('lisening on 20000...')
server:settimeout(0)

local coro = coroutine.create
coroutine.create = function(...)
	local ret = coro(...)
	return ret
end

luaevent.addserver(server, echoHandler)
luaevent.loop()
