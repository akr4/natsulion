#import "TwitterStatusView.h"
#import "NTLNColors.h"

@implementation TwitterStatusView

- (void) awakeFromNib {
    _defaultHeight = [self frame].size.height;
    _requiredHeight = _defaultHeight;
}

- (float) requiredHeight {
    return _requiredHeight;
}

- (void) setTwitterStatus:(TwitterStatus*)status {
    _status = status;
    [_status retain];
}

- (NSView *) hitTest:(NSPoint)aPoint {
//    if (_highlighted) {
        return [super hitTest:aPoint];
//    }
//    return self;
}

- (void) dealloc {
    [_backgroundColor release];
    [_status release];
    [super dealloc];
}

- (void) highlight {
    _highlighted = TRUE;
    
    switch ([_status replyType]) {
        case MESSAGE_REPLY_TYPE_DIRECT:
        case MESSAGE_REPLY_TYPE_REPLY:
            _backgroundColor = [NTLNColors colorForHighlightedReply];
            break;
        case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
            _backgroundColor = [NTLNColors colorForHighlightedProbableReply];
            break;
        case MESSAGE_REPLY_TYPE_NORMAL:
        default:
            break;
    }
 
    float delta = [textField expandIfNeeded];
    if (delta > 0) {
//        NSLog(@"delta %f ------------------", delta);
        _requiredHeight = _defaultHeight + delta;
    }
}

- (void) unhighlight {
    _highlighted = FALSE;

    switch ([_status replyType]) {
        case MESSAGE_REPLY_TYPE_DIRECT:
        case MESSAGE_REPLY_TYPE_REPLY:
            _backgroundColor = [NTLNColors colorForReply];
            break;
        case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
            _backgroundColor = [NTLNColors colorForProbableReply];
            break;
        case MESSAGE_REPLY_TYPE_NORMAL:
        default:
            break;
    }

    _requiredHeight = _defaultHeight;
}

- (void)drawRect:(NSRect)aRect {
    if (!_backgroundColor) {
        return;
    }
    [_backgroundColor set];
    NSRectFill(aRect);
}

@end
