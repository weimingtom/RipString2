// see http://www.mmdb.net/m_kaneko/mysql/
// see http://www.mmdb.net/m_kaneko/mysql/kansu/mysql_query.html

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <mysql.h>

static const char opt_host_name[]      = "localhost";
static const char opt_user_name[]      = "root";
static const char opt_password[]       = "123456";
static const unsigned int opt_port_num = 3306;
static const char *opt_socket_name     = NULL;
static const char *opt_db_name         = "test";
static const unsigned int opt_flags    = 0;

static MYSQL *conn;

void print_error(MYSQL *conn, const char *title)
{
    fprintf(stderr,"%s:\nError %u (%s)\n",title,mysql_errno(conn),mysql_error(conn));
}

void process_result_set(MYSQL *conn,MYSQL_RES *res_set)
{
    far MYSQL_ROW row;
    unsigned int i;

    while ((row = mysql_fetch_row(res_set)) != NULL)
    {
        for(i = 0; i < mysql_num_fields(res_set); ++i)
        {
            if (i > 0)
                fputc('\t',stdout);
            
            row[i] = row[i];
            printf("%1s",row[i] != NULL ? row[i] : "NULL");
        }
        fputc('\n',stdout);
    }

    if(mysql_errno(conn) != 0)
        print_error(conn,"mysql_fetch_row() failed");
    else
        printf("%lu rows returned \n", (unsigned long)mysql_num_rows(res_set));
}

int main(int argc, _TCHAR* argv[])
{
    char strSQL[2048];
    
    if( (conn = mysql_init(NULL))== NULL)
    {
        fprintf(stderr,"mysql init failed!\n");
        exit(1);
    }

    if(mysql_real_connect(conn, opt_host_name, opt_user_name, opt_password,
        opt_db_name, opt_port_num, opt_socket_name, opt_flags) == NULL)
    {
		fprintf(stderr,"mysql_real_connect failed:\nError %u (%s)\n", mysql_errno(conn),mysql_error(conn));
		mysql_close(conn);
		exit(1);
    }

    if(mysql_query(conn,"CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100));"))
    {
        print_error(conn,"create table failed");
    }
    else
    {
        printf("create table success, effected rows:%lu\n",(unsigned long)mysql_affected_rows(conn));
    }

	memset(strSQL, 0, sizeof(strSQL));
	sprintf(strSQL, "INSERT INTO exmpl_tbl VALUES(1, \'%s\'),(2, \'%s\');", "Hello", "World");
    if(mysql_query(conn, strSQL))
    {
        print_error(conn,"insert failed");
    }
    else
    {
        printf("insert success, affected rows:%lu\n",(unsigned long)mysql_affected_rows(conn));
    }
        
    if(mysql_query(conn,"select * from exmpl_tbl;"))
    {
        print_error(conn,"mysql_query() error");
    }
    else
    {
        MYSQL_RES *res_set;
        res_set = mysql_store_result(conn);
        if(res_set == NULL)
        {
            print_error(conn,"mysql_store_result failed");
        }
        else 
        {
            process_result_set(conn,res_set);
            mysql_free_result(res_set);
        }
    }

    if(mysql_query(conn,"DROP TABLE exmpl_tbl;"))
    {
        print_error(conn,"insert failed");
    }
    else
    {
        printf("drop table success, effected rows:%lu\n",(unsigned long)mysql_affected_rows(conn));
    }
	
    mysql_close(conn);

    //getchar();
    return 0;
}
