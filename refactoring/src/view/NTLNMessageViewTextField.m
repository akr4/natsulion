#import "NTLNMessageViewTextField.h"
#import "NTLNColors.h"

@implementation NTLNMessageViewTextField

- (id) init {
    return self;
}

- (void) dealloc {
    [_defaultColor release];
    [super dealloc];
}

- (void) awakeFromNib {
    _defaultColor = [[self textColor] retain];
    _highlighted = FALSE;
}

- (void) highlight {
    [self setTextColor:[NTLNColors colorForHighlightedText]];
    _highlighted = TRUE;
}

- (void) unhighlight {
    [self setTextColor:_defaultColor];
    _highlighted = FALSE;
}

- (NSColor*) defaultColor {
    return _defaultColor;
}

- (BOOL) highlighted {
    return _highlighted;
}

@end
