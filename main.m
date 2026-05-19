#import <UIKit/UIKit.h>
#import <unistd.h>

@interface ViewController : UIViewController
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor greenColor];
    textView.font = [UIFont fontWithName:@"Courier" size:18];
    textView.editable = NO;
    textView.textAlignment = NSTextAlignmentCenter;
    
    uid_t current_uid = getuid();
    NSString *status = (current_uid == 0) ? @"[+++] Success: ROOT!" : @"[-] Warning: Sandbox caadi ah.";
    
    textView.text = [NSString stringWithFormat:@"\n\n\nStikJail v1.0\n\n[+] Aqoonsiga (UID): %d\n\n%@", current_uid, status];
    
    [self.view addSubview:textView];
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
