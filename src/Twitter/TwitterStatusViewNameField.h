#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewClickableTextField.h"
#import "NTLNMessage.h"

@interface TwitterStatusViewNameField : NTLNMessageViewClickableTextField {
    NTLNMessage *_status;
}

- (void) setStatus:(NTLNMessage*)status;

@end
