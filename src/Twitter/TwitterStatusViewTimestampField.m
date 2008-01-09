#import "TwitterStatusViewTimestampField.h"
#import "TwitterUtils.h"

@implementation TwitterStatusViewTimestampField

- (void) setStatus:(TwitterStatus*)status {
    _status = status;
    [status retain];
    
    [self setTimestamp:[_status timestamp]];
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if (![self mouseIsOnText]) {
        [super mouseDown:theEvent];
        return;
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] statusPageURLString:[_status screenName] statusId:[_status statusId]]]];
//    [[self superview] mouseDown:theEvent];
    [super mouseDown:theEvent];
}

@end
