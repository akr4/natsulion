#import "TwitterStatusViewNameField.h"
#import "NTLNColors.h"
#import "TwitterUtils.h"
#import "NTLNUIUtils.h"

@implementation TwitterStatusViewNameField

- (void) setStatus:(NTLNMessage*)status {
    _status = status;
    [status retain];
    
    if ([[status screenName] isEqualToString:[status name]]) {
        [self setStringValue:[status screenName]];
    } else {
        [self setStringValue:[[[status screenName] stringByAppendingString:@"/"] stringByAppendingString:[status name]]];
    }
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] userPageURLString:[_status screenName]]]];
    [super mouseDown:theEvent];
}

@end
