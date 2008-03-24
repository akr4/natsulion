#import <Cocoa/Cocoa.h>
#import "NTLNAppController.h"
#import "NTLNMainWindowController.h"
#import "Twitter.h"

#define NTLN_PREFERENCE_USERID @"userId"
#define NTLN_PREFERENCE_USE_GROWL @"useGrowl"
#define NTLN_PREFERENCE_REFRESH_INTERVAL @"refreshInterval"

enum NTLNAccountConfigState {
    NTLN_ACCOUNT_CONFIG_USERNAME,
    NTLN_ACCOUNT_CONFIG_PASSWORD,
};

@interface NTLNPreferencesWindowController : NSWindowController<TwitterCheckCallback> {

    IBOutlet NTLNAppController *appController;

#pragma mark Account sheet    
    IBOutlet NSTextField *messageArea;
    IBOutlet NSPanel *accountInfoSheet;
    IBOutlet NSProgressIndicator *checkAuthProgressIndicator;
    IBOutlet NSTextField *userIdField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *backButton;
    IBOutlet NSTextField *passwordLabel;
    TwitterCheck *_twitterCheck;
    enum NTLNAccountConfigState _accountConfigState;
}

- (IBAction) showSheet:(id)sender;
- (void) sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
- (IBAction) sheetOk:(id)sender;
- (IBAction) sheetCancel:(id)sender;

@end
