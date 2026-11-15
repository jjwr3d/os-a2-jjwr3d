/*
Jeremiah Whittenburg
Operating Systems CS33211
*/

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int n_limit = -1;
    int cmd_idx = 1;

    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
        if (argc < 4) {
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
            exit(1);
        }
        n_limit = atoi(argv[2]);
        if (n_limit < 1) {
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
            exit(1);
        }
        cmd_idx = 3;
    }

    char *cmd = argv[cmd_idx];
    char *xargv[MAXARG];
    int base_argc = 0;

    // Fill initial execution arguments
    for (int i = cmd_idx; i < argc; i++) {
        xargv[base_argc++] = argv[i];
    }

    char buf[1024];
    int n, buf_len = 0;
    int global_status = 0;

    // Read everything from stdin
    while ((n = read(0, buf + buf_len, sizeof(buf) - buf_len - 1)) > 0) {
        buf_len += n;
        buf[buf_len] = '\0';

        char *words[MAXARG];
        int word_count = 0;
        char *p = buf;
        char *word_start = 0;
        char *last_processed = buf;

        while (*p) {
            // Check if character is a delimiter
            if (*p == ' ' || *p == '\t' || *p == '\n') {
                if (word_start) {
                    *p = '\0';
                    words[word_count++] = word_start;
                    word_start = 0;
                }
                
                // Trigger condition
                int should_run = 0;
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
                    should_run = 1; // Run once per non-empty line
                } else if (n_limit > 0 && word_count == n_limit) {
                    should_run = 1; // Run when batch limit hit
                }

                if (should_run) {
                    int curr_argc = base_argc;
                    for (int i = 0; i < word_count; i++) {
                        xargv[curr_argc++] = words[i];
                    }
                    xargv[curr_argc] = 0;

                    int pid = fork();
                    if (pid == 0) {
                        exec(cmd, xargv);
                        fprintf(2, "xargs: exec failed\n");
                        exit(1);
                    } else {
                        int status;
                        wait(&status);
                        if (status != 0) global_status = 1;
                    }
                    word_count = 0;
                    last_processed = p + 1;
                }
            } else {
                if (!word_start) word_start = p;
            }
            p++;
        }

        // Shift unprocessed partial chunks back to buffer head
        int processed_bytes = last_processed - buf;
        if (processed_bytes > 0) {
            memmove(buf, last_processed, buf_len - processed_bytes);
            buf_len -= processed_bytes;
        }
    }

    // Handle any trailing words if -n N was used and stdin ended without filling a final batch
    if (n_limit > 0 && buf_len > 0) {
        char *words[MAXARG];
        int word_count = 0;
        char *p = buf;
        char *word_start = 0;
        while (p < buf + buf_len) {
            if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\0') {
                if (word_start) {
                    *p = '\0';
                    words[word_count++] = word_start;
                    word_start = 0;
                }
            } else {
                if (!word_start) word_start = p;
            }
            p++;
        }
        if (word_count > 0) {
            int curr_argc = base_argc;
            for (int i = 0; i < word_count; i++) {
                xargv[curr_argc++] = words[i];
            }
            xargv[curr_argc] = 0;
            int pid = fork();
            if (pid == 0) {
                exec(cmd, xargv);
                exit(1);
            } else {
                int status;
                wait(&status);
                if (status != 0) global_status = 1;
            }
        }
    }

    exit(global_status);
}