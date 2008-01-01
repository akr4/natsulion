#import "WelcomeWindowController.h"
#import "Account.h"

@implementation WelcomeWindowController

- (void) setWelcomeWindowControllerCallback:(NSObject<WelcomeWindowCallback>*)callback {
    _callback = callback;
    [_callback retain];
}

- (void) dealloc {
    [_callback release];
    [super dealloc];
}

- (void) resetTwitterCheck {
    if (_twitterCheck) {
        [_twitterCheck release];
        _twitterCheck = nil;
    }
}

- (IBAction) checkAuth:(id)sender {
    [messageArea setStringValue:@""];
    [nextButton setEnabled:FALSE];
    [checkAuthProgressIndicator startAnimation:self];
    
    [self resetTwitterCheck];
    _twitterCheck = [[TwitterCheck alloc] init];
    [_twitterCheck checkAuthentication:[userIdField stringValue]
                              password:[passwordField stringValue]
                              callback:self];
}

- (IBAction) exitApplication:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void) finishedToCheck:(int)result {
    
    [self resetTwitterCheck];
    [checkAuthProgressIndicator stopAnimation:self];
    [nextButton setEnabled:TRUE];
    
    switch (result) {
        case NTLN_TWITTERCHECK_SUCESS:
            if ([[Account newInstanceWithUsername:[userIdField stringValue]] addOrUpdateKeyChainWithPassword:[passwordField stringValue]]) {
                [_callback finishedToSetup];
            } else {
                [messageArea setStringValue:@"Error occurred. Unable to store your password to your keychain."];
            }
            break;
            case NTLN_TWITTERCHECK_AUTH_FAILURE:
            case NTLN_TWITTERCHECK_FAILURE:
            // TODO internationalization
            [messageArea setStringValue:@"Error occurred. Please check your username and password or try later."];
            break;
            default:
            break;
    }
}

@end
