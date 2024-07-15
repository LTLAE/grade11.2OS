#include <iostream>
#include <unistd.h>
using namespace std;

int main(){
    int p1, p2;
    p1 = fork();
    if (p1 == 0) {
        lockf(1,1,0);
        for(int timer = 0; timer < 3; timer++) cout << "Children1" << endl;
        lockf(1,0,0);
    } else {
    	lockf(1,1,0);
        for(int timer = 0; timer < 3; timer++) cout << "Parent" << endl;
    	lockf(1,0,0);
    }
    p2 = fork();
    if (p2 == 0) {
       lockf(1,1,0);
       for(int timer = 0; timer < 3; timer++)  cout << "Children2" << endl;
       lockf(1,0,0);
    } else {
    	lockf(1,1,0);
        for(int timer = 0; timer < 3; timer++)  cout << "Parent" << endl;
    	lockf(1,0,0);
    }
}