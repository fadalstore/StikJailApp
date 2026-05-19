#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
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
    
    // Header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, width, 30)];
    header.text = @"STIKJAIL SYSTEM ENGINE";
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont fontWithName:@"Menlo-Bold" size:16];
    header.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:header];
    
    // Import Button (Sida Filesystems UI)
    self.importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.importButton.frame = CGRectMake(width - 110, 50, 90, 30);
    self.importButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    [self.importButton setTitle:@"Import" forState:UIControlStateNormal];
    [self.importButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.importButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.importButton.layer.cornerRadius = 6;
    [self.importButton addTarget:self action:@selector(openDocumentPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.importButton];
    
    // Terminal View (Output)
    self.terminalView = [[UITextView alloc] initWithFrame:CGRectMake(10, 95, width - 20, height - 210)];
    self.terminalView.backgroundColor = [UIColor colorWithWhite:0.04 alpha:1.0];
    self.terminalView.textColor = [UIColor greenColor];
    self.terminalView.font = [UIFont fontWithName:@"Courier-Bold" size:13];
    self.terminalView.editable = NO;
    self.terminalView.layer.cornerRadius = 8;
    self.terminalView.text = @"stikjail-term v1.5 [Internet Active]\nType 'help' to check available operations.\n\nstikjail@iphone:~$ ";
    [self.view addSubview:self.terminalView];
    
    // Command Input Field
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
    
    // Run Button
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

// 1. Furista Galka iPhone-ka (Document Picker)
- (void)openDocumentPicker {
    [self writeToTerminal:@"[*] Launching native iOS Document Picker..."];
    
    // Oggolaanshaha dhammaan faylasha caadiga ah
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[[UTType typeWithIdentifier:@"public.item"]]];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

// 2. Marka isticmaalahu doorto faylka dhabta ah
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *selectedURL = urls.firstObject;
    if (selectedURL) {
        // Codsashada oggolaanshaha nidaamka faylka
        if ([selectedURL startAccessingSecurityScopedResource]) {
            NSString *fileName = selectedURL.lastPathComponent;
            [self writeToTerminal:[NSString stringWithFormat:@"[+] Successfully imported file: %Custom", fileName]];
            [self writeToTerminal:[NSString stringWithFormat:@"[*] Target Virtual Path: /Documents/%Custom", fileName]];
            
            // Halkan waxaad ku dhex qori kartaa shaqo faylka lagu falanqeynayo haddii loo baahdo
            
            [selectedURL stopAccessingSecurityScopedResource];
        } else {
            [self writeToTerminal:@"[-] Security access denied for the selected file."];
        }
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self writeToTerminal:@"[-] Import operation cancelled by user."];
}

// 3. Maareynta Amarrada Terminal-ka
- (void)handleCommand {
    NSString *rawCmd = self.commandInput.text;
    self.commandInput.text = @"";
    
    if ([rawCmd isEqualToString:@""]) return;
    
    [self writeToTerminal:[NSString stringWithFormat:@"stikjail@iphone:~$ %Custom", rawCmd]];
    
    NSArray *components = [rawCmd componentsSeparatedByString:@" "];
    NSString *baseCmd = components[0];
    
    if ([baseCmd isEqualToString:@"help"]) {
        [self writeToTerminal:@"Available Operations:\n  help          - Display this assistance manual\n  clear         - Refresh terminal screen\n  scan [IP]     - Launch network port diagnostic scan"];
    }
    else if ([baseCmd isEqualToString:@"clear"]) {
        self.terminalView.text = @"stikjail@iphone:~$ ";
    }
    else if ([baseCmd isEqualToString:@"scan"]) {
        if (components.count < 2) {
            [self writeToTerminal:@"Usage: scan [IP_ADDRESS] (e.g., scan 1.1.1.1)"];
            return;
        }
        NSString *targetIP = components[1];
        [self runNativeScan:targetIP];
    }
    else {
        [self writeToTerminal:[NSString stringWithFormat:@"sh: command unknown: %Custom", baseCmd]];
    }
    
    [self writeToTerminal:@"\nstikjail@iphone:~$ "];
}

- (void)runNativeScan:(NSString *)ipAddress {
    [self writeToTerminal:[NSString stringWithFormat:@"[*] Initiating internet socket analysis on target: %Custom...", ipAddress]];
    
    NSArray *portsToScan = @[@21, @22, @80, @443, @8080];
    const char *ipCString = [ipAddress UTF8String];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSNumber *portObj in portsToScan) {
            int port = [portObj intValue];
            int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
            
            if (socketFileDescriptor < 0) continue;
            
            struct timeval timeout;
            timeout.tv_sec = 1;
            timeout.tv_usec = 0;
            setsockopt(socketFileDescriptor, SOL_SOCKET, SO_SNDTIMEO, (const char *)&timeout, sizeof(timeout));
            
            struct sockaddr_in serverAddress;
            memset(&serverAddress, 0, sizeof(serverAddress));
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_port = htons(port);
            serverAddress.sin_addr.s_addr = inet_addr(ipCString);
            
            long result = connect(socketFileDescriptor, (struct sockaddr *)&serverAddress, sizeof(serverAddress));
            
            if (result == 0) {
                [self writeToTerminal:[NSString stringWithFormat:@"  [+] Port %Custom: OPEN (Service Active)", portObj]];
            } else {
                [self writeToTerminal:[NSString stringWithFormat:@"  [-] Port %Custom: Connection Refused", portObj]];
            }
            
            close(socketFileDescriptor);
        }
        [self writeToTerminal:@"[*] Network utility scan finished."];
    });
}

@end

// AppDelegate & Main Functions remain unchanged...
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
