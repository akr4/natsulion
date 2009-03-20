#import "NTLNMessageViewTimestampField.h"


@implementation NTLNMessageViewTimestampField

- (id) init {
    return self;
}

- (void) dealloc {
    [_timestamp release];
    [super dealloc];
}

- (NSDate*) timestamp {
    return _timestamp;
}

- (void) setTimestamp:(NSDate*)timestamp {
    _timestamp = timestamp;
    [_timestamp retain];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [self setStringValue:[formatter stringFromDate:_timestamp]];
}

@end
