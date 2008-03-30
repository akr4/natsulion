#import "TwitterStatusViewImageView.h"
#import "TwitterStatusViewController.h"

@implementation TwitterStatusViewImageView

- (void) addImageTrackingArea {
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options: (NSTrackingMouseEnteredAndExited | NSTrackingCursorUpdate | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
}

- (void) awakeFromNib {
    [self addImageTrackingArea];
}

- (void) mouseDown:(NSEvent *)theEvent {
//    [[self superview] mouseDown:theEvent];
    [_controller iconViewClicked];
}

-(void)cursorUpdate:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];    
}

- (void)mouseEntered:(NSEvent *)theEvent {
}

- (void)mouseExited:(NSEvent *)theEvent {
}

- (void) highlight {
}

- (void) unhighlight {
}

- (void) setStatus:(NTLNMessage*)status {
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

- (void)updateTrackingAreas {
    NSArray *trackingAreas = [self trackingAreas];
    int i;
    for (i = 0; i < [trackingAreas count]; i++) {
        [self removeTrackingArea:[trackingAreas objectAtIndex:i]];
    }
    
    [self addImageTrackingArea];
}

@end
