#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"

#define NTLN_PREFRENCESWINDOW_SHEET_OK 0
#define NTLN_PREFRENCESWINDOW_SHEET_NG 1

@implementation NTLNPreferencesWindowController

- (void) awakeFromNib {
    
}


- (void) resetTwitterCheck {
    if (_twitterCheck) {
        [_twitterCheck release];
        _twitterCheck = nil;
    }
}

- (IBAction)showSheet:(id)sender {
    [[NSApplication sharedApplication] beginSheet:accountInfoSheet
                                   modalForWindow:[self window]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                                      contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    [accountInfoSheet orderOut:self];
}

- (IBAction)sheetOk:(id)sender {
    [messageArea setStringValue:@""];
    [nextButton setEnabled:FALSE];
    [checkAuthProgressIndicator startAnimation:self];
                
    [self resetTwitterCheck];
    _twitterCheck = [[TwitterCheck alloc] init];
    [_twitterCheck checkAuthentication:[userIdField stringValue]
                              password:[passwordField stringValue]
                              callback:self];
}

- (IBAction) sheetCancel:(id)sender {
    [self resetTwitterCheck];
    [checkAuthProgressIndicator stopAnimation:self];
    [[NSApplication sharedApplication] endSheet:accountInfoSheet returnCode:NTLN_PREFRENCESWINDOW_SHEET_NG];
}

- (void) finishedToCheck:(int)result {

    [self resetTwitterCheck];
    [checkAuthProgressIndicator stopAnimation:self];
    [nextButton setEnabled:TRUE];

    switch (result) {
        case NTLN_TWITTERCHECK_SUCESS:
            if ([[NTLNAccount newInstanceWithUsername:[userIdField stringValue]] addOrUpdateKeyChainWithPassword:[passwordField stringValue]]) {
                [[NSApplication sharedApplication] endSheet:accountInfoSheet returnCode:NTLN_PREFRENCESWINDOW_SHEET_OK];
                [appController startTimer];
            } else {
                [messageArea setStringValue:NSLocalizedString(@"Unable to store your password to your keychain.", @"account setting")];
            }
            break;
        case NTLN_TWITTERCHECK_AUTH_FAILURE:
        case NTLN_TWITTERCHECK_FAILURE:
            // TODO internationalization
            [messageArea setStringValue:NSLocalizedString(@"Please check your username and password or try later.", @"account setting")];
            break;
        default:
            break;
    }
    
    
}


@end
