#!lua

-- see http://www.keplerproject.org/luasql/

require 'luasql.mysql'

local hostname = 'localhost'
local port = 3306
local username = 'root'
local password = '123456'
local database = 'test'
local env, conn, cur, row, val, c

env = assert(luasql.mysql())
conn = assert(env:connect('', username, password, hostname, port),
	'Could not connect to database')

conn:execute('use '..database)

conn:execute'CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))'

assert(conn:execute(string.format("INSERT INTO exmpl_tbl VALUES(1, '%s')", 'Hello')))
assert(conn:execute(string.format("INSERT INTO exmpl_tbl VALUES(2, '%s')", 'World')))
conn:commit()

cur = assert(conn:execute('SELECT val FROM exmpl_tbl WHERE id=1'))
row = cur:fetch ({}, 'a')
if row then
	print(string.format('Value returned: %s', row.val))
end

val = 'World'
cur = assert(conn:execute(string.format("SELECT id FROM exmpl_tbl WHERE val='%s'", val)))
row = cur:fetch ({}, 'a')
if row then
	print(string.format('ID of %s is: %d', val, row.id))
end

cur = assert(conn:execute('SELECT * FROM exmpl_tbl'))
row = cur:fetch ({}, 'a')
while row do
	print(string.format('Value of ID %d is %s', row.id, row.val))
	row = cur:fetch (row, 'a')
end

c = conn:execute'DELETE FROM exmpl_tbl WHERE id=1'
print(string.format('Deleted %d rows', c))

conn:execute'DROP TABLE exmpl_tbl'
conn:commit()
conn:close()
env:close()
