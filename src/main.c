#include <windows.h>
#include <stdlib.h>
#include <stdio.h>

extern char** environ;

int main(int argc, char* argv[]) {
#if DEBUG
    if (GetStdHandle(STD_OUTPUT_HANDLE) == INVALID_HANDLE_VALUE) {
        AttachConsole(ATTACH_PARENT_PROCESS /* (DWORD) -1 */);
    }
#endif
    char path[MAX_PATH];
    GetModuleFileName(NULL, path, MAX_PATH);
    fprintf(stdout, "Hello, %s!\n", path);

    return EXIT_SUCCESS;
}
