#import <Cocoa/Cocoa.h>
#import "Twitter.h"

@protocol WelcomeWindowCallback
- (void) finishedToSetup;
@end

@interface WelcomeWindowController : NSWindowController<TwitterCheckCallback> {

    IBOutlet NSProgressIndicator *checkAuthProgressIndicator;
    IBOutlet NSTextField *messageArea;
    IBOutlet NSTextField *userIdField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSButton *nextButton;
    
    TwitterCheck *_twitterCheck;
    NSObject<WelcomeWindowCallback> *_callback;
}

- (IBAction) checkAuth:(id)sender;
- (IBAction) exitApplication:(id)sender;

- (void) setWelcomeWindowControllerCallback:(NSObject<WelcomeWindowCallback>*)callback;

@end
