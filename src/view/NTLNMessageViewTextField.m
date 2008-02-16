#import "NTLNMessageViewTextField.h"
#import "NTLNColors.h"

@implementation NTLNMessageViewTextField

- (void) setupColors {
    [_defaultColor release];
    _defaultColor = [[[NTLNColors instance] colorForSubText] retain];
    [self setTextColor:_defaultColor];
}

- (void) awakeFromNib {
    _highlighted = FALSE;
    [self setupColors];
}

- (void) dealloc {
    [_defaultColor release];
    [super dealloc];
}

- (void) notifyColorChange {
    if (_highlighted) {
        [self highlight];
    } else {
        [self unhighlight];
    }
    [self setupColors];
    [self setNeedsDisplay:TRUE];
}

- (void) highlight {
    [self setTextColor:[[NTLNColors instance] colorForHighlightedText]];
    _highlighted = TRUE;
}

- (void) unhighlight {
    [self setTextColor:[[NTLNColors instance] colorForSubText]];
    _highlighted = FALSE;
}

- (NSColor*) defaultColor {
    return _defaultColor;
}

- (BOOL) highlighted {
    return _highlighted;
}

@end
