#import "TwitterStatusViewNameField.h"
#import "NTLNColors.h"
#import "TwitterUtils.h"

@implementation TwitterStatusViewNameField

- (void) awakeFromNib {
    [super awakeFromNib];
    
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
}

- (void) setStatus:(TwitterStatus*)status {
    _status = status;
    [status retain];
    
    [self setStringValue:[[[status name] stringByAppendingString:@"/"] stringByAppendingString:[status screenName]]];
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedLink]];
    } else {
        [self setTextColor:[NTLNColors colorForLink]];
    }
    [[NSCursor pointingHandCursor] push];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedText]];
    } else {
        [self setTextColor:[self defaultColor]];
    }
    [NSCursor pop];
}

- (void) mouseDown:(NSEvent *)theEvent {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] userPageURLString:[_status screenName]]]];
    [[self superview] mouseDown:theEvent];
}

@end
