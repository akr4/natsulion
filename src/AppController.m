#import "AppController.h"
#import "PreferencesWindow.h"
#import "Account.h"

@implementation AppController

+ (void) setupDefaults {
    NSString *userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" 
                                                                       ofType:@"plist"]; 
    NSLog(@"UserDefaults path: %@", userDefaultsValuesPath);

    NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath]; 
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict]; 
}

+ (void) initialize {
    NSLog(@"%s", __PRETTY_FUNCTION__); 
    [AppController setupDefaults];
}

- (void) dealloc {
    [_refreshTimer release];
    [super dealloc];
}

- (int) refreshInterval {
    return _refreshInterval;
}

- (void) resetTimer {
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        [_refreshTimer release];
    }
}

- (void) stopTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__); 
    [self resetTimer];
}

- (void) startTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__); 

    [self resetTimer];
    
    if (_refreshInterval < 1) {
        return;
    }

    _refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:_refreshInterval * 60
                                                      target:mainWindowController
                                                    selector:@selector(updateStatus)
                                                    userInfo:nil 
                                                     repeats:YES] retain];
    [_refreshTimer fire];
}

- (void) setRefreshInterval:(int)interval {
    _refreshInterval = interval;
    
    if ([[Account instance] username]) {
        [self startTimer];
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
    
    [welcomeWindowController setWelcomeWindowControllerCallback:self];
    
    
    NSString *username = [[Account instance] username];
    if (!username) {
        NSLog(@"if");
        // first time
        [mainWindowController close];
      	[NSBundle loadNibNamed:@"Welcome" owner:welcomeWindowController];
        [welcomeWindowController showWindow:nil];
    } else {
        NSLog(@"else");
        [mainWindowController showWindow:nil];
        if ([[Account instance] password]) {
            [self startTimer];
        }
    }
}


// WelcomeWindowCallback ///////////////////////////////////////////////////////////////////////
- (void) finishedToSetup {
    [welcomeWindowController close];
    [mainWindowController showWindow:nil];
    [self startTimer];
}

@end
