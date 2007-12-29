//
//  PreferencesWindow.h
//  NatsuLion
//
//  Created by 上田 明良 on 07/12/18.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PREFERENCE_USERID @"userId"
#define PREFERENCE_PASSWORD @"password"
#define PREFERENCE_USE_GROWL @"useGrowl"
#define PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE @"showWindowWhenNewMessage"

@interface PreferencesWindow : NSWindowController {
    
    // Account Informations
    IBOutlet NSTextField *userIdTextField;
    IBOutlet NSTextField *passwordTextField;
    
    IBOutlet NSButton *useGrowlButton;
    IBOutlet NSButton *showWindowWhenNewMessageButton;
}
- (IBAction) changeButtonState:(id)sender;
@end
