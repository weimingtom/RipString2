require"luaevent"
require"socket"
local oldPrint = print
print = function(...)
	oldPrint("[CLT]", ...)
end

local function func()
	print("ACTIVATED")
	local sock = socket.tcp()
	--sock:
	sock = luaevent.wrap(sock)
	assert(sock:connect("localhost", 20000))
	for i = 1, 100 do
		assert(sock:send("Greet me\n"))
		assert(sock:receive())
		collectgarbage()
	end
	print("COMPLETE")
end

luaevent.addthread(func)
luaevent.loop()
