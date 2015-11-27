---
-- helper functions ( Big Endian Version )
--
function dumpPack(s)
	local block = 16
	local i = 1
	while true do
		local bytes = s:sub(i, i+15)
		for _, b in ipairs { string.byte(bytes, 1, -1) } do
			io.write(string. format('%02X ', b))
		end

		io.write(string.rep('   ', block - string.len(bytes)))
		io.write(' ', string.gsub(bytes, '%c', '.'), '\n')

		i = i + 16
		if i > #s then break end
	end
end

function readNumber(bytes)
	local n = 0
	for i, b in ipairs { string.byte(bytes, 1, -1) } do
		n = n + b*256^(i-1)
	end
	return n
end

function Bit8toStr(i)
	return string.char(i)
end

function Bit16toStr(i)
	if i < 0 then return "" end
	local i1 = math.floor(i % 256)
	local i2 = math.floor(math.floor(i / 256) % 256)
	return string.char(i2 , i1)
end

function Bit32toStr(i)
	if i < 0 then return "" end
	local i1 = math.floor(i % 256)
	i = math.floor((i - i1) / 256)
	local i2 = math.floor(i % 256)
	i = math.floor((i - i2) / 256)
	local i3 = math.floor(i % 256)
	i = math.floor((i - i3) / 256)
	local i4 = math.floor(i % 256)
	i = math.floor((i - i4) / 256)
	return string.char(i4, i3, i2, i1)
end

function UTF8toStr(bytes)
	if type(bytes) ~= "string" then return nil end
	return Bit16toStr(#bytes)..bytes
end

function RawtoPack(bytes)
	if type(bytes) ~= "string" then return nil end
	return "CT"..Bit32toStr(#bytes)..bytes
end


function testcase()
	local bytes = ""
	bytes = bytes..Bit8toStr(1)
	bytes = bytes..Bit8toStr(2)
	bytes = bytes..Bit16toStr(3)
	bytes = bytes..Bit32toStr(4)
	dumpPack(bytes)
	dumpPack(RawtoPack(bytes))
end


---
-- helper functions ( Little Endian Version )
--

function Bit8toStr2(i)
	return string.char(i)
end

function Bit16toStr2(i)
	if i < 0 then return "" end
	local i1 = math.floor(i % 256)
	local i2 = math.floor(math.floor(i / 256) % 256)
	return string.char(i2 , i1)
end

function Bit32toStr2(i)
	if i < 0 then return "" end
	local i1 = math.floor(i % 256)
	i = math.floor((i - i1) / 256)
	local i2 = math.floor(i % 256)
	i = math.floor((i - i2) / 256)
	local i3 = math.floor(i % 256)
	i = math.floor((i - i3) / 256)
	local i4 = math.floor(i % 256)
	i = math.floor((i - i4) / 256)
	return string.char(i1, i2, i3, i4)
end

function UTF8toStr2(bytes)
	if type(bytes) ~= "string" then return nil end
	return Bit16toStr2(#bytes)..bytes
end

function RawtoPack2(bytes)
	if type(bytes) ~= "string" then return nil end
	return "CT"..Bit32toStr2(#bytes)..bytes
end


---
-- sample package generater
--
local MODL_GAMECLIENT = 5
local NMSG_LOGIN = 1
local NMSG_MOVE = 3

-- Big Endian
function SamplePack1(user, pass)
	print("SamplePack1")
	local bytes = ""
	bytes = bytes..Bit8toStr(MODL_GAMECLIENT)
	bytes = bytes..Bit8toStr(NMSG_LOGIN)
	bytes = bytes..UTF8toStr(user)
	bytes = bytes..UTF8toStr(pass)
	bytes = RawtoPack(bytes)
	dumpPack(bytes)
	return bytes
end

-- Little Endian
function SamplePack2(user, pass)
	print("SamplePack2")
	local bytes = ""
	bytes = bytes..Bit8toStr2(MODL_GAMECLIENT)
	bytes = bytes..Bit8toStr2(NMSG_LOGIN)
	bytes = bytes..UTF8toStr2(user)
	bytes = bytes..UTF8toStr2(pass)
	bytes = RawtoPack2(bytes)
	dumpPack(bytes)
	return bytes
end


-- Big Endian
function SamplePack3(user, x, y)
	print("SamplePack3")
	local bytes = ""
	bytes = bytes..Bit8toStr(MODL_GAMECLIENT)
	bytes = bytes..Bit8toStr(NMSG_MOVE)
	bytes = bytes..UTF8toStr(user)
	bytes = bytes..Bit32toStr(x)
	bytes = bytes..Bit32toStr(y)
	bytes = RawtoPack(bytes)
	dumpPack(bytes)
	return bytes
end

---
-- Pack socket test 01
--
local socket = require("socket")
host = host or "localhost"
port = port or 8899
host = socket.dns.toip(host)
print("IP: '" ..host.. "' port: " .. port .. "...")

local connects = {}
--New tcp socket
xpcall(function ()
	for k = 1, 1000 do
		local c = assert(socket.tcp())
		assert(c:connect(host, port))
		c:send(SamplePack1("nanami", "12345")) -- 23 bytes
		c:send(SamplePack3("nanami", k, 3)) -- 24 bytes
		c:send(SamplePack1("nanami", "12345")) -- 23 bytes
		if false then
			connects[#connects+1] = c
		else
			c:close()
		end
	end
end, function(message)
	print(message)
	print(debug.traceback());
end)

-- testcase()

print("Ending...")

--prevent data read fail
--os.execute('pause');

