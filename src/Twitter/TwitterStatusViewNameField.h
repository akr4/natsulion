#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"
#import "TwitterStatus.h"

@interface TwitterStatusViewNameField : MessageViewTextField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

@end
