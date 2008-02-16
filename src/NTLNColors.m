#import "NTLNColors.h"
#import "NTLNConfiguration.h"

static NTLNColors *_instance;

@implementation NTLNColors

+ (id) instance {
    if (!_instance) {
        _instance = [[[self class] alloc] init];
    }
    return _instance;
}

- (void) releaseColors {
    [_colorForReply release];
    [_colorForHighlightedReply release];
    [_colorForProbableReply release];
    [_colorForHighlightedProbableReply release];
    [_colorForLink release];
    [_colorForHighlightedLink release];
    [_colorForText release];
    [_colorForHighlightedText release];
    [_colorForSubText release];
    [_colorForSubText2 release];
    [_colorForHighlightedBackground release];
    [_colorForBackground release];
    [_controlAlternatingRowBackgroundColors release];
}

- (void) setupLightColors {
    [self releaseColors];
    
    float alpha = [[NTLNConfiguration instance] windowAlpha];
    _colorForText = [[NSColor blackColor] retain];
    _colorForHighlightedText = [[NSColor whiteColor] retain];
    _colorForSubText = [[[NSColor blackColor] highlightWithLevel:0.3] retain];
    _colorForSubText2 = [[[NSColor blackColor] highlightWithLevel:0.5] retain];
    _colorForLink = [[NSColor colorWithDeviceRed:0.333 green:0.616 blue:0.902 alpha:1.0] retain];
    _colorForHighlightedLink = [[NSColor colorWithDeviceRed:0.749 green:0.949 blue:1 alpha:1.0] retain];

    _colorForReply = [[NSColor colorWithDeviceHue:0 saturation:0.3 brightness:1 alpha:alpha] retain];
    _colorForHighlightedReply = [[NSColor colorWithDeviceHue:0 saturation:0.55 brightness:1.0 alpha:alpha] retain];
    _colorForProbableReply = [[NSColor colorWithDeviceHue:0.1167 saturation:0.3 brightness:1.0 alpha:alpha] retain];
    _colorForHighlightedProbableReply = [[NSColor colorWithDeviceHue:0.1167 saturation:0.55 brightness:1.0 alpha:alpha] retain];
    _colorForBackground = [[[NSColor whiteColor] colorWithAlphaComponent:alpha] retain];
    _colorForHighlightedBackground = [[[NSColor alternateSelectedControlColor] colorWithAlphaComponent:alpha] retain];
    _colorForWarning = [[NSColor colorWithDeviceHue:0 saturation:0.10 brightness:1 alpha:1] retain];
    _colorForError = [[NSColor colorWithDeviceHue:0 saturation:0.22 brightness:1 alpha:1] retain];
    
    NSMutableArray *alternatingColors = [[[NSMutableArray alloc] initWithCapacity:2] retain];
    for (NSColor *c in [NSColor controlAlternatingRowBackgroundColors]) {
        [alternatingColors addObject:[c colorWithAlphaComponent:alpha]];
    }
    _controlAlternatingRowBackgroundColors = alternatingColors;
}

- (void) setupDarkColors {
    [self releaseColors];

    float alpha = [[NTLNConfiguration instance] windowAlpha];
    _colorForText = [[NSColor whiteColor] retain];
    _colorForHighlightedText = [[NSColor blackColor] retain];
    _colorForSubText = [[[NSColor whiteColor] shadowWithLevel:0.3] retain];
    _colorForSubText2 = [[[NSColor whiteColor] shadowWithLevel:0.5] retain];
    _colorForLink = [[NSColor colorWithDeviceHue:0.583 saturation:0.61 brightness:0.87 alpha:1.0] retain];
    _colorForHighlightedLink = [[NSColor colorWithDeviceHue:0.583 saturation:0.8 brightness:0.4 alpha:1.0] retain];

    _colorForReply = [[NSColor colorWithDeviceHue:0 saturation:0.55 brightness:0.5 alpha:alpha] retain];
    _colorForHighlightedReply = [[_colorForReply highlightWithLevel:0.4] retain];
    _colorForProbableReply = [[NSColor colorWithDeviceHue:0.1167 saturation:0.55 brightness:0.5 alpha:alpha] retain];
    _colorForHighlightedProbableReply = [[_colorForProbableReply highlightWithLevel:0.5] retain];
    _colorForBackground = [[[NSColor blackColor] colorWithAlphaComponent:alpha] retain];
    _colorForHighlightedBackground = [[_colorForBackground highlightWithLevel:0.5] retain];
    _colorForWarning = [[NSColor colorWithDeviceHue:0 saturation:0.10 brightness:1 alpha:1] retain];
    _colorForError = [[NSColor colorWithDeviceHue:0 saturation:0.22 brightness:1 alpha:1] retain];
    
    _controlAlternatingRowBackgroundColors = [[[NSArray alloc] initWithObjects:
                                              [[NSColor blackColor] colorWithAlphaComponent:alpha],
                                              [[[NSColor blackColor] highlightWithLevel:0.05] colorWithAlphaComponent:alpha],
                                              nil] retain];
    
}

- (void) setupColors {
    if ([[NTLNConfiguration instance] colorScheme] == NTLN_CONFIGURATION_COLOR_SCHEME_LIGHT) {
        [self setupLightColors];
    } else {
        [self setupDarkColors];
    }
}

- (id) init {
    [self setupColors];
    return self;
}

- (void) dealloc {
    [self releaseColors];
    [super dealloc];
}

- (void) notifyConfigurationChange {
    [self setupColors];
}

- (NSColor*) colorForReply {
    return _colorForReply;
}

- (NSColor*) colorForHighlightedReply {
    return _colorForHighlightedReply;
}

- (NSColor*) colorForProbableReply {
    return _colorForProbableReply;
}

- (NSColor*) colorForHighlightedProbableReply {
    return _colorForHighlightedProbableReply;
}

- (NSColor*) colorForLink {
    return _colorForLink;
}

- (NSColor*) colorForHighlightedLink {
    return _colorForHighlightedLink;
}

- (NSColor*) colorForText {
    return _colorForText;
}

- (NSColor*) colorForHighlightedText {
    return _colorForHighlightedText;
}

- (NSColor*) colorForSubText {
    return _colorForSubText;
}

- (NSColor*) colorForSubText2 {
    return _colorForSubText2;
}

- (NSColor*) colorForHighlightedBackground {
    return _colorForHighlightedBackground;
}

- (NSColor*) colorForBackground {
    return _colorForBackground;
}

- (NSColor*) colorForWarning {
    return _colorForWarning;
}

- (NSColor*) colorForError {
    return _colorForError;
}
     
- (NSArray*) controlAlternatingRowBackgroundColors {
    return _controlAlternatingRowBackgroundColors;
}

@end
