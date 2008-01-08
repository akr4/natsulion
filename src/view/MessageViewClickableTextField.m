#import "MessageViewClickableTextField.h"
#import "UIUtils.h"
#import "NTLNColors.h"

@implementation MessageViewClickableTextField

- (NSRect) rectForText {
    NSDictionary *attributes = [[self attributedStringValue] attributesAtIndex:0 effectiveRange:nil];
    NSFont *font = (NSFont*)[attributes valueForKey:@"NSFont"];
    float width = [[UIUtils utils] widthForString:[self stringValue] font:font height:[self frame].size.height];
    //    NSLog(@"width = %f", width);
    NSRect rect = [self bounds];
    rect.size.width = width;
    return rect;
}

- (void) setStringValue:(NSString*)aString {
    [super setStringValue:aString];
    
    
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self rectForText]
                                                                 options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
    
}

- (BOOL) isOnText:(NSPoint)point {
    id o = [self hitTest:[self convertPointToBase:point]];
    //    NSLog(@"<%@>", o);
    if (o == self) {
        return TRUE;
    }
    return FALSE;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedLink]];
    } else {
        [self setTextColor:[NTLNColors colorForLink]];
    }
    [[NSCursor pointingHandCursor] push];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedText]];
    } else {
        [self setTextColor:[self defaultColor]];
    }
    [NSCursor pop];
}

@end
