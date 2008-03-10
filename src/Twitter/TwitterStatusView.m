#import "TwitterStatusView.h"
#import "NTLNColors.h"
#import "TwitterStatusViewController.h"
#import "NTLNConfiguration.h"
#import "NTLNNotification.h"

@implementation TwitterStatusView

- (void) awakeFromNib {
    _defaultHeight = [self frame].size.height;
    _requiredHeight = _defaultHeight;
    _sizeShouldBeCalculated = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED
                                               object:nil];
}

- (void) removeTrackingAreas {
    NSArray *trackingAreas = [self trackingAreas];
    for (NSTrackingArea *area in trackingAreas) {
        [self removeTrackingArea:area];
    }
}

- (void) addTrackingArea {
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
}

- (void) updateTrackingArea {
    [self removeTrackingAreas];
    [self addTrackingArea];
}

- (float) expandTextField {
    float delta = [textField expandIfNeeded];
    if (delta > 0) {
        _requiredHeight = _defaultHeight + delta;
    } else {
        _requiredHeight = _defaultHeight;
    }
    return _requiredHeight;
}

- (void) markNeedCalculateHeight {
    _sizeShouldBeCalculated = TRUE;
}

- (float) requiredHeight {
    if (!_sizeShouldBeCalculated) {
        return _requiredHeight;
    }

    float back;
    _sizeShouldBeCalculated = FALSE;
    back = [self expandTextField];
    NSSize size = [self frame].size;
    size.height = back;
    [self setFrameSize:size];
    [self updateTrackingArea]; 
    return back;
}

- (void) setTwitterStatus:(TwitterStatus*)status {
    _status = status;
    [_status retain];
    [self requiredHeight];
}

- (void) dealloc {
    [_backgroundColor release];
    [_status release];
    [self removeTrackingAreas];
    [super dealloc];
}

- (void) highlight {
    _highlighted = TRUE;
    
    switch ([_status replyType]) {
        case MESSAGE_REPLY_TYPE_DIRECT:
        case MESSAGE_REPLY_TYPE_REPLY:
            [_backgroundColor release];
            _backgroundColor = [[[NTLNColors instance] colorForHighlightedReply] retain];
            break;
        case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
            [_backgroundColor release];
            _backgroundColor = [[[NTLNColors instance] colorForHighlightedProbableReply] retain];
            break;
        case MESSAGE_REPLY_TYPE_NORMAL:
//            [_backgroundColor release];
//            _backgroundColor = [[[NTLNColors instance] colorForHighlightedBackground] retain];
        default:
            _backgroundColor = nil;
            break;
    }
}

- (void) unhighlight {
    _highlighted = FALSE;

    switch ([_status replyType]) {
        case MESSAGE_REPLY_TYPE_DIRECT:
        case MESSAGE_REPLY_TYPE_REPLY:
            [_backgroundColor release];
            _backgroundColor = [[[NTLNColors instance] colorForReply] retain];
            break;
        case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
            [_backgroundColor release];
            _backgroundColor = [[[NTLNColors instance] colorForProbableReply] retain];
            break;
        case MESSAGE_REPLY_TYPE_NORMAL:
//            [_backgroundColor release];
//            _backgroundColor = [[[NTLNColors instance] colorForBackground] retain];
        default:
            _backgroundColor = nil;
            break;
    }
}

- (void)drawRect:(NSRect)aRect {
    if (_backgroundColor) {
        [_backgroundColor set];
        NSRectFillUsingOperation(aRect, NSCompositeCopy);
    }

//    if ([_status status] != NTLN_MESSAGE_STATUS_READ) {
//        [[[NTLNColors instance] colorForText] set];
//        [NSBezierPath setDefaultLineWidth:15.0f];
//        [NSBezierPath strokeLineFromPoint:NSMakePoint([self bounds].origin.x, [self bounds].origin.y)
//                                  toPoint:NSMakePoint([self bounds].origin.x, [self bounds].origin.y + [self bounds].size.height)];
//    }
}

- (void) setViewController:(TwitterStatusViewController*)controller {
    _controller = controller; // weak reference
}

- (void) mouseEnteredTimerExpired:(NSTimer*)timer {
    [_controller showStar:TRUE];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _starTimer = [[NSTimer scheduledTimerWithTimeInterval:0.3
                                                   target:self
                                                selector:@selector(mouseEnteredTimerExpired:)
                                                 userInfo:nil 
                                                  repeats:FALSE] retain];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if ([_starTimer isValid]) {
        [_starTimer invalidate];
    }
    [_starTimer release];
    _starTimer = nil;
    [_controller showStar:FALSE];
}

- (NSColor*) backgroundColor {
    return _backgroundColor;
}

#pragma mark Notification
- (void) colorSchemeChanged:(NSNotification*)notification {
    [self setNeedsDisplay:TRUE];
}

@end
