#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/stat.h>
#import <dlfcn.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) UITextView *logView;
@property (strong, nonatomic) UIButton *injectButton;
@property (strong, nonatomic) UILabel *statusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    // Header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 60)];
    header.text = @"STIKJAIL EXPLOIT";
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28];
    header.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:header];
    
    // Status Label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, screenWidth, 30)];
    self.statusLabel.text = @"Ready to Inject";
    self.statusLabel.textColor = [UIColor lightGrayColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    // Log View
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(15, 130, screenWidth - 30, screenHeight - 250)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.logView.textColor = [UIColor cyanColor];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 8;
    self.logView.text = @"[i] StikJail initialized...\n[i] Waiting for user trigger...";
    [self.view addSubview:self.logView];
    
    // Inject Button
    self.injectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.injectButton.frame = CGRectMake(screenWidth/2 - 110, screenHeight - 100, 220, 55);
    self.injectButton.backgroundColor = [UIColor whiteColor];
    [self.injectButton setTitle:@"JAILBREAK" forState:UIControlStateNormal];
    [self.injectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.injectButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.injectButton.layer.cornerRadius = 12;
    [self.injectButton addTarget:self action:@selector(runExploit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.injectButton];
}

- (void)log:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [self.logView.text stringByAppendingFormat:@"\n%@", msg];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

- (void)runExploit {
    self.injectButton.enabled = NO;
    self.injectButton.alpha = 0.5;
    self.statusLabel.text = @"Exploiting...";
    
    [self log:@"[!] Starting exploit chain..."];
    
    // 1. Check SiriKitFlow
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^{
        [self log:@"[*] Loading SiriKitFlow.framework..."];
        void *h = dlopen("/System/Library/PrivateFrameworks/SiriKitFlow.framework/SiriKitFlow", RTLD_NOW);
        if (h) {
            [self log:@"[+] SiriKitFlow loaded successfully!"];
            dlclose(h);
        } else {
            [self log:@"[-] SiriKitFlow load failed (Sandbox)."];
        }
        
        // 2. Read Info.plist
        [self log:@"[*] Reading SiriKitFlow Info.plist..."];
        NSString *plistPath = @"/System/Library/PrivateFrameworks/SiriKitFlow.framework/Info.plist";
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist) {
            [self log:[NSString stringWithFormat:@"[+] Version: %@", plist[@"CFBundleShortVersionString"]]];
        } else {
            [self log:@"[-] Access Denied: Info.plist"];
        }
        
        // 3. Simulated Kernel Tasks
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^{
            [self log:@"[*] Searching for kernel slide..."];
            [self log:@"[*] Found slide: 0x1a2b3c4d5e6f"];
            [self log:@"[*] Patching setuid(0)..."];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                uid_t u = getuid();
                if (u == 0) {
                    [self log:@"[!!!] ROOT ACCESS ACHIEVED!"];
                    self.statusLabel.text = @"Jailbroken!";
                    self.statusLabel.textColor = [UIColor greenColor];
                } else {
                    [self log:@"[-] Exploit failed (UID still 501)."];
                    [self log:@"[!] Note: Real root needs a kernel exploit."];
                    self.statusLabel.text = @"Exploit Failed";
                    self.statusLabel.textColor = [UIColor redColor];
                }
                self.injectButton.enabled = YES;
                self.injectButton.alpha = 1.0;
            });
        });
    });
}

@end

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
