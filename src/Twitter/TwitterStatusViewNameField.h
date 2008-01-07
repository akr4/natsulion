#import <Cocoa/Cocoa.h>
#import "MessageViewClickableTextField.h"
#import "TwitterStatus.h"

@interface TwitterStatusViewNameField : MessageViewClickableTextField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

@end
