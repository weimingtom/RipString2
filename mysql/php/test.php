#!php
<?php
	//see http://www.roscripts.com/PHP_MySQL_by_examples-193.html
	//see http://www.csci.csusb.edu/dick/samples/php.samples.html
	//see http://www.lslnet.com/linux/books/php3MySQL/php3MySQL_1.htm
	//see http://www.w3school.com.cn/php/php_ref_mysql.asp
	$host		=	'localhost';
	$user		=	'root';
	$pass		=	'123456';
	$database	=	'test';

	$connect = @mysql_connect($host, $user, $pass);

	if (!$connect)
	{
		trigger_error(mysql_error(), E_USER_ERROR);
	}
	else
	{
		if (!mysql_select_db($database, $connect))
			die(mysql_error());
		
		@mysql_query("CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))");
		
		@mysql_query("INSERT INTO exmpl_tbl VALUES(1, '" . "Hello" . "')");
		@mysql_query("INSERT INTO exmpl_tbl VALUES(2, '" . "World" . "')");
				
		$query = mysql_query("SELECT val FROM exmpl_tbl WHERE id=1");
		$row = mysql_fetch_assoc($query);
		if($row)
			printf("Value returned: %s\n", $row['val']);
		
		$val = "World";
		$query = mysql_query("SELECT id FROM exmpl_tbl WHERE val = '" . mysql_real_escape_string($val) . "'");
		$row = mysql_fetch_assoc($query);
		if($row)
			printf("ID of %s is %d\n", mysql_real_escape_string($val), $row['id']);
		
		$query = mysql_query("SELECT * FROM exmpl_tbl");
		while($row = mysql_fetch_assoc($query))
		{
			printf("Value of ID %d is %s\n", $row['id'], $row['val']);		
		}
		
		@mysql_query("DELETE FROM exmpl_tbl WHERE id=1");
		@mysql_query("DROP TABLE exmpl_tbl");
		@mysql_close($connect);
	}
?>
