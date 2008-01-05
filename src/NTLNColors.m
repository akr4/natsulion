#import "NTLNColors.h"

static NSColor *_colorForReply;
static NSColor *_colorForHighlightedReply;
static NSColor *_colorForProbableReply;
static NSColor *_colorForHighlightedProbableReply;
static NSColor *_colorForLink;
static NSColor *_colorForHighlightedLink;
static NSColor *_colorForHighlightedText;

@implementation NTLNColors

+ (void) initialize {
    _colorForReply = [[NSColor colorWithDeviceHue:0 saturation:0.22 brightness:1 alpha:1] retain];
    _colorForHighlightedReply = [[NSColor colorWithDeviceHue:0 saturation:0.55 brightness:1.0 alpha:1] retain];
    _colorForProbableReply = [[NSColor colorWithDeviceHue:0.0611 saturation:0.22 brightness:1.0 alpha:1] retain];
    _colorForHighlightedProbableReply = [[NSColor colorWithDeviceHue:0.0611 saturation:0.55 brightness:1.0 alpha:1] retain];
    _colorForLink = [[NSColor colorWithDeviceRed:0.333 green:0.616 blue:0.902 alpha:1.0] retain];
    _colorForHighlightedLink = [[NSColor colorWithDeviceRed:0.749 green:0.949 blue:1 alpha:1.0] retain];
    _colorForHighlightedText = [[NSColor whiteColor] retain];
}

+ (NSColor*) colorForReply {
    return _colorForReply;
}

+ (NSColor*) colorForHighlightedReply {
    return _colorForHighlightedReply;
}

+ (NSColor*) colorForProbableReply {
    return _colorForProbableReply;
}

+ (NSColor*) colorForHighlightedProbableReply {
    return _colorForHighlightedProbableReply;
}

+ (NSColor*) colorForLink {
    return _colorForLink;
}

+ (NSColor*) colorForHighlightedLink {
    return _colorForHighlightedLink;
}

+ (NSColor*) colorForHighlightedText {
    return _colorForHighlightedText;
}

@end
