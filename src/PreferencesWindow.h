#import <Cocoa/Cocoa.h>

#define PREFERENCE_USERID @"userId"
#define PREFERENCE_PASSWORD @"password"
#define PREFERENCE_USE_GROWL @"useGrowl"
#define PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE @"showWindowWhenNewMessage"
#define PREFERENCE_REFRESH_INTERVAL @"refreshInterval"

@interface PreferencesWindow : NSWindowController {
 
    IBOutlet NSTextField *refreshIntervalTextField;
    IBOutlet NSStepper *refreshIntervalStepper;

}

@end
