#import <Cocoa/Cocoa.h>


@interface NTLNMessageViewTextField : NSTextField {
    NSColor *_defaultColor;
    BOOL _highlighted;
}

- (void) highlight;
- (void) unhighlight;
- (BOOL) highlighted;
- (NSColor*) defaultColor;
- (void) notifyColorChange;

@end
