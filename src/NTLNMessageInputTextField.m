#import "NTLNMessageInputTextField.h"
#import "NTLNURLUtils.h"
#import "NTLNColors.h"
#import "NTLNConfiguration.h"
#import "NTLNNotification.h"

#define MARGIN 4.0f

@implementation NTLNMessageInputTextField

- (void) setupColors {
    [_backgroundColor release];
    _backgroundColor = [[[NTLNColors instance] colorForBackground] retain];
    [self setBackgroundColor:_backgroundColor];
    [self setTextColor:[[NTLNColors instance] colorForText]];
    [(NSTextView*)[[self window] fieldEditor:TRUE forObject:self] setInsertionPointColor:[[NTLNColors instance] colorForText]];
}

- (void) setupFontSize {
    [self setFont:[NSFont userFontOfSize:[[NTLNConfiguration instance] fontSize]]];
}

- (void) setupPlaceholderString {
    NSString *placeholderString;
    if ([[NTLNConfiguration instance] sendMessageWithEnterAndModifier])  {
        placeholderString = NSLocalizedString(@"Input your message and press \"Ctrl + Enter\" key", nil);
    } else {
        placeholderString = NSLocalizedString(@"Input your message and press \"Enter\" key", nil);
    }
    NSMutableAttributedString *placeHolderString = [[[NSMutableAttributedString alloc] initWithString:placeholderString] autorelease];
    NSRange range = NSMakeRange(0, [placeHolderString length]);
    [placeHolderString addAttribute:NSForegroundColorAttributeName value:[[NTLNColors instance] colorForSubText2] range:range];
    [[self cell] setPlaceholderAttributedString:placeHolderString];
}

- (void) awakeFromNib {
    [self setDelegate:self];
    _defaultHeight = [self frame].size.height;
    [self setupColors];
    [self setupFontSize];
    [self setupPlaceholderString];
    _backgroundCompositePolicy = NSCompositeCopy;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSettingChanged:)
                                                 name:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSettingChanged:)
                                                 name:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(fontSizeChanged:)
                                                 name:NTLN_NOTIFICATION_FONT_SIZE_CHANGED
                                               object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyForSendChanged:)
                                                 name:NTLN_NOTIFICATION_SEND_MESSAGE_WITH_ENTER_AND_MODIFIER_SETTING_CHANGED
                                               object:nil];    

}

- (void) dealloc  {
    [_backgroundColor release];
    [super dealloc];
}

- (BOOL)becomeFirstResponder {
    [(NSTextView*)[[self window] fieldEditor:TRUE forObject:self] setInsertionPointColor:[[NTLNColors instance] colorForText]];
    return [super becomeFirstResponder];
}

- (void) setLengthForWarning:(int)warning max:(int)max {
    _warningLength = warning;
    _maxLength = max;
}

- (void) setCallback:(NSObject<NTLNMessageInputTextFieldCallback>*)callback {
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
    if (_maxLength < [[self stringValue] length]) {
        _lengthState = NTLN_LENGTH_STATE_MAXIMUM;
        [_backgroundColor release];
        _backgroundColor = [[[NTLNColors instance] colorForError] retain];
    }
}

- (void) checkAndUpdateWarningLength {
    if (_warningLength < [[self stringValue] length] && [[self stringValue] length] <= _maxLength) {
        _lengthState = NTLN_LENGTH_STATE_WARNING;
        [_backgroundColor release];
        _backgroundColor = [[[NTLNColors instance] colorForWarning] retain];
    }
}

- (void) checkAndUpdateNormalLength {
    if ([[self stringValue] length] < _warningLength) {
        _lengthState = NTLN_LENGTH_STATE_NORMAL;
        [_backgroundColor release];
        _backgroundColor = [[[NTLNColors instance] colorForBackground] retain];
    }
}

- (void) updateWarnError {
        
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

- (void) textChanged {
    [self updateWarnError];
    [self updateHeight];
    [_callback messageInputTextFieldChanged:[[self stringValue] length] state:_lengthState];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [self textChanged];
}

- (void)setFrameSize:(NSSize)newSize {
//    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [super setFrameSize:newSize];
    if (!_frameSizeInternalChanging) {
        [self updateHeight];
    }
}

- (void) updateState {
    [self updateWarnError];
    [self updateHeight];
}

- (void) addReplyTo:(NSString*)username {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableString *newText = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
    [newText appendString:[self stringValue]];
    [newText appendString:@"@"];
    [newText appendString:username];
    [newText appendString:@" "];
    [self setStringValue:newText];
    [self textChanged];
    return;
//    
//    URLExtractor *extractor = [URLExtractor extractor];
//    NSArray *tokens = [extractor tokenizeByID:[self stringValue]];
//    
//    if ([tokens count] == 0) {
//        NSMutableString *newText = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
//        [newText appendString:@"@"];
//        [newText appendString:username];
//        [newText appendString:@" "];
//        [self setStringValue:newText];
//        [self textChanged];
//        return;
//    }
//    
////    NSLog(@"tokens: %@", [tokens description]);
//    
//    int lastIdTokenIndex = -1;
//    int i;
//    for (i = 0; i < [tokens count]; i++) {
//        NSString *token = [tokens objectAtIndex:i];
////        NSLog(@"i: %d, token: %@", i, [tokens objectAtIndex:i]);
//        if ([extractor isWhiteSpace:token]) {
//            continue;
//        }
//        if ([extractor isIDToken:token]) {
//            lastIdTokenIndex = i;
//        } else {
//            break; // regard the id tokens continueing from begin as id token
//        }
//    }
//    
//    NSMutableString *newText = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
//    
//    for (i = 0; i < [tokens count]; i++) {
//        [newText appendString:[tokens objectAtIndex:i]];
//        if (lastIdTokenIndex == i) {
//            [newText appendString:@" "];
//            [newText appendString:@"@"];
//            [newText appendString:username];
//        }
//    }
//    
//    if (lastIdTokenIndex == -1) {
//        [newText appendString:@"@"];
//        [newText appendString:username];
//        [newText appendString:@" "];
//    }
//    
//    [self setStringValue:newText];
//    [self textChanged];
}

- (void) focusAndLocateCursorEnd {
    [[self window] makeFirstResponder:self];
    [(NSText *)[[self window] firstResponder] setSelectedRange:NSMakeRange([[self stringValue] length], 0)];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (![[NTLNConfiguration instance] sendMessageWithEnterAndModifier]) {
        return FALSE;
    }
    
    if (command == @selector(insertNewline:)) {
        return TRUE;
    } else if (command == @selector(insertLineBreak:)) {
        [[self target] performSelector:[self action]];
        return FALSE;
    } else {
        return FALSE;
    }
}

- (void)drawRect:(NSRect)aRect {
    NSRect bounds = [self bounds]; 
    [super drawRect:bounds]; 
    
    if (_backgroundColor) {
        [_backgroundColor set];
        // there is a white border without this NSFrameRectWithWidth. if you know better way, please tell me. thanks.
        NSFrameRectWithWidth(bounds, 2.0); 
        NSRectFillUsingOperation(aRect, NSCompositeDestinationAtop);
    }
}

#pragma mark Notification
- (void) colorSettingChanged:(NSNotification*)notification {
    [self setupColors];
    [self setupPlaceholderString];
    [self setNeedsDisplay:TRUE];
}

- (void) fontSizeChanged:(NSNotification*)notification {
    [self setupFontSize];
}

- (void) keyForSendChanged:(NSNotification*)notification {
    [self setupPlaceholderString];
}
@end
