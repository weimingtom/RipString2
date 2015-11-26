#!ruby

# http://www.kitebird.com/articles/
# http://www.kitebird.com/articles/ruby-mysql.html

require 'rubygems'
require 'mysql'

begin
	dbh = Mysql.real_connect "localhost", "root", "123456", "test"
	#puts "Server version: " + dbh.get_server_info
	dbh.query "DROP TABLE IF EXISTS exmpl_tbl"
	dbh.query "CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))"
	
	dbh.query "INSERT INTO exmpl_tbl VALUES(1, '" + dbh.escape_string("Hello") +"')"
	dbh.query "INSERT INTO exmpl_tbl VALUES(2, '" + dbh.escape_string("World") +"')"
	
	res = dbh.query "SELECT val FROM exmpl_tbl WHERE id=1" 
	row = res.fetch_row
	printf "Value returned: %s\n", row[0] unless row.nil?
	res.free
	
	val = "World"
	res = dbh.query "SELECT id FROM exmpl_tbl WHERE val='" + dbh.escape_string(val) + "'"
	row = res.fetch_hash
	printf "ID of %s is %d\n", val, row["id"] unless row.nil?
	res.free
	
	res = dbh.query "SELECT * FROM exmpl_tbl"
	res.each do |row|
		printf "Value of ID %d is %s\n", row[0], row[1]
	end
	puts "Number of rows returned: #{res.num_rows}"
	res.free

	dbh.query "DELETE FROM exmpl_tbl WHERE id=1"
	dbh.query "DROP TABLE exmpl_tbl"
rescue Mysql::Error => e
	puts "Error code: #{e.errno}"
	puts "Error message: #{e.error}"
	puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
	# disconnect from server
	dbh.close if dbh
end

