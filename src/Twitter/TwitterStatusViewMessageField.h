#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"
#import "Configuration.h"

@interface TwitterStatusViewMessageField :  MessageViewTextField {
    IBOutlet Configuration *configuration;

    float _defaultHeight;
    float _defaultY;
}

- (void) setMessage:(NSString*)message;
- (float) expandIfNeeded;

@end
