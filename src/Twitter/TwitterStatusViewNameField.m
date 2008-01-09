#import "TwitterStatusViewNameField.h"
#import "NTLNColors.h"
#import "TwitterUtils.h"
#import "UIUtils.h"

@implementation TwitterStatusViewNameField

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) setStatus:(TwitterStatus*)status {
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
        return;
    }    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] userPageURLString:[_status screenName]]]];
    [[self superview] mouseDown:theEvent];
}

@end
