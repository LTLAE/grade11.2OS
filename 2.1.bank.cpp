#include <iostream>
#include <fstream>
#include <algorithm>

#define processCount 5
#define resourceCount 3
using namespace std;



int main(int argc, char *argv[]) {
    //incorrect input
    if(argc != 2) {
        cout << "Bank: Missing File" << endl;
        cout << "Usage: Bank [Resource File]" << endl;
        cout << "Don't try 'bank --help' for more options." << endl;
        exit(0);
    }

    //bank program starts here
    int available[resourceCount];                   //system - sum(allocation)
    int max[processCount][resourceCount];           //record resources that every currentProcess requests
    int allocation[processCount][resourceCount];    //record resources that every currentProcess has
    int need[processCount][resourceCount];          //max - allocation
    int currentProcess;                             //which Process is asking for resource
    int request[resourceCount];                     //record resources that current currentProcess requests
    int system[resourceCount];                      //resource system have
    ifstream file;
    // file.open("data5");     //for debug
    file.open(argv[1]);     //uncomment to use './bank data'
    /*
    int data;
    for (int timer = 0; timer < 37; timer++) {
        file >> data;
        cout << data << '\t';
    }
     */

    //use file >> var<int> to get the next value, 37 values in total
    file >> currentProcess;
    for (int timer = 0; timer < resourceCount; timer++) file >> request[timer];
    for (int timer = 0; timer < resourceCount; timer++) file >> system[timer];
    for (int timer = 0; timer < resourceCount; timer++) available[timer] = system[timer];
    for (int process = 0; process < processCount; process++) {
        for (int resource = 0; resource < resourceCount; resource++) file >> max[process][resource];
        for (int resource = 0; resource < resourceCount; resource++) file >> allocation[process][resource];
        for (int resource = 0; resource < resourceCount; resource++) need[process][resource] = max[process][resource] - allocation[process][resource];
        for (int resource = 0; resource < resourceCount; resource++) available[resource] = available[resource] - allocation[process][resource];
    }
    file.close();
    //data import finished

    //check if the solution exist
    for (int resource = 0; resource < resourceCount; resource++) {
        if (request[resource] > need[currentProcess][resource]) {
            cout << "Error: Current process is requesting more resources then needed." << endl;
            exit(0);
        }
        if (request[resource] > available[resource]) {
            cout << "Error: Current process is requesting more resources then the system has." << endl;
            exit(0);
        }
    }
    //banker
    bool finish[processCount] = {0};                //a temp array to test if system is safe
    int work[resourceCount];                        //a temp array to test if system is safe
    int sequence[processCount];                     //use this array to record safe sequence
    int safe = 1;                                   //system safe?
    for (int timer = 0; timer < resourceCount; timer++) work[timer] = available[timer];
    for (int timer = 0; timer < processCount; timer++) sequence[timer] = -1;

    //try giving currentProcess resources it required
    int sequenceCount = 0;
    //if request can not be finished, safe = 0
    for (int timer = 0; timer < resourceCount; timer++) {
        if (request[timer] > work[timer]) {
            safe = 0;
            for (int resource = 0; resource < resourceCount; resource++) finish[resource] = 1;
            break;
        }
    }
    //if request can be finished, give it resources
    if (safe == 1) {
        for (int timer = 0; timer < resourceCount; timer++) {
            work[timer] -= request[timer];
            allocation[currentProcess][timer] += request[timer];
            need[currentProcess][timer] -= request[timer];
        }
    }
    //search which process to give resources next
    //loop will end normally when finish[] = {1}, when system is not safe, loop will break
    while (all_of(finish, finish + processCount, [](int i) { return i == 1; }) == 0 && safe == 1) {
        bool processGiven = 0;  //if any process received resource, processGiven = 1
        for (int scanner = 0; scanner < processCount; scanner++) {
            if (finish[scanner] == 1) continue; //skip finished process
            //can process [scanner] be finished? flag = 1 if yes
            int flag = 1;
            for (int timer = 0; timer < resourceCount; timer++) {
                if (need[scanner][timer] > work[timer]) {
                    flag = 0;
                    break;
                }
            }
            if (flag == 1 && finish[scanner] == 0) {
                //give process [scanner] resources it required
                sequence[sequenceCount] = scanner;
                sequenceCount++;
                for (int timer = 0; timer < resourceCount; timer++) work[timer] += allocation[scanner][timer];
                finish[scanner] = 1;
                processGiven = 1;
                scanner = -1;   //reset scanner to 0, -1 for scanner ++ at the end of loop
            }
        }
        //if no process is finished, system is not safe
        if (processGiven == 0) {
            safe = 0;
            break;
        }
    }

    if (safe == 1) {    //remember to 'go to interrupt handling program'
        //system safe
        cout << "System is safe after providing process " << currentProcess << " with " << request[0] << " " << request[1] << " " << request[2] << endl;
        cout << "A possible safe sequence is: ";
        for (int timer = 0; timer < processCount; timer++) cout << sequence[timer] << " ";
        cout << endl;
        exit(0);
    } else {
        //system not safe
        cout << "System is not safe after providing process " << currentProcess << " with " << request[0] << " " << request[1] << " " << request[2] << endl;
        cout << "A possible safe sequence is: ";
        for (int timer = 0; timer < processCount; timer++) cout << sequence[timer] << " ";
        cout << endl;
        exit(0);
    }
}

//special thank to Daxie_White for logical support
//special thank to Demitail for debugging support