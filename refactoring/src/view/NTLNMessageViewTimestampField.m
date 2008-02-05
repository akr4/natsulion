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
    
    [self setStringValue:[_timestamp descriptionWithCalendarFormat:@"%02H:%02M:%02S"
                                                         timeZone:[NSTimeZone localTimeZone]
                                                           locale:[[NSUserDefaults standardUserDefaults]
                                                                   dictionaryRepresentation]]];
    
}

@end
