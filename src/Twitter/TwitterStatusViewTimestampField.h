#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"
#import "NTLNMessageViewTimestampField.h"

@interface TwitterStatusViewTimestampField : NTLNMessageViewTimestampField {
    NTLNMessage *_status;
}

- (void) setStatus:(NTLNMessage*)status;

@end
