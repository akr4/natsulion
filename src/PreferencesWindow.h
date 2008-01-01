#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "Twitter.h"

#define PREFERENCE_USERID @"userId"
#define PREFERENCE_USE_GROWL @"useGrowl"
#define PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE @"showWindowWhenNewMessage"
#define PREFERENCE_REFRESH_INTERVAL @"refreshInterval"

@interface PreferencesWindow : NSWindowController<TwitterCheckCallback> {
    IBOutlet NSPanel *accountInfoSheet;
    IBOutlet NSProgressIndicator *checkAuthProgressIndicator;
    IBOutlet NSTextField *messageArea;
    IBOutlet NSTextField *userIdField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSButton *nextButton;
    IBOutlet AppController *appController;
    
    TwitterCheck *_twitterCheck;
}

- (IBAction) showSheet:(id)sender;
- (void) sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
- (IBAction) sheetOk:(id)sender;
- (IBAction) sheetCancel:(id)sender;

@end
