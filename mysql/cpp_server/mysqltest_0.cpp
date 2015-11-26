#include <windows.h>
#include <iostream>
#include <mysql.h>

using namespace std;

int main()
{
    char *host = "localhost";
    char *user = "root";
    char *pass = "123456";
    char *db = "test";

    MYSQL *sock;
    sock = mysql_init(0);
    if (sock) 
		cout << "sock handle ok!" << endl;
    else 
        cout << "sock handle failed!" << mysql_error(sock) << endl;
	
    if (mysql_real_connect(sock, host, user, pass, db, 0, NULL, 0))
        cout << "connection ok!" << endl;
    else
        cout << "connection fail: " << mysql_error(sock) << endl;
		
    cout << "connection character set: " << mysql_character_set_name(sock) << endl;
    
    mysql_close(sock);
	
    return 0;
}

