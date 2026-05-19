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
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 50)];
    titleLabel.text = @"StikJail v1.1";
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    // Log View
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, 150, self.view.bounds.size.width - 40, 300)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.logView.textColor = [UIColor greenColor];
    self.logView.font = [UIFont fontWithName:@"Courier" size:14];
    self.logView.editable = NO;
    self.logView.layer.cornerRadius = 10;
    self.logView.text = @"[+] System Ready...\n[+] Device: iOS SE (Detected)\n[+] UID: 501 (Sandbox)";
    [self.view addSubview:self.logView];
    
    // Inject Button
    self.injectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.injectButton.frame = CGRectMake(self.view.bounds.size.width/2 - 100, 500, 200, 50);
    self.injectButton.backgroundColor = [UIColor greenColor];
    [self.injectButton setTitle:@"START INJECTION" forState:UIControlStateNormal];
    [self.injectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.injectButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.injectButton.layer.cornerRadius = 25;
    [self.injectButton addTarget:self action:@selector(startInjection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.injectButton];
    
    // Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.center = CGPointMake(self.view.bounds.size.width/2, 580);
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addLog:@"[*] Isku-dayga Sandbox Escape..."];
        
        // Isku day in la taabto faylasha nidaamka (Simulated exploit)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self addLog:@"[*] Helidda Kernel offsets..."];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self addLog:@"[*] Injecting root payload..."];
                
                // Baaritaan dhab ah oo UID ah
                uid_t current_uid = getuid();
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating];
                    if (current_uid == 0) {
                        [self addLog:@"[+++] SUCCESS: ROOT ACCESS GRANTED!"];
                        self.view.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0 alpha:1];
                    } else {
                        [self addLog:@"[-] FAILED: Sandbox waa mid adag."];
                        [self addLog:@"[!] Talo: SideStore ma bixiyo Root access."];
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
