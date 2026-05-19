#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <sys/utsname.h>

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
    header.text = @"STIKJAIL RUN";
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
    header.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:header];
    
    // Status
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, screenWidth, 30)];
    self.statusLabel.text = @"Status: Ready to Execute";
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    // Log View
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(15, 130, screenWidth - 30, screenHeight - 250)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.logView.textColor = [UIColor greenColor];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 8;
    self.logView.text = @"[+] StikJail Binary Ready\n[+] UID: 501 (Current User)";
    [self.view addSubview:self.logView];
    
    // Inject Button
    self.injectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.injectButton.frame = CGRectMake(screenWidth/2 - 110, screenHeight - 100, 220, 55);
    self.injectButton.backgroundColor = [UIColor whiteColor];
    [self.injectButton setTitle:@"RUN EXPLOIT" forState:UIControlStateNormal];
    [self.injectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.injectButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.injectButton.layer.cornerRadius = 15;
    [self.injectButton addTarget:self action:@selector(executeExploit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.injectButton];
}

- (void)log:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [self.logView.text stringByAppendingFormat:@"\n%@", msg];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

- (void)executeExploit {
    self.injectButton.enabled = NO;
    self.injectButton.alpha = 0.5;
    self.statusLabel.text = @"Executing...";
    
    [self log:@"[!] Starting Real-time Exploit..."];
    
    // 1. SiriKitFlow Access Check
    [self log:@"[*] Checking SiriKitFlow framework..."];
    NSString *plistPath = @"/System/Library/PrivateFrameworks/SiriKitFlow.framework/Info.plist";
    if ([[NSFileManager defaultManager] isReadableFileAtPath:plistPath]) {
        [self log:@"[+] Success: SiriKitFlow is accessible."];
    } else {
        [self log:@"[-] Error: SiriKitFlow restricted."];
    }
    
    // 2. Real UID Escalation Attempt
    [self log:@"[*] Attempting setuid(0)..."];
    if (setuid(0) == 0) {
        [self log:@"[+++] ROOT ACCESS GRANTED!"];
    } else {
        [self log:@"[-] setuid(0) failed: Operation not permitted."];
    }
    
    // 3. Root Directory Write Test
    [self log:@"[*] Testing RootFS Write Access..."];
    NSError *error;
    [@"test" writeToFile:@"/private/var/mobile/stikjail_test" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        [self log:@"[+] Write Success: /private/var/mobile/"];
    } else {
        [self log:[NSString stringWithFormat:@"[-] Write Failed: %@", error.localizedDescription]];
    }
    
    // Final Result
    uid_t final_uid = getuid();
    if (final_uid == 0) {
        self.statusLabel.text = @"SUCCESS: ROOT";
        self.statusLabel.textColor = [UIColor greenColor];
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0 alpha:1];
    } else {
        [self log:@"\n[!] Final Result: Still in Sandbox (UID 501)"];
        [self log:@"[i] Need Kernel Exploit for this iOS version."];
        self.statusLabel.text = @"EXPLOIT FAILED";
        self.statusLabel.textColor = [UIColor redColor];
    }
    
    self.injectButton.enabled = YES;
    self.injectButton.alpha = 1.0;
    [self.injectButton setTitle:@"RUN AGAIN" forState:UIControlStateNormal];
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
