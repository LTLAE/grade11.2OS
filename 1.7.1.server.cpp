#include <sys/types.h>
#include <sys/msg.h>
#include <sys/ipc.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#define MSGKEY 75
using namespace std;

struct  msgform{
    long  mtype;
    char  mtext[1000];
}msg;

int  msgqid;

int main(){
    msgqid=msgget(MSGKEY,0777|IPC_CREAT);  /*创建75#消息队列*/
    do {
    msgrcv(msgqid,&msg,1030,0,0);   /*接收消息*/
    printf("(server)received\n");
    cout << "mtype: " << msg.mtype << " metext: " << msg.mtext << endl;
    }
    while(msg.mtype!=1);
    msgctl(msgqid,IPC_RMID,0);  /*删除消息队列，归还资源*/
    exit(0);
}