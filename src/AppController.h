#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "PreferencesWindow.h"

@interface AppController : NSObject {
    IBOutlet MainWindowController *mainWindowController;
    IBOutlet PreferencesWindow *preferencesWindowController;
    
    int _refreshInterval;
    NSTimer *_refreshTimer;
    
}

- (IBAction) showPreferencesSheet:(id)sender;
- (IBAction) closePreferencesSheet:(id)sender;

- (int) refreshInterval;
- (void) setRefreshInterval:(int)interval;

@end
