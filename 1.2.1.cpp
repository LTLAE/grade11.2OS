#include <iostream>
#include <unistd.h>
using namespace std;

int main(){
	int pid;
	pid = fork();	//create a child process
	
	if(pid == 0) 	execl("/bin/ls","ls",NULL);
	else	{
	wait(NULL);
	cout << "Complete" << endl;
	}
}
