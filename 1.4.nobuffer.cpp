#include <iostream>
#include <unistd.h>
using namespace std;

int main(){
	time_t t;
	FILE *fp;
	fp=fopen("./MyDaemon.log","a");
	// setlinebuf(fp); //set a line buffer
	pid_t pid;
	pid = fork();
	if(pid > 0) {
		cout << "Daemon on duty." << endl;
	}
	while(1) {	//endless loop
		if(fp != NULL) {	//if file is opened
		sleep(10);	//write time every 10 seconds
		cout << "Daemon has updated time." << endl;
		t=time(0);
		fprintf(fp,"Jianyu, the current time is %s\n", asctime(localtime(&t)));
		}
	}
	fclose(fp); 
}
