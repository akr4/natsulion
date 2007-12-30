#import "AutoResizingTextField.h"

#define MARGIN 4.0f

@implementation AutoResizingTextField

- (void) awakeFromNib {
    [self setDelegate:self];
    _defaultHeight = [self frame].size.height;
}

- (void) setCallback:(NSObject<AutoResizingTextFieldCallback>*)callback {
    _callback = callback;
}

- (float) heightForString:(NSString*)myString andFont:(NSFont*)myFont andWidth:(float)myWidth {
    NSTextStorage *textStorage = [[[NSTextStorage alloc]
                                   initWithString:myString] autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc]
                                       initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]
                                      autorelease];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager
            usedRectForTextContainer:textContainer].size.height;
}

- (void) changeHeight {
    float height;
    NSRect currentRect = [self frame];
    
    if ([self stringValue] == nil || [[self stringValue] length] == 0) {
        height = _defaultHeight;
    } else {
        NSDictionary *attributes = [[self attributedStringValue] attributesAtIndex:0 effectiveRange:nil];
        NSFont *font = (NSFont*)[attributes valueForKey:@"NSFont"];
        height = [self heightForString:[self stringValue] andFont:font andWidth:(currentRect.size.width - MARGIN * 2)] + MARGIN;
    }
    if (height < _defaultHeight) {
        height = _defaultHeight;
    }
//    NSLog(@"height: %f", height);
    
    float heightDelta = currentRect.size.height - height;
    NSSize newSize;
    newSize.height = height;
    newSize.width = currentRect.size.width;
    
    _frameSizeInternalChanging = TRUE;
    [super setFrameSize:newSize];
    _frameSizeInternalChanging = FALSE;
    
    [_callback autoResizingTextFieldResized:heightDelta];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [self changeHeight];
}

- (void)setFrameSize:(NSSize)newSize {
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [super setFrameSize:newSize];
    if (!_frameSizeInternalChanging) {
        [self changeHeight];
    }
}

@end
