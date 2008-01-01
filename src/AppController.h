#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"

@interface AppController : NSObject {
    IBOutlet MainWindowController *mainWindowController;
    
    int _refreshInterval;
    NSTimer *_refreshTimer;
    
}

- (int) refreshInterval;
- (void) setRefreshInterval:(int)interval;
@end
