#import "MessageInputTextField.h"

#define MARGIN 4.0f

@implementation MessageInputTextField

- (void) awakeFromNib {
    [self setDelegate:self];
    _defaultHeight = [self frame].size.height;
    _defaultBackgroundColor = [[self backgroundColor] retain];
}

- (void) dealloc  {
    [_defaultBackgroundColor release];
    [super dealloc];
}

- (void) setLengthForWarning:(int)warning max:(int)max {
    _warningLength = warning;
    _maxLength = max;
}

- (void) setCallback:(NSObject<MessageInputTextFieldCallback>*)callback {
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

- (void) updateHeight {
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
    
    [_callback messageInputTextFieldResized:heightDelta];
}

- (void) checkAndUpdateMaxLength {
    if (_maxLength <= [[self stringValue] length]) {
        _lengthState = NTLN_LENGTH_STATE_MAXIMUM;
        //                [self setEnabled:FALSE];
        [self setBackgroundColor:[NSColor colorWithDeviceHue:0 saturation:0.22 brightness:1 alpha:1]];
    }
}

- (void) checkAndUpdateWarningLength {
    if (_warningLength <= [[self stringValue] length] && [[self stringValue] length] < _maxLength) {
        _lengthState = NTLN_LENGTH_STATE_WARNING;
        [self setBackgroundColor:[NSColor colorWithDeviceHue:0 saturation:0.10 brightness:1 alpha:1]];
    }
}

- (void) checkAndUpdateNormalLength {
    if ([[self stringValue] length] < _warningLength) {
        _lengthState = NTLN_LENGTH_STATE_NORMAL;
        [self setBackgroundColor:_defaultBackgroundColor];
    }
}

- (void) updateTextState {
        
    switch (_lengthState) {
        case NTLN_LENGTH_STATE_NORMAL:
            [self checkAndUpdateMaxLength];
            [self checkAndUpdateWarningLength];
            break;
            
        case NTLN_LENGTH_STATE_WARNING:
            [self checkAndUpdateMaxLength];
            [self checkAndUpdateNormalLength];
            break;
        
        case NTLN_LENGTH_STATE_MAXIMUM:
            [self checkAndUpdateWarningLength];
            [self checkAndUpdateNormalLength];
            break;
            
        default:
            break;
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [self updateTextState];
    [self updateHeight];
    [_callback messageInputTextFieldChanged:[[self stringValue] length] state:_lengthState];
}

- (void)setFrameSize:(NSSize)newSize {
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [super setFrameSize:newSize];
    if (!_frameSizeInternalChanging) {
        [self updateHeight];
    }
}

@end
