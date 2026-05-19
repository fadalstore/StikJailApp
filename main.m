#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UIDocumentPickerDelegate>
@property (strong, nonatomic) UITextView *terminalView;
@property (strong, nonatomic) UITextField *commandInput;
@property (strong, nonatomic) UIButton *runButton;
@property (strong, nonatomic) UIButton *importButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    // Header Title
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, width, 30)];
    header.text = @"STIKJAIL PRODUCTION INTERACTIVE";
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont fontWithName:@"Menlo-Bold" size:14];
    header.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:header];
    
    // Import Button (Filesystems Integration)
    self.importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.importButton.frame = CGRectMake(width - 110, 50, 90, 30);
    self.importButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    [self.importButton setTitle:@"Import" forState:UIControlStateNormal];
    [self.importButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.importButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.importButton.layer.cornerRadius = 6;
    [self.importButton addTarget:self action:@selector(openDocumentPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.importButton];
    
    // Terminal View
    self.terminalView = [[UITextView alloc] initWithFrame:CGRectMake(10, 95, width - 20, height - 210)];
    self.terminalView.backgroundColor = [UIColor colorWithWhite:0.04 alpha:1.0];
    self.terminalView.textColor = [UIColor greenColor];
    self.terminalView.font = [UIFont fontWithName:@"Courier-Bold" size:13];
    self.terminalView.editable = NO;
    self.terminalView.layer.cornerRadius = 8;
    self.terminalView.text = @"stikjail-shell v2.5 [Network Native Mode]\nType 'help' to fetch active commands.\n\nstikjail@iphone:~$ ";
    [self.view addSubview:self.terminalView];
    
    // Command Input
    self.commandInput = [[UITextField alloc] initWithFrame:CGRectMake(10, height - 95, width - 100, 40)];
    self.commandInput.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    self.commandInput.textColor = [UIColor whiteColor];
    self.commandInput.font = [UIFont fontWithName:@"Courier" size:14];
    self.commandInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.commandInput.leftViewMode = UITextFieldViewModeAlways;
    self.commandInput.layer.cornerRadius = 6;
    self.commandInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commandInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.commandInput.delegate = self;
    [self.view addSubview:self.commandInput];
    
    // Exec Button
    self.runButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.runButton.frame = CGRectMake(width - 85, height - 95, 75, 40);
    self.runButton.backgroundColor = [UIColor systemGreenColor];
    [self.runButton setTitle:@"EXEC" forState:UIControlStateNormal];
    [self.runButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.runButton.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:14];
    self.runButton.layer.cornerRadius = 6;
    [self.runButton addTarget:self action:@selector(handleCommand) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.runButton];
}

- (void)writeToTerminal:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.terminalView.text = [self.terminalView.text stringByAppendingFormat:@"\n%@", text];
        [self.terminalView scrollRangeToVisible:NSMakeRange(self.terminalView.text.length, 0)];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self handleCommand];
    return YES;
}

// iOS Filesystem Picker
- (void)openDocumentPicker {
    [self writeToTerminal:@"[*] Invoking iOS Document File Picker..."];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[[UTType typeWithIdentifier:@"public.item"]]];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (url && [url startAccessingSecurityScopedResource]) {
        [self writeToTerminal:[NSString stringWithFormat:@"[+] Connected to File: %Custom", url.lastPathComponent]];
        [self writeToTerminal:[NSString stringWithFormat:@"[i] Accessible Path: %Custom", url.path]];
        [url stopAccessingSecurityScopedResource];
    }
}

