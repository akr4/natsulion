#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewClickableTextField.h"

@interface NTLNMessageViewTimestampField : NTLNMessageViewClickableTextField {
    NSDate *_timestamp;
}
- (void) setTimestamp:(NSDate*)timestamp;
- (NSDate*) timestamp;
@end
