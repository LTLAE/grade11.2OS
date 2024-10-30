#include <iostream>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <iomanip>
#include <pwd.h>
#include <grp.h>

using namespace std;

void ls() { //use dir operation function to stimulate ls command
    DIR *dir = opendir(".");    //open current directory
    struct dirent *dirEntry = nullptr;    //read directory
    struct stat dirStat;
    if (dir == NULL) {
        cout << "Error opening directory." << endl;
        return;
    }
    //ChatGPT said readdir(dir) would return the address of the directory entry
    //If it reaches NULL, it reaches the end of the directory
    //Scan through directory to get the total blocks
    double totalBlocks = 0;
    while ((dirEntry = readdir(dir)) != NULL) {
        if (dirEntry->d_name[0] == '.') continue; //skip hidden files
        lstat(dirEntry->d_name, &dirStat);
        totalBlocks += dirStat.st_blocks;
    }
    cout << "total " << totalBlocks << endl; //total blocks

    //reopen directory to reset pointers
    closedir(dir);
    dir = opendir(".");

    //Scan through directory again to get details of each file
    while ((dirEntry = readdir(dir)) != NULL) {
        //dirEntry need to be updated in every loop
        //open file: dirEntry
        //lstat would receive file name as input, so dirEntry->d_name is used
        if (dirEntry->d_name[0] == '.') continue; //skip hidden files
        lstat(dirEntry->d_name, &dirStat);
        //permission checking codes from Internet
        //User permissions
        cout << ((dirStat.st_mode & S_IRUSR) ? "r" : "-");
        cout << ((dirStat.st_mode & S_IWUSR) ? "w" : "-");
        cout << ((dirStat.st_mode & S_IXUSR) ? "x" : "-");
        //Group permissions
        cout << ((dirStat.st_mode & S_IRGRP) ? "r" : "-");
        cout << ((dirStat.st_mode & S_IWGRP) ? "w" : "-");
        cout << ((dirStat.st_mode & S_IXGRP) ? "x" : "-");
        //Other permissions
        cout << ((dirStat.st_mode & S_IROTH) ? "r" : "-");
        cout << ((dirStat.st_mode & S_IWOTH) ? "w" : "-");
        cout << ((dirStat.st_mode & S_IXOTH) ? "x" : "-");
        cout << " ";

        cout << left << setw(4) << dirStat.st_nlink; //number of hard links
        cout << left << setw(10) << getpwuid(dirStat.st_uid)->pw_name; //owner name
        cout << left << setw(7) << getgrgid(dirStat.st_gid)->gr_name; //group name
        cout << left << setw(10) << dirStat.st_size; //file size
        string date = ctime(&dirStat.st_mtime);    //only output day, mon and year
        cout << left << setw(13) << date.substr(4, 12); //last modified time
        cout << dirEntry->d_name << endl;   //file name
    }
    closedir(dir);  //close current directory
}

int main() {

    //use fwrite()
    cout << "Using fwrite() to write to a File" << endl;
    FILE *fwriteFile = fopen("fwrite.txt", "w");
    if (fwriteFile == NULL) {
        cout << "Error opening File." << endl;
        return 1;
    }
    //use chrono with the help with ChatGPT
    chrono::time_point<chrono::steady_clock> start = chrono::steady_clock::now();   //get start time
    for(double timer = 0; timer < 10e6; timer++) {
        string data = "Guangzhou University, Name, ID " + to_string(
                chrono::duration_cast<chrono::milliseconds>(chrono::steady_clock::now().time_since_epoch()).count()) + " " + to_string(timer) + "\n";
        fwrite(data.c_str(), sizeof(char), data.size(), fwriteFile);
    }
    chrono::time_point<chrono::steady_clock> end = chrono::steady_clock::now(); //get end time
    chrono::duration<double> timeElapsed = end-start;   //change time to double for output
    std::cout << "fwrite() took: " << timeElapsed.count() << "s" << endl;
    fclose(fwriteFile);

    //use write()
    cout << "Using write() to write to a File" << endl;
    int writeFile = open("write.txt", O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
    if (writeFile == -1) {
        cout << "Error opening File." << endl;
        return 1;
    }
    //use chrono with the help with ChatGPT
    start = chrono::steady_clock::now();   //get start time
    for(double timer = 0; timer < 10e6; timer++) {
        string data = "Guangzhou University, Name, ID " + to_string(
                chrono::duration_cast<chrono::milliseconds>(chrono::steady_clock::now().time_since_epoch()).count()) + " " + to_string(timer) + "\n";
        write(writeFile, data.c_str(), data.size());
    }
    end = chrono::steady_clock::now(); //get end time
    timeElapsed = end-start;   //change time to double for output
    std::cout << "write() took: " << timeElapsed.count() << "s" << endl;
    close(writeFile);


    ls();
}
