/*
Jeremiah Whittenburg
Operating Systems CS33211
*/

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// Recursive wildcard matcher matching instructions
int match(char *pattern, char *str) {
    if (*pattern == '\0' && *str == '\0') return 1;
    if (*pattern == '*') {
        // Try matching zero or more characters against the wildcard
        if (match(pattern + 1, str)) return 1;
        if (*str != '\0' && match(pattern, str + 1)) return 1;
        return 0;
    }
    if (*pattern == *str) return match(pattern + 1, str + 1);
    return 0;
}

void find(char *path, char *pattern, char type_filter) {
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if ((fd = open(path, 0)) < 0) {
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }

    if (fstat(fd, &st) < 0) {
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        exit(1);
    }

    if (st.type != T_DIR) {
        close(fd);
        return;
    }

    if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
        close(fd);
        return;
    }
    strcpy(buf, path);
    p = buf + strlen(buf);
    *p++ = '/';

    while (read(fd, &de, sizeof(de)) == sizeof(de)) {
        if (de.inum == 0) continue;
        if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;

        memmove(p, de.name, DIRSIZ);
        p[DIRSIZ] = 0;

        if (stat(buf, &st) < 0) continue;

        // Determine if it matches constraints
        int name_matches = match(pattern, de.name);
        int type_matches = 1;
        if (type_filter == 'f' && (st.type != T_FILE && st.type != T_DEVICE)) type_matches = 0;
        if (type_filter == 'd' && st.type != T_DIR) type_matches = 0;

        if (name_matches && type_matches) {
            printf("%s\n", buf);
        }

        // Recursively search subdirectories
        if (st.type == T_DIR) {
            find(buf, pattern, type_filter);
        }
    }
    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(2, "usage: find <dir> <pattern> [-type f|d]\n");
        exit(1);
    }

    char *dir = argv[1];
    char *pattern = argv[2];
    char type_filter = 0; // 0 means no filter

    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "-type") == 0 && i + 1 < argc) {
            if (strcmp(argv[i+1], "f") == 0) type_filter = 'f';
            else if (strcmp(argv[i+1], "d") == 0) type_filter = 'd';
            i++;
        }
    }

    find(dir, pattern, type_filter);
    exit(0);
}