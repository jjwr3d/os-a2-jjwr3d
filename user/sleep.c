/*
Jeremiah Whittenburg
Operating Systems CS33211
*/

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }

    char *s = argv[1];
    // Check if the argument is negative, empty, or contains non-digits
    if (s[0] == '\0') {
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }
    
    int start = 0;
    if (s[0] == '-') { // Catch explicit negatives upfront
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }

    for (int i = start; s[i] != '\0'; i++) {
        if (s[i] < '0' || s[i] > '9') {
            fprintf(2, "usage: sleep <ticks>\n");
            exit(1);
        }
    }

    int ticks = atoi(argv[1]);
    if (pause(ticks) < 0) { // Using pause() per instructions
        exit(1);
    }

    exit(0);
}