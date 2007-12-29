#import "PreferencesWindow.h"

@implementation PreferencesWindow

- (void) awakeFromNib {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *v = [defaults stringForKey:PREFERENCE_USERID];
    if (v) {
        [userIdTextField setStringValue:v];
    }

    v = [defaults stringForKey:PREFERENCE_PASSWORD];
    if (v) {
        [passwordTextField setStringValue:v];
    }
    
    if ([defaults boolForKey:PREFERENCE_USE_GROWL]) {
        [useGrowlButton setState:NSOnState];
    } else {
        [useGrowlButton setState:NSOffState];
    }
    
    if ([defaults boolForKey:PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE]) {
        [showWindowWhenNewMessageButton setState:NSOnState];
    } else {
        [showWindowWhenNewMessageButton setState:NSOffState];
    }
}

- (void) updatePreferencesInternal {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[userIdTextField stringValue] forKey:PREFERENCE_USERID];
    [defaults setObject:[passwordTextField stringValue] forKey:PREFERENCE_PASSWORD];
    [defaults setBool:([useGrowlButton state] == NSOnState ? TRUE : FALSE) forKey:PREFERENCE_USE_GROWL];
    [defaults setBool:([showWindowWhenNewMessageButton state] == NSOnState ? TRUE : FALSE) forKey:PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [self updatePreferencesInternal];
}

- (IBAction) changeButtonState:(id)sender {
    [self updatePreferencesInternal];
}
@end
