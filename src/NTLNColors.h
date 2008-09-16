#import <Cocoa/Cocoa.h>

#define NTLN_COLORS_LIGHT_SCHEME_DEFAULT_ALPHA 0.8f
#define NTLN_COLORS_DARK_SCHEME_DEFAULT_ALPHA 0.6f

@interface NTLNColors : NSObject {
    NSColor *_colorForLink;
    NSColor *_colorForHighlightedLink;
    NSColor *_colorForText;
    NSColor *_colorForHighlightedText;
    NSColor *_colorForSubText;
    NSColor *_colorForSubText2;
    
    NSColor *_colorForReply;
    NSColor *_colorForHighlightedReply;
    NSColor *_colorForProbableReply;
    NSColor *_colorForHighlightedProbableReply;
    NSColor *_colorForDirectMessage;
    NSColor *_colorForHighlightedDirectMessage;
    
    NSColor *_colorForHighlightedBackground;
    NSColor *_colorForBackground;
    NSColor *_colorForWarning;
    NSColor *_colorForError;
    NSArray *_controlAlternatingRowBackgroundColors;
}
+ (id) instance;
- (void) notifyConfigurationChange;
#pragma mark Foreground Color
- (NSColor*) colorForLink;
- (NSColor*) colorForHighlightedLink;
- (NSColor*) colorForText;
- (NSColor*) colorForHighlightedText;
- (NSColor*) colorForSubText;
- (NSColor*) colorForSubText2;

#pragma mark Background Color
- (NSColor*) colorForReply;
- (NSColor*) colorForHighlightedReply;
- (NSColor*) colorForProbableReply;
- (NSColor*) colorForHighlightedProbableReply;
- (NSColor*) colorForDirectMessage;
- (NSColor*) colorForHighlightedDirectMessage;
- (NSColor*) colorForHighlightedBackground;
- (NSColor*) colorForBackground;
- (NSColor*) colorForWarning;
- (NSColor*) colorForError;

- (NSArray*) controlAlternatingRowBackgroundColors;
@end
