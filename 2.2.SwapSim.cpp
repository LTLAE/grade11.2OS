#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
using namespace std;

int WhichIsTheMax(int arr[], int size) {
    int maxIndex = 0;
    int maxNum = arr[0];
    for (int timer = 1; timer < size; timer++) {
        if (arr[timer] > maxNum) {
            maxNum = arr[timer];
            maxIndex = timer;
        }
    }
    return maxIndex;
}   //return max element's index

int WhichIsTheElement(int arr[], int size, int elem) {
    for (int timer = 0; timer < size; timer++) {
        if (arr[timer] == elem) return timer;
    }
    return -1;
}   //return the requested element's index

void OPT(int * ram, int ramSize, int pages[], int pageCount) {
    cout << "OPT" << endl;
    int hit = 0;
    int pageProgress = 0;
    //fill the ram
    for (; pageProgress < ramSize; pageProgress++) {
        ram[pageProgress] = pages[pageProgress];
    }

    while (pageProgress < pageCount - 1) {
        cout << "Ram: [";
        for (int timer = 0; timer < ramSize - 1; timer++)   cout << ram[timer] << " , ";
        cout << ram[ramSize - 1] << "] Next page: " << pages[pageProgress] << endl;

        if (find (ram, ram + ramSize, pages[pageProgress]) != ram + ramSize) {
            //page in ram
            hit++;
            pageProgress++;
        } else {
            //page not in ram
            int timeToNextRead[ramSize];    //record the time to next read of each page in ram
            bool foundNextElem[ramSize];  //1 when the page is found
            for (int timer = 0; timer < ramSize; timer++) {
                timeToNextRead[timer] = 0;
                foundNextElem[timer] = false;
            }
            for (int scanner = pageProgress; scanner < pageCount - 1; scanner++) {   //use scanner to scan the pages after current page
                for (int process = 0; process < ramSize; process++) {
                    if (ram[process] == pages[scanner]) {
                        timeToNextRead[process] = scanner - pageProgress;
                        foundNextElem[process] = true;
                    }
                    //if all pages are found, break
                    if (all_of(foundNextElem, foundNextElem + ramSize, [](bool i) {return i;})) {
                        break;
                    }
                }
            }
            //replace the page
            //if a page is not found, replace it
            if (find(foundNextElem, foundNextElem + ramSize, false) != foundNextElem + ramSize) {
                ram[find(foundNextElem, foundNextElem + ramSize, false) - foundNextElem] = pages[pageProgress];
                pageProgress++;
            } else {
            //if all pages are found
            ram[WhichIsTheMax(timeToNextRead, ramSize)] = pages[pageProgress];
            pageProgress++;
            }
        }
    }
    cout << "OPT end. Hit: " << hit << " Acc:" << static_cast<double>(hit)/static_cast<double>(pageCount) << endl;
}

void FIFO(int * ram, int ramSize, int pages[], int pageCount){
    cout << "FIFO" << endl;
    int hit = 0;
    int pageProgress = 0;
    //fill the ram
    for (; pageProgress < ramSize; pageProgress++) {
        ram[pageProgress] = pages[pageProgress];
    }
    //ram filled with sequence 0 1 2 3 ... ramSize - 1. So I just rotate them.
    int rotate = 0;
    while (pageProgress < pageCount - 1) {
        cout << "Ram: [";
        for (int timer = 0; timer < ramSize - 1; timer++) cout << ram[timer] << " , ";
        cout << ram[ramSize - 1] << "] Next page: " << pages[pageProgress] << endl;

        if (rotate == ramSize) rotate = 0;
        if (find(ram, ram + ramSize, pages[pageProgress]) != ram + ramSize) hit++;  //count hits
        else {
            ram[rotate] = pages[pageProgress];
            rotate++;
        }
        pageProgress++;
    }
    cout << "FIFO end. Hit: " << hit << " Acc:" << static_cast<double>(hit)/static_cast<double>(pageCount) << endl;
}

void LRU(int * ram, int ramSize, int pages[], int pageCount){
    cout << "LRU" << endl;
    int hit = 0;
    int pageProgress = 0;
    vector<int> NotAStack;  //Use a vector to simulate the stack
    //Use vector.insert to simulate push and vector.erase to simulate pop
    //Just find the element and erase it. It is easier than actually operating a stack
    //fill the ram
    for (; pageProgress < ramSize; pageProgress++) {
        ram[pageProgress] = pages[pageProgress];
        NotAStack.insert(NotAStack.begin(), pages[pageProgress]);
    }

    while (pageProgress < pageCount - 1) {
        cout << "Ram: [";
        for (int timer = 0; timer < ramSize - 1; timer++) cout << ram[timer] << " , ";
        cout << ram[ramSize - 1] << "] Next page: " << pages[pageProgress] << endl;

        if (find(ram, ram + ramSize, pages[pageProgress]) != ram + ramSize) {
            //page in ram
            hit++;
            NotAStack.erase(find(NotAStack.begin(), NotAStack.end(), pages[pageProgress]));
            NotAStack.insert(NotAStack.begin(), pages[pageProgress]);
            pageProgress++;
        } else {
            //page not in ram
            ram[WhichIsTheElement(ram, ramSize, NotAStack.back())] = pages[pageProgress];
            NotAStack.erase(NotAStack.end() - 1);
            NotAStack.insert(NotAStack.begin(), pages[pageProgress]);
            pageProgress++;
        }
    }

    cout << "LRU end. Hit: " << hit << " Acc:" << static_cast<double>(hit)/static_cast<double>(pageCount) << endl;
}

void ClearRam(int *ram, int ramSize) {
    for (int timer = 0; timer < ramSize; timer++) ram[timer] = -1;
}

int main(int argc, char *argv[]) {
    //incorrect input
    if(argc != 2) {
        cout << "SwapSim: Missing File" << endl;
        cout << "Usage: SwapSim [Resource File]" << endl;
        cout << "Don't try 'swapsim --help' for more options." << endl;
        exit(0);
    }

    int ramSize;
    int pageCount;
    ifstream file;
    //file.open("data");     //for debug
    file.open(argv[1]);     //uncomment to use './swapsim data'
    file >> ramSize;
    //I have no idea but the array 'ram' would be ram[50] and the program runs perfectly
    //Concerning about the memory?
    //ramSize = 4;
    int ram[ramSize];
    file >> pageCount;
    int pages[pageCount + 1];
    pages[pageCount] = -1;  //page sequence ends with -1
    for (int timer = 0; timer < pageCount; timer++) {
        file >> pages[timer];
    }
    file.close();
    //data import finished
    ClearRam(ram, ramSize);
    OPT(ram, ramSize, pages, pageCount);
    ClearRam(ram, ramSize);
    FIFO(ram, ramSize, pages, pageCount);
    ClearRam(ram, ramSize);
    LRU(ram, ramSize, pages, pageCount);

}
