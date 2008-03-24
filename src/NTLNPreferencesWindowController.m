#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"

#define NTLN_PREFRENCESWINDOW_SHEET_OK 0
#define NTLN_PREFRENCESWINDOW_SHEET_NG 1

@implementation NTLNPreferencesWindowController

- (void) setAccountSheetUsernameState {
    _accountConfigState = NTLN_ACCOUNT_CONFIG_USERNAME;
    [nextButton setTitle:NSLocalizedString(@"Next", nil)];
    [passwordLabel setHidden:TRUE];
    [passwordField setEnabled:FALSE];
}

- (void) setAccountSheetPasswordState {
    _accountConfigState = NTLN_ACCOUNT_CONFIG_PASSWORD;
    [nextButton setTitle:NSLocalizedString(@"Apply", nil)];
    [passwordLabel setHidden:FALSE];
    [passwordField setEnabled:TRUE];
}

- (void) awakeFromNib {
    [self setAccountSheetUsernameState];
}

- (void) resetTwitterCheck {
    if (_twitterCheck) {
        [_twitterCheck release];
        _twitterCheck = nil;
    }
}

- (void) checkWithTwitterUsername:(NSString*)username password:(NSString*)password {
    [nextButton setEnabled:FALSE];
    [checkAuthProgressIndicator startAnimation:self];
    [self resetTwitterCheck];
    _twitterCheck = [[TwitterCheck alloc] init];
    [_twitterCheck checkAuthentication:username
                              password:password
                              callback:self];
//    NSLog(@"%@/%@", username, password);
}

- (IBAction)showSheet:(id)sender {
    [[NSApplication sharedApplication] beginSheet:accountInfoSheet
                                   modalForWindow:[self window]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                                      contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    [self setAccountSheetUsernameState];
    [messageArea setStringValue:@""];
    [userIdField setStringValue:@""];
    [passwordField setStringValue:@""];
    [accountInfoSheet orderOut:self];
}

- (IBAction)sheetOk:(id)sender {
    [messageArea setStringValue:@""];
    
    if (_accountConfigState == NTLN_ACCOUNT_CONFIG_USERNAME) {
        NSString *password = [[NTLNAccount newInstanceWithUsername:[userIdField stringValue]] password];
        if (password && [password length] > 0) {
            [self checkWithTwitterUsername:[userIdField stringValue] password:password];
        } else {
            [self setAccountSheetPasswordState];
        }
    } else {
        [self checkWithTwitterUsername:[userIdField stringValue] password:[passwordField stringValue]];
    }
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
            if (_accountConfigState == NTLN_ACCOUNT_CONFIG_PASSWORD) {
                if (![[NTLNAccount newInstanceWithUsername:[userIdField stringValue]] addOrUpdateKeyChainWithPassword:[passwordField stringValue]]) {
                    [messageArea setStringValue:NSLocalizedString(@"Unable to store your password to your keychain.", @"account setting")];
                    break;
                }
            }
            [[NSApplication sharedApplication] endSheet:accountInfoSheet returnCode:NTLN_PREFRENCESWINDOW_SHEET_OK];
            [appController startTimer];
            break;
        case NTLN_TWITTERCHECK_AUTH_FAILURE:
        case NTLN_TWITTERCHECK_FAILURE:
            [self setAccountSheetPasswordState];
            [messageArea setStringValue:NSLocalizedString(@"Please check your username and password or try later.", @"account setting")];
            break;
        default:
            break;
    }
}


@end
