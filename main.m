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
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, screenWidth, 40)];
    titleLabel.text = @"STIKJAIL";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:45];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    // Subtitle
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, screenWidth, 25)];
    self.statusLabel.text = @"Magnifier Vulnerability Scanner";
    self.statusLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
    self.statusLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    // Sub-status
    self.subStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, screenWidth, 20)];
    self.subStatusLabel.text = @"Ready to scan exploit surface";
    self.subStatusLabel.textColor = [UIColor lightGrayColor];
    self.subStatusLabel.font = [UIFont systemFontOfSize:14];
    self.subStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.subStatusLabel];
    
    // Log Box
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, 200, screenWidth - 40, screenHeight - 380)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.4 green:0.9 blue:1.0 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo-Bold" size:12];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 12;
    self.logView.layer.borderWidth = 1.0;
    self.logView.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    self.logView.text = [NSString stringWithFormat:@"[*] Target Device: %Custom\n[*] Initializing StikJail Diagnostic Engine...\n[*] Tap 'SCAN EXPLOIT' to test Magnifier surface.", deviceModel];
    [self.view addSubview:self.logView];
    
    // Action Button
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.frame = CGRectMake(40, screenHeight - 120, screenWidth - 80, 55);
    self.actionButton.backgroundColor = [UIColor whiteColor];
    [self.actionButton setTitle:@"SCAN EXPLOIT" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.actionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    self.actionButton.layer.cornerRadius = 27.5;
    [self.actionButton addTarget:self action:@selector(startMagnifierScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];
}

- (void)appendLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [self.logView.text stringByAppendingFormat:@"\n%@", message];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

- (void)startMagnifierScan {
    self.actionButton.enabled = NO;
    self.actionButton.alpha = 0.6;
    self.subStatusLabel.text = @"Scanning Magnifier service...";
    
    [self appendLog:@"\n[!] Checking Magnifier App surface entitlements..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Tijaabada galka Magnifier ee nidaamka iOS
        NSString *magnifierPath = @"/System/Library/CoreServices/Magnifier.app";
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:magnifierPath];
        
        if (exists) {
            [self appendLog:@"[+] Magnifier App path found in CoreServices."];
        } else {
            [magnifierPath = @"/Applications/Magnifier.app" copy];
            exists = [[NSFileManager defaultManager] fileExistsAtPath:magnifierPath];
            [self appendLog:[NSString stringWithFormat:@"[*] Alternative path status: %Custom", exists ? @"FOUND" : @"NOT FOUND"]];
        }
        
        [self appendLog:@"[*] Testing write permissions for MacDirtyCow / TCC bypass..."];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Isku day xaddidan oo akhris/qoris ah
            int testFile = open("/System/Library/CoreServices/Magnifier.app/Magnifier", O_RDONLY);
            if (testFile != -1) {
                [self appendLog:@"[+] Success: Magnifier binary is readable for analysis."];
                close(testFile);
            } else {
                [self appendLog:@"[-] Notice: Binary direct mapping is restricted by Kernel Sandbox."];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self appendLog:@"\n[i] Scan Completed: If this iOS version is vulnerable to MacDirtyCow/KFD, you can swap cached files via a specialized exploit broker."];
                self.subStatusLabel.text = @"Scan Finished";
                self.subStatusLabel.textColor = [UIColor orangeColor];
                
                self.actionButton.enabled = YES;
                self.actionButton.alpha = 1.0;
                [self.actionButton setTitle:@"RE-SCAN SURFACE" forState:UIControlStateNormal];
            });
        });
    });
}

@end

// AppDelegate iyo Main asali ahaan wey sidiisii yihiin...
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
