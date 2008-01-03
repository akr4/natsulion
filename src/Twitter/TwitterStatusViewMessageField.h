#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"

@interface TwitterStatusViewMessageField :  MessageViewTextField {
    float _defaultHeight;
}

- (void) setMessage:(NSString*)message;
- (float) expandIfNeeded;

@end
