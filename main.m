#import <Foundation/Foundation.h>
#import <unistd.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {
        printf("[+] StikJail: Waxaa bilaamay baaritaanka cloud-ka...\n");
        uid_t current_uid = getuid();
        printf("[+] Aqoonsiga Isticmaalaha (UID): %d\n", current_uid);
        
        if (current_uid == 0) {
            printf("[+++] Success: Mishiinku wuxuu ku socdaa ROOT!\n");
        } else {
            printf("[-] Warning: Mishiinku wuxuu ku jiraa Sandbox caadi ah.\n");
        }
    }
    return 0;
}

