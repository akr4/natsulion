#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"

@interface TwitterStatusViewMessageField :  MessageViewTextField {
    float _defaultHeight;
    float _defaultY;
}

- (void) setMessage:(NSString*)message;
- (float) expandIfNeeded;

@end
