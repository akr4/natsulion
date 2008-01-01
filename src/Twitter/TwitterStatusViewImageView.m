#import "TwitterStatusViewImageView.h"
#import "TwitterUtils.h"

@implementation TwitterStatusViewImageView

- (void) awakeFromNib {
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options: (NSTrackingCursorUpdate | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
}

- (void) mouseDown:(NSEvent *)theEvent {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[TwitterUtils utils] userPageURLString:[_status screenName]]]];
    [[self superview] mouseDown:theEvent];
}

-(void)cursorUpdate:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
}

- (void) highlight {
}

- (void) unhighlight {
}

- (void) setStatus:(TwitterStatus*)status {
    _status = status;
    [_status retain];
    [self setImage:[_status icon]];
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}



@end
