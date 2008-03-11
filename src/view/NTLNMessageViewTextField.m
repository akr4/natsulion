#import "NTLNMessageViewTextField.h"
#import "NTLNColors.h"
#import "NTLNNotification.h"
#import "NTLNConfiguration.h"

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

- (void) colorSchemeChanged {
    [self setupColors];
    [self setNeedsDisplay:TRUE];
}

- (void) fontSizeChanged {
    float size = [[NTLNConfiguration instance] fontSize];
    if (size > [NSFont systemFontSize]) {
        size = [NSFont systemFontSize];
    }
    [self setFont:[NSFont userFontOfSize:size]];
}

@end
