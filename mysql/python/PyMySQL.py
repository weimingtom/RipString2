#!python

#see http://mysql-python.sourceforge.net/MySQLdb.html

import MySQLdb

 




db = MySQLdb.connect(host='localhost', port=3306, 
	user='root', passwd='123456', db="test")
cur = db.cursor()

cur.execute('CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))')
cur.execute("""INSERT INTO exmpl_tbl VALUES(1, %s)""", ('Hello',))
cur.execute('DROP TABLE exmpl_tbl')

#con.commit()
#r = cur.execute('select * from people')
#r = cur.fetchall()
#print r

cur.commit()
cur.close()
db.close()
