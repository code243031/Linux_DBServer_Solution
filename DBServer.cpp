#include <iostream>
#include <stdlib.h>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT 2250

// 별도의 헤더파일로 옳겨놓을 것
#include <mysql_connection.h>
#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>

bool GetCustomers();

using namespace std;

int main() {
	struct sockaddr_in serv_sock, clnt_sock;
	socklen_t clnt_addr_size;

	int server;
	int client;

	cout << "Create socket..."
	server = socket(PF_INET, SOCK_STREAM, 0);
	if (server < 0) {
		cout << "create socket failed.\n";
		exit(-1);
	}
	cout << "Complete\n";

	cout << "---------------------------------------------------------\n"
	cout << "Bridging System DB Server v 1.0.0a\n";
	cout << "브릿징시스템에 데이터를 제공 및 저장하기 위한 목적으로 설계된 Database와 연결하기 위한 프로그램 입니다!\n";
	cout << "---------------------------------------------------------\n";

	cout << "Set socketAddress...";
	memset(&serv_sock, 0, sizeof(serv_sock));
	serv_sock.sin_family = AF_INET;
	serv_sock.sin_addr.s_addr = inet_addr("10.0.2.15");
	serv_sock.sin_port = htons(PORT);

	cout << "Complete\n";

	cout << "Bind server...";
	if (bind(server, (struct sockaddr*) &serv_sock, sizeof(serv_sock)) < 0) {
		cout << "bind failed\n";
		exit(-1);
	}

	cout << "Complete\n";	
	cout << "Server Now Listening\n";

	listen(server, 5);

	while (1) {
		clnt_addr_size = sizeof(clnt_sock);
		int conn = accept(server, (struct sockaddr*) &clnt_sock, &clnt_addr_size);
		if (conn < 0) {
			cout << "accept failed.\n";
			exit(-1);
		}
		
		cout << "User connect complete.\n";

		GetCustomers();
	}

	close(client);
	close(server);

	return 0;
}

bool GetCustomers() {
	sql::Driver *driver;
	sql::Connection *conn;
	sql::Statement *stmt;
	sql::ResultSet *res;

	string query = "SELECT * FROM RegisterID;";

	driver = get_driver_instance();
	conn = driver->connect("tcp://localhost:3306", "bridge", "tsnp2022&&");

	conn->setSchema("BridgingSystem_Debug");
	stmt = conn->createStatement();

	res = stmt->executeQuery(query);

	while (res->next()) {
		cout << "id = " << res->getString("UserId") << "\n";
		cout << "pw = " << res->getString("UserPw") << "\n";
		cout << "date = " << res->getString("LastAccessDate") << "\n";
	}

	return true;
}
