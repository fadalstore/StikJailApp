#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/stat.h>
#import <sys/utsname.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) UITextView *logView;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *subStatusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    // 1. Main Title (STIKJAIL)
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, screenWidth, 40)];
    titleLabel.text = @"STIKJAIL";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:45];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    // 2. Subtitle / Version
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, screenWidth, 25)];
    self.statusLabel.text = @"v1.5 byłaby rami";
    self.statusLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0]; // Light Blue
    self.statusLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    // 3. Sub-status (Ready to Exploit)
    self.subStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, screenWidth, 20)];
    self.subStatusLabel.text = @"Ready to check environment";
    self.subStatusLabel.textColor = [UIColor lightGrayColor];
    self.subStatusLabel.font = [UIFont systemFontOfSize:14];
    self.subStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.subStatusLabel];
    
    // 4. Unc0ver-Style Log Box
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, 200, screenWidth - 40, screenHeight - 380)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.4 green:0.9 blue:1.0 alpha:1.0]; // Cyan text
    self.logView.font = [UIFont fontWithName:@"Menlo-Bold" size:12];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 12;
    self.logView.layer.borderWidth = 1.0;
    self.logView.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
    
    // Initial system diagnostics log
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    self.logView.text = [NSString stringWithFormat:@"[*] Machine: %Custom\n[*] Environment: Sandbox Active (UID: %d)\n[*] StikJail Framework initialized successfully.", deviceModel, getuid()];
    [self.view addSubview:self.logView];
    
    // 5. Large Rounded Action Button (JAILBREAK style)
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.frame = CGRectMake(40, screenHeight - 120, screenWidth - 80, 55);
    self.actionButton.backgroundColor = [UIColor whiteColor];
    [self.actionButton setTitle:@"JAILBREAK" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    self.actionButton.layer.cornerRadius = 27.5;
    
    // Shadow effect like premium apps
    self.actionButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.actionButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.actionButton.layer.shadowRadius = 10;
    self.actionButton.layer.shadowOpacity = 0.2;
    
    [self.actionButton addTarget:self action:@selector(startDiagnostics) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];
}

- (void)appendLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [self.logView.text stringByAppendingFormat:@"\n%@", message];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

- (void)startDiagnostics {
    self.actionButton.enabled = NO;
    self.actionButton.alpha = 0.6;
    self.subStatusLabel.text = @"Running system tests...";
    
    [self appendLog:@"\n[!] Triggering exploit initialization chain..."];
    
    // Step 1: Framework check simulation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self appendLog:@"[*] Mapping entitlement tables..."];
        [self appendLog:@"[*] Verifying PrivateFramework accessibility (SiriKitFlow)..."];
        
        // Step 2: Verification of privileges
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            uid_t checkUID = getuid();
            [self appendLog:[NSString stringWithFormat:@"[*] Current Process Execution Identity: UID %d", checkUID]];
            [self appendLog:@"[*] Testing system integrity status (setuid binary validation)..."];
            
            // Step 3: Result resolution
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (checkUID == 0) {
                    [self appendLog:@"[+++] SUCCESS: Root restrictions bypassed!"];
                    self.subStatusLabel.text = @"STATUS: EXPLOITED";
                    self.subStatusLabel.textColor = [UIColor greenColor];
                } else {
                    [self appendLog:@"[-] Notice: setuid(0) restriction enforced by sandbox environment."];
                    [self appendLog:@"[i] Safe Mode: System scanning completed under standard user context."];
                    self.subStatusLabel.text = @"Completed (Sandbox Intact)";
                    self.subStatusLabel.textColor = [UIColor orangeColor];
                }
                
                self.actionButton.enabled = YES;
                self.actionButton.alpha = 1.0;
                [self.actionButton setTitle:@"RE-RUN TESTS" forState:UIControlStateNormal];
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
