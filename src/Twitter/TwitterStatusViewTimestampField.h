#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "NTLNMessageViewTimestampField.h"

@interface TwitterStatusViewTimestampField : NTLNMessageViewTimestampField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

@end
