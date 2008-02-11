#import <Cocoa/Cocoa.h>
#import "NTLNMainWindowController.h"
#import "NTLNWelcomeWindowController.h"

@class NTLNPreferencesWindowController;

@interface NTLNAppController : NSObject<NTLNWelcomeWindowCallback> {
    IBOutlet NTLNMainWindowController *mainWindowController;
    IBOutlet NTLNPreferencesWindowController *preferencesWindowController;
    IBOutlet NTLNWelcomeWindowController *welcomeWindowController;

    int _refreshInterval;
    NSTimer *_refreshTimer;
    
}

- (IBAction) showPreferencesSheet:(id)sender;
- (IBAction) closePreferencesSheet:(id)sender;

- (int) refreshInterval;
- (void) setRefreshInterval:(int)interval;
- (void) startTimer;
- (void) stopTimer;

@end
