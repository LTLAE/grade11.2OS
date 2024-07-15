#include <stdio.h>
#include <csignal>
#include <unistd.h>
#include <cstdlib>
#include <sys/wait.h>
#include <iostream>
using namespace std;

int wait_mark;

// typedef void (*FunctionP)(int, int);

void waiting( ) {
    while(wait_mark!=0);
    // for(int jump = 1; jump != 0; jump = wait_mark);
    printf("A process ends its wait.\n");
}

void stop(int sighum) {
    wait_mark -= 1;
    printf("A process is removed from waiting.\n");
}

/*
void SignalHandler(int sigNum) {
    cout << "Received " << sigNum << endl;
    stop();
}
*/

/*
void ParentWait(){
    wait_mark = 2;  //wait two child processes
    signal(16, reinterpret_cast<void (*)(int)>(stop));
    signal(17, reinterpret_cast<void (*)(int)>(stop));
    waiting();
}
*/

//very very bad thing is that signal() only receive pointer as input
//FunctionPointer ptr points to stop()
//I need to pass two values to it for debugging
//codes above are abandoned

int main( ) {
    // FunctionP ptr;
    // ptr = &stop;
    int p1,p2;
    p1 = fork();       /*创建子进程p1*/
    if (p1 > 0) {
        p2 = fork();     /*创建子进程p2*/
        if(p2 > 0) {
            wait_mark = 1;  
            printf("Parent process started. Waiting for ^C signal.\n");
            signal(SIGINT,stop);   /*接收到^c信号，转stop*/
            waiting();
            kill(p1,16);        /*向p1发软中断信号16*/
            printf("Sent 16 to p1.\n");
            kill(p2,17);        /*向p2发软中断信号17*/
            printf("Sent 17 to p2.\n");
            wait(0);            /*同步*/
            wait(0);
            // ParentWait();
            printf("Parent process is killed!\n");
            exit(0);
        } else {
            wait_mark=1;
            printf("Child process p2 started. Waiting for 17 signal.\n");
            signal(SIGINT,SIG_IGN);
            signal(17, stop);   /*接收到软中断信号17，转stop*/
            wait(0);
            waiting();
            // kill(getppid(),17);
            printf("Child process 2 is killed by parent!\n");
            exit(0);
        }
    } else {
        wait_mark=1;
        printf("Child process p1 started. Waiting for 16 signal.\n");
        signal(SIGINT,SIG_IGN);
        signal(16, stop);        /*接收到软中断信号16，转stop*/
        wait(0);
        waiting();
        // kill(getppid(),16);
        printf("Child process 1 is killed by parent!\n");
        exit(0);
    }
}
