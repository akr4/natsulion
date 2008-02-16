#import <Cocoa/Cocoa.h>
#import "NTLNAppController.h"
#import "NTLNMainWindowController.h"
#import "Twitter.h"

#define NTLN_PREFERENCE_USERID @"userId"
#define NTLN_PREFERENCE_USE_GROWL @"useGrowl"
#define NTLN_PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE @"showWindowWhenNewMessage"
#define NTLN_PREFERENCE_REFRESH_INTERVAL @"refreshInterval"

@interface NTLNPreferencesWindowController : NSWindowController<TwitterCheckCallback> {

    IBOutlet NTLNAppController *appController;

#pragma mark Basic Tab
    IBOutlet NSPanel *accountInfoSheet;
    IBOutlet NSProgressIndicator *checkAuthProgressIndicator;
    IBOutlet NSTextField *messageArea;
    IBOutlet NSTextField *userIdField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSButton *nextButton;

    TwitterCheck *_twitterCheck;
}

- (IBAction) showSheet:(id)sender;
- (void) sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
- (IBAction) sheetOk:(id)sender;
- (IBAction) sheetCancel:(id)sender;

@end
