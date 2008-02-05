#import <Cocoa/Cocoa.h>
#import "Twitter.h"

@protocol NTLNWelcomeWindowCallback
- (void) finishedToSetup;
@end

@interface NTLNWelcomeWindowController : NSWindowController<TwitterCheckCallback> {

    IBOutlet NSProgressIndicator *checkAuthProgressIndicator;
    IBOutlet NSTextField *messageArea;
    IBOutlet NSTextField *userIdField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSButton *nextButton;
    
    TwitterCheck *_twitterCheck;
    NSObject<NTLNWelcomeWindowCallback> *_callback;
}

- (IBAction) checkAuth:(id)sender;
- (IBAction) exitApplication:(id)sender;

- (void) setWelcomeWindowControllerCallback:(NSObject<NTLNWelcomeWindowCallback>*)callback;

@end
