#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <iostream>
using namespace std;

int p1,p2;

int main(){
    int fd[2];
    char outpipe[100],inpipe[100];
    pipe(fd);   //create a pipe

    p1 = fork();
    if(p1 == 0) {
        lockf(fd[1],1,0);
        sprintf(outpipe,"child 1 process is sending message!");     /*把串放入数组outpipe中*/
        write(fd[1],outpipe,50);     /*向管道写长为50字节的串*/
        lockf(fd[1],0,0);
        exit(0);
    } else {
        p2 = fork();
        if(p2 == 0) {
            lockf(fd[1],1,0);
            sprintf(outpipe,"child 2 process is sending message!");
            write(fd[1],outpipe,50);
            lockf(fd[1],0,0);
            exit(0);
        } else {
            wait(0);              /*同步*/
            read(fd[0],inpipe,50);   /*从管道中读长为50字节的串*/
            printf("%s\n",inpipe);
            wait(0);
            read(fd[0],inpipe,50);
            printf("%s\n",inpipe);
            exit(0);

        }
    }
}