#import <Cocoa/Cocoa.h>

@interface NTLNCustomViewCell : NSCell {
    NSView *_view;
}

- (void) addView:(NSView*)view;

@end
