#include <iostream>
#include <unistd.h>
using namespace std;

int main(){
	int pid;
	pid = fork();	//create a child process
	
	// if(pid == 0) 	execl("/Users/LuoyuanGu/Desktop","1.3.2.hello",NULL);
	if(pid == 0) execl("./1.3.2.hello","1.3.2.hello",NULL);
	else	{
	wait(NULL);
	cout << "Complete" << endl;
	}
}
