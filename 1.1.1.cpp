#include <iostream>
#include <unistd.h>
using namespace std;

int main(){
int p1, p2;
p1 = fork();
if (p1 == 0) cout << "Children1" << endl;
else cout << "Parent" << endl;
p2 = fork();
if (p2 == 0) cout << "Children2" << endl;
else cout << "Parent" << endl;
}
