#import <Cocoa/Cocoa.h>
#import "MessageTableViewController.h"
#import "Twitter.h"
#import "GrowlNotifier.h"
#import "MessageInputTextField.h"
#import "Configuration.h"

@protocol TimelineSortOrderChangeObserver
- (void) timelineSortOrderChangeObserverSortOrderChanged;
@end

@interface MainWindowController : NSWindowController <TimelineSortOrderChangeObserver, TimelineCallback, TwitterPostCallback, MessageInputTextFieldCallback> {
    IBOutlet NSWindow *mainWindow;
    IBOutlet MessageTableViewController *messageTableViewController;
    IBOutlet NSProgressIndicator *downloadProgress;
    IBOutlet MessageInputTextField *messageTextField;
    IBOutlet NSTextField *statusTextField;
    IBOutlet Configuration *configuration;
    IBOutlet NSArrayController *messageViewControllerArrayController;
    
    Twitter *_twitter;
    GrowlNotifier *_growl;
    
    // TODO: is it better AppController has this instance instead of MainWindowController?
    // timing after launched
    NSTimer *_afterLaunchedTimer;
    BOOL _growlEnabled;
}

- (IBAction) sendMessage:(id) sender;

- (void) showWindowToFront;
- (void) setFrameAutosaveName:(NSString*)name;
- (NSArray*) timelineSortDescriptors;

@end
