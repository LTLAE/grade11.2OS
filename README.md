GZHU grade 14 Operating system experiments personal backup  
====
This repository is created for personal backup.  
Highly NOT recommand using codes in this repo to submit homework.  

experiment 1  
---
* 1.1 使用fork()创建进程，并查看进程和子进程之间的关系。
* 1.2 用fork()创建一个进程，然后用exec()用新的程序替换子进程内容，然后用wait()等待子进程执行完后，再结束父进程。
* 1.3 用lockf()给（一）中的每一个进程加锁，观察现象。
* 1.4 创建一个日志文件/var/log/Mydaemon.log，然后每隔一段时间向其中写入一个时间戳。
* 1.5 编写程序：用fork( )创建两个子进程，再用系统调用signal( )让父进程捕捉键盘上来的中断信号（即按^c键）；捕捉到中断信号后，父进程用系统调用kill( )向两个子进程发出信号，子进程捕捉到信号后分别输出下列信息后终止：  
&nbsp;&nbsp;Child process1 is killed by parent!  
&nbsp;&nbsp;Child process2 is killed by parent!  
&nbsp;父进程等待两个子进程终止后，输出如下的信息后终止：  
&nbsp;&nbsp;Parent process is killed!  
* 1.6 编写程序实现进程的管道通信。用系统调用pipe( )建立一管道，二个子进程P1和P2分别向管道各写一句话：  
&nbsp;&nbsp;Child 1 is sending a message!  
&nbsp;&nbsp;Child 2 is sending a message!
* 1.7 消息的创建、发送和接收。使用系统调用msgget( ),msgsnd( ),msgrev( ),及msgctl( )编制一长度为1k的消息发送和接收的程序。
* 1.8 编制一长度为1k的共享存储区发送和接收的程序。

experiment2
---
* 2.1 编写Dijkstra的银行家算法，如果能分配，显示成功，并给出一个安全序列。如果不能分配，显示相应的理由。  
```Test data1
0 1 0 1
28 44 28
13 5 9 7 4 5
6 11 3 1 7 3
15 11 12 8 8 8
11 14 12 7 7 4
2 16 7 1 9 5
```
```Test data2
4 2 7 2
28 44 28
13 5 9 7 4 5
6 11 3 1 7 3
15 11 12 8 8 8
11 14 12 7 7 4
2 16 7 1 9 5
```
```Test data3
3 4 4 4
28 44 28
13 5 9 7 4 5
6 11 3 1 7 3
15 11 12 8 8 8
11 14 12 7 7 4
2 16 7 1 9 5
```
```Test data4
3 1 0 0
20 27 39
10 8 10 1 2 9
10 8 15 3 5 9
7 10 9 1 6 4
16 2 10 8 2 3
7 9 8 1 6 5
```
```Test data5
4 0 2 2
20 27 39
10 8 10 1 2 9
10 8 15 3 5 9
7 10 9 1 6 4
16 2 10 8 2 3
7 9 8 1 6 5
```
* 2.2 常用页面置换算法模拟实验。编写程序分别使用下述三个算法计算访问命中率：最佳淘汰算法（OPT），先进先出的算法（FIFO），最近最久未使用算法（LRU）。输出访问顺序和命中率结果。
```Test data
4
50
7 0 9 1 2 0 3 0 4 2 3 0 3 2 1 2 0 8 1 7 0 1 7 0 4 1 2 0 3 0 4 2 3 0 3 2 1 2 0 8 1 7 0 1 1 2 3 4 5 0
```
* 2.3 文件管理实验。  
&nbsp;&nbsp;2.3.1 利用fwrite接口不断追加写文件100万次，内容为“Guangzhou University,本人姓名（如张三）,学号”，用到的函数包括C库函数fopen(), fwrite(), fclose() 等。并用高精度时间获取函数（如C库的gettimeofday或C++库的chrono）计算写文件100万次所需的时间，以毫秒为单位；利用write接口不断追加写文件100万次，内容和上面相同，比较两者的性能差距，并给出原因。  
&nbsp;&nbsp;2.3.2 利用目录相关函数opendir、readdir、closedir，文件属性函数lstat等，模拟实现ls -l的功能。  

experiment3  
---
* 操作系统真象还原 (郑纲)  1 - 7 章 内容。  
&nbsp;&nbsp;虚拟磁盘文件名为 hd60m.img

course design  
---
* 操作系统真象还原 (郑纲)  8 - 10 章 内容。  
&nbsp;&nbsp;虚拟磁盘文件名为 hd60m.img

在学习过程中，参考了[seaswalker大大的tiny-os项目](https://github.com/seaswalker/tiny-os)，在此特别感谢！
