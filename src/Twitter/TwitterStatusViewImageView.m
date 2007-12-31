#import "TwitterStatusViewImageView.h"


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
    NSMutableString *urlStr = [NSMutableString stringWithCapacity:20];
    [urlStr appendString:@"http://twitter.com/"];
    [urlStr appendString:[_status screenName]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
    [[self superview] mouseDown:theEvent];
}

-(void)cursorUpdate:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
}

- (void) highlight {
}

- (void) lowlight {
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
