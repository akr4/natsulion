#import <Cocoa/Cocoa.h>
#import "TwitterStatusViewTextField.h"

@interface TwitterStatusViewMessageField : TwitterStatusViewTextField {
    float _defaultHeight;
}

- (void) setMessage:(NSString*)message;
- (float) expandIfNeeded;

@end
