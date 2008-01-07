#import "TwitterStatusViewImageView.h"
#import "TwitterStatusViewController.h"

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
    [_controller iconViewClicked];
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

- (void) setViewController:(TwitterStatusViewController*)controller {
    _controller = controller; // weak reference
}

- (void) dealloc {
    [_status release];
    [super dealloc];
}

@end
