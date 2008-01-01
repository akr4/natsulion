#import "AppController.h"
#import "PreferencesWindow.h"

@implementation AppController

- (void) dealloc {
    [_refreshTimer release];
    [super dealloc];
}

- (int) refreshInterval {
    return _refreshInterval;
}

- (void) setRefreshInterval:(int)interval {
    _refreshInterval = interval;
    
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        [_refreshTimer release];
    }

    NSLog(@"_refreshInterval: %d", _refreshInterval);
    if (_refreshInterval >= 1) {
        _refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval * 60
                                                          target:mainWindowController
                                                        selector:@selector(updateStatus)
                                                        userInfo:nil 
                                                         repeats:YES] retain];
    }
}

- (void) awakeFromNib {
}

- (IBAction) showPreferencesSheet:(id)sender {
    [[NSApplication sharedApplication] beginSheet:[preferencesWindowController window]
                                   modalForWindow:[mainWindowController window]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                                      contextInfo:nil];
}

- (IBAction) closePreferencesSheet:(id)sender {
    [[NSApplication sharedApplication] endSheet:[preferencesWindowController window] returnCode:0];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    [[preferencesWindowController window] orderOut:self];
}

// NSApplicatoin delegate /////////////////////////////////////////////////////////////////
- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [mainWindowController showWindowToFront];
    return TRUE;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"%s", __PRETTY_FUNCTION__);    
    
    [mainWindowController setFrameAutosaveName:@"MainWindow"];
    
    [self bind:@"refreshInterval"
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.refreshInterval"
       options:nil];
    
    [mainWindowController showWindow:nil];
    [_refreshTimer fire];
}


@end
