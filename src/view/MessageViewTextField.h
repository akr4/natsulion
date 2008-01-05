#import <Cocoa/Cocoa.h>


@interface MessageViewTextField : NSTextField {
    NSColor *_defaultColor;
    BOOL _highlighted;
}

- (void) highlight;
- (void) unhighlight;
- (BOOL) highlighted;
- (NSColor*) defaultColor;

@end
