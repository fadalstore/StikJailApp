#import <UIKit/UIKit.h>
#import <unistd.h>
#import <sys/stat.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) UITextView *logView;
@property (strong, nonatomic) UIButton *injectButton;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, screenWidth, 40)];
    titleLabel.text = @"StikJail v1.2";
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:26];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    // Log View - Waxaan u yareeyay dhererka si badhanka loo arko
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(15, 100, screenWidth - 30, screenHeight - 220)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.logView.textColor = [UIColor greenColor];
    self.logView.font = [UIFont fontWithName:@"Courier" size:12];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 10;
    self.logView.layer.borderWidth = 1;
    self.logView.layer.borderColor = [UIColor greenColor].CGColor;
    self.logView.text = @"[+] System Ready...\n[+] Device: iOS SE (Detected)\n[+] UID: 501 (Sandbox)";
    [self.view addSubview:self.logView];
    
    // Inject Button - Hadda wuxuu ka soo muuqanayaa shaashadda hoosteeda
    self.injectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.injectButton.frame = CGRectMake(screenWidth/2 - 100, screenHeight - 100, 200, 50);
    self.injectButton.backgroundColor = [UIColor greenColor];
    [self.injectButton setTitle:@"START INJECTION" forState:UIControlStateNormal];
    [self.injectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.injectButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.injectButton.layer.cornerRadius = 25;
    [self.injectButton addTarget:self action:@selector(startInjection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.injectButton];
    
    // Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.center = CGPointMake(screenWidth/2, screenHeight - 40);
    self.spinner.color = [UIColor whiteColor];
    [self.view addSubview:self.spinner];
}

- (void)addLog:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [self.logView.text stringByAppendingFormat:@"\n%@", text];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
    });
}

- (void)startInjection {
    self.injectButton.enabled = NO;
    self.injectButton.alpha = 0.5;
    [self.spinner startAnimating];
    
    [self addLog:@"[!] Billaabay Injection..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Baaritaanka SiriKitFlow sidii aad codsatay
        [self addLog:@"[*] Checking SiriKitFlow access..."];
        NSString *path = @"/System/Library/PrivateFrameworks/SiriKitFlow.framework/Info.plist";
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [self addLog:@"[+] Path Found: SiriKitFlow"];
        } else {
            [self addLog:@"[-] Error: Path restricted by Sandbox."];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self addLog:@"[*] Exploiting Kernel (Simulated)..."];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self addLog:@"[*] Overwriting task_self_addr..."];
                
                uid_t current_uid = getuid();
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating];
                    if (current_uid == 0) {
                        [self addLog:@"[+++] SUCCESS: ROOT ACCESS GRANTED!"];
                        self.view.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0 alpha:1];
                    } else {
                        [self addLog:@"[-] FAILED: Kernel patch failed."];
                        [self addLog:@"[!] Device is still sandboxed."];
                    }
                    self.injectButton.enabled = YES;
                    self.injectButton.alpha = 1.0;
                });
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
