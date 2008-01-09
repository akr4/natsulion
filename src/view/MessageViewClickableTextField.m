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

    // check only right or others (=regarded as left)
    if ([self alignment] == NSRightTextAlignment) {
        rect.origin.x = [self bounds].size.width - width;
    }
    
    return rect;
}

- (void) setStringValue:(NSString*)aString {
    [super setStringValue:aString];
    
    
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:[self rectForText]
                                                                 options: (NSTrackingMouseEnteredAndExited | NSTrackingCursorUpdate | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    [self addTrackingArea:trackingArea];
    
}

- (BOOL) mouseIsOnText {
    return _mouseIsOnText;
}

-(void)cursorUpdate:(NSEvent *)theEvent {
    if (_mouseIsOnText) {
        [[NSCursor pointingHandCursor] set];
    } else {
        [[NSCursor arrowCursor] set]; // is it possible to use previous cursor instead of concreat arrowCursor?
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedLink]];
    } else {
        [self setTextColor:[NTLNColors colorForLink]];
    }
    _mouseIsOnText = TRUE;
}

- (void)mouseExited:(NSEvent *)theEvent {
    if ([self highlighted]) {
        [self setTextColor:[NTLNColors colorForHighlightedText]];
    } else {
        [self setTextColor:[self defaultColor]];
    }
    _mouseIsOnText = FALSE;
}

@end
