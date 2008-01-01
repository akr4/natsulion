#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "WelcomeWindowController.h"

@class PreferencesWindow;

@interface AppController : NSObject<WelcomeWindowCallback> {
    IBOutlet MainWindowController *mainWindowController;
    IBOutlet PreferencesWindow *preferencesWindowController;
    IBOutlet WelcomeWindowController *welcomeWindowController;
    
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
