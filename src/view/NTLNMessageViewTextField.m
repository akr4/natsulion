#import "NTLNMessageViewTextField.h"
#import "NTLNColors.h"
#import "NTLNNotification.h"

@implementation NTLNMessageViewTextField

- (void) setupColors {
    [_defaultColor release];
    _defaultColor = [[[NTLNColors instance] colorForSubText] retain];
    [self setTextColor:_defaultColor];
}

- (void) awakeFromNib {
    _highlighted = FALSE;
    [self setupColors];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED
                                               object:nil];
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

#pragma mark Notification
- (void) colorSchemeChanged:(NSNotification*)notification {
    [self setupColors];
    [self setNeedsDisplay:TRUE];
}

@end