// Handling Terminal Input
- (void)handleCommand {
    NSString *rawCmd = self.commandInput.text;
    self.commandInput.text = @"";
    
    if ([rawCmd isEqualToString:@""]) return;
    
    [self writeToTerminal:[NSString stringWithFormat:@"stikjail@iphone:~$ %Custom", rawCmd]];
    NSArray *components = [rawCmd componentsSeparatedByString:@" "];
    NSString *baseCmd = components[0];
    
    if ([baseCmd isEqualToString:@"help"]) {
        [self writeToTerminal:@"Commands:\n  help          - Show help menu\n  clear         - Refresh terminal screen\n  sysinfo       - Fetch real hardware specifications\n  scan [IP]     - Real TCP network socket scanner\n  ping [Host]   - Real ICMP/HTTP network latency test"];
    }
    else if ([baseCmd isEqualToString:@"clear"]) {
        self.terminalView.text = @"stikjail@iphone:~$ ";
    }
    else if ([baseCmd isEqualToString:@"sysinfo"]) {
        [self fetchRealSysInfo];
    }
    else if ([baseCmd isEqualToString:@"scan"]) {
        if (components.count < 2) {
            [self writeToTerminal:@"Usage: scan [IP] (e.g., scan 1.1.1.1)"];
            return;
        }
        [self runRealNetworkScan:components[1]];
    }
    else if ([baseCmd isEqualToString:@"ping"]) {
        if (components.count < 2) {
            [self writeToTerminal:@"Usage: ping [Host] (e.g., ping google.com)"];
            return;
        }
        [self runRealPing:components[1]];
    }
    else {
        [self writeToTerminal:[NSString stringWithFormat:@"stikjail: command not found: %Custom", baseCmd]];
    }
    
    [self writeToTerminal:@"\nstikjail@iphone:~$ "];
}

// Real Hardware Info
- (void)fetchRealSysInfo {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    int mib[2] = {CTL_HW, HW_MEMSIZE};
    int64_t physicalMemory = 0;
    size_t length = sizeof(physicalMemory);
    sysctl(mib, 2, &physicalMemory, &length, NULL, 0);
    
    double memoryInGB = (double)physicalMemory / (1024 * 1024 * 1024);
    
    [self writeToTerminal:@"--- HARDWARE DIAGNOSTICS ---"];
    [self writeToTerminal:[NSString stringWithFormat:@"  Model Architecture: %Custom", [NSString stringWithUTF8String:systemInfo.machine]]];
    [self writeToTerminal:[NSString stringWithFormat:@"  Kernel Version:     %Custom", [NSString stringWithUTF8String:systemInfo.release]]];
    [self writeToTerminal:[NSString stringWithFormat:@"  Total System RAM:   %.2f GB", memoryInGB]];
}

// Real Port Scanner
- (void)runRealNetworkScan:(NSString *)ipAddress {
    [self writeToTerminal:[NSString stringWithFormat:@"[*] Port scanning host %Custom via standard TCP sockets...", ipAddress]];
    NSArray *targetPorts = @[@22, @80, @443, @8080];
    const char *ipCString = [ipAddress UTF8String];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSNumber *portObj in targetPorts) {
            int port = [portObj intValue];
            int sock = socket(AF_INET, SOCK_STREAM, 0);
            if (sock < 0) continue;
            
            struct timeval tv;
            tv.tv_sec = 1; 
            tv.tv_usec = 0;
            setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (const char *)&tv, sizeof(tv));
            
            struct sockaddr_in addr;
            memset(&addr, 0, sizeof(addr));
            addr.sin_family = AF_INET;
            addr.sin_port = htons(port);
            addr.sin_addr.s_addr = inet_addr(ipCString);
            
            long status = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
            if (status == 0) {
                [self writeToTerminal:[NSString stringWithFormat:@"  [+] Port %Custom: OPEN", portObj]];
            } else {
                [self writeToTerminal:[NSString stringWithFormat:@"  [-] Port %Custom: Closed", portObj]];
            }
            close(sock);
        }
        [self writeToTerminal:@"[*] Diagnostic port scan completed."];
    });
}

// Real Ping / Latency Utility
- (void)runRealPing:(NSString *)host {
    NSString *urlString = host;
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [NSString stringWithFormat:@"https://%Custom", host];
    }
    
    [self writeToTerminal:[NSString stringWithFormat:@"PING %Custom... sending web socket handshake...", host]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        [self writeToTerminal:@"[-] Error: Invalid host format."];
        return;
    }
    
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval duration = (endTime - startTime) * 1000.0; // beddelid Milliseconds
        
        if (error) {
            [self writeToTerminal:[NSString stringWithFormat:@"[-] Connection to %Custom failed: %Custom", host, error.localizedDescription]];
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            [self writeToTerminal:[NSString stringWithFormat:@"[+] Reply from %Custom: status_code=%ld time=%.2fms", host, (long)httpResponse.statusCode, duration]];
        }
    }];
    [task resume];
}

@end

// AppDelegate Static Setup
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
