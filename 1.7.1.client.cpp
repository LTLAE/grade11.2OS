#include <sys/types.h>
#include <sys/msg.h>
#include <sys/ipc.h>
#include <stdio.h>
#include <stdlib.h>
#define MSGKEY 75
using namespace std;

struct  msgform{
    long  mtype;
    char  mtext[1000];
}msg;

int  msgqid;

int main(){
    msgqid=msgget(MSGKEY,0777);   /*打开75#消息队列*/
    for(int timer = 10; timer >= 1; timer--){
    msg.mtype = timer;
    printf("(client)sent\n");
    msgsnd(msgqid,&msg,1024,0);     /*发送消息*/
    }
    exit(0);
}