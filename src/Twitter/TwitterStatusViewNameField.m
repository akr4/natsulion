#import "TwitterStatusViewNameField.h"

@implementation TwitterStatusViewNameField

- (void) setStatus:(TwitterStatus*)status {
    _status = status;
    [status retain];
    
    [self setStringValue:[[[status name] stringByAppendingString:@"/"] stringByAppendingString:[status screenName]]];
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}
@end
