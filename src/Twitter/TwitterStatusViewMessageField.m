#import "TwitterStatusViewMessageField.h"
#import "URLExtractor.h"
#import "UIUtils.h"
#import "TwitterUtils.h"
#import "NTLNColors.h"
#import "Configuration.h"
#import "TwitterStatusViewController.h"

@interface NSAttributedString (Hyperlink)
+(id) hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL attributes:(NSDictionary*)attributes;
@end

@implementation NSAttributedString (Hyperlink)
+(id) hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL attributes:(NSDictionary*)attributes {
    NSMutableAttributedString* attrString = [[[NSMutableAttributedString alloc] initWithString:inString] autorelease];
    NSRange range = NSMakeRange(0, [attrString length]);
    [attrString addAttributes:attributes range:range];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    return attrString;
}
@end

@implementation TwitterStatusViewMessageTextView

- (void) setParentView:(TwitterStatusViewMessageField*)parent {
    _parent = parent;
}

- (void) mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if (![_parent highlighted]) {
        [[[_parent controller] view] mouseDown:theEvent];
    }
}

@end

@implementation TwitterStatusViewMessageField

- (void) awakeFromNib {
    _defaultHeight = [self frame].size.height;
    _defaultY = [self frame].origin.y;
    [textView setParentView:self];
    [textView setAutomaticLinkDetectionEnabled:TRUE];
//    [self setAllowsEditingTextAttributes:TRUE];
}

// internal methods /////////////////////////////////////////////////////////////////////////////////////

- (TwitterStatusViewController*)controller {
    return _controller;
}

- (void) setViewController:(TwitterStatusViewController*)controller {
    _controller = controller; // weak reference
}

- (NSDictionary*) defaultFontAttributes {
    NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
//    [style setLineSpacing:0.0];
//    [style setMinimumLineHeight:4];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont userFontOfSize:[NSFont systemFontSize]], NSFontAttributeName,
            style, NSParagraphStyleAttributeName,
            nil];

}

- (float) heightForString {
    [[textView layoutManager] glyphRangeForTextContainer:[textView textContainer]];
    float height = [[textView layoutManager] usedRectForTextContainer:[textView textContainer]].size.height;
//    NSLog(@"--- %f, %f, %f, %@",
//          height, 
//          [[self layoutManager] usedRectForTextContainer:[self textContainer]].size.width, 
//          [[self textContainer] containerSize].width,
//          [self textStorage]);
    return height;
}

- (void) setValueAndFormat:(NSString*)aString colorForText:(NSColor*)colorForText {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    URLExtractor *extractor = [[[URLExtractor alloc] init] autorelease];
    NSArray *tokens = [extractor tokenizeByAll:aString];
    
    NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] init] autorelease];
    int i;
    for (i = 0; i < [tokens count]; i++) {
        NSString *token = [tokens objectAtIndex:i];
        //        NSLog(@"token: %@", token);
        if ([extractor isURLToken:token]) {
            [string appendAttributedString:[NSAttributedString hyperlinkFromString:token 
                                                                               URL:[NSURL URLWithString:token] 
                                                                        attributes:[self defaultFontAttributes]]];
        } else if ([extractor isIDToken:token]) {
            [string appendAttributedString:
            [NSAttributedString hyperlinkFromString:token
                                                URL:[NSURL URLWithString:
                                                     [[TwitterUtils utils] userPageURLString:[token substringFromIndex:1]]]
                                         attributes:[self defaultFontAttributes]]];
        } else {
            NSMutableAttributedString *s = [[[NSMutableAttributedString alloc] initWithString:token] autorelease];
            NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[self defaultFontAttributes]];
            [attrs setObject:colorForText forKey:NSForegroundColorAttributeName];
            [s setAttributes:attrs range:NSMakeRange(0, [s length])];
            [string appendAttributedString:s];
        }
    }
    [[textView textStorage] setAttributedString:string];
}

// public methods //////////////////////////////////////////////////////////////////////
// returns delta of expaned height
- (float) expandIfNeeded {
//    NSLog(@"-*- width: %f", [self frame].size.width);
    float height = [self heightForString];
    if (height > _defaultHeight) {
        [textView setFrameSize:NSMakeSize([self frame].size.width, height)];
    } else {
        [textView setFrameSize:NSMakeSize([self frame].size.width, _defaultHeight)];
    }    
//    NSLog(@"**** %@ - %f", [self attributedStringValue], height);
    return height - _defaultHeight;
}

- (void) setMessage:(NSString*)message {
    [self setValueAndFormat:message colorForText:[NTLNColors colorForText]];
}

- (void) highlight {
    _highlighted = TRUE;
    [self setValueAndFormat:[[textView textStorage] string] colorForText:[NTLNColors colorForHighlightedText]];
    [textView setSelectable:TRUE];
    [textView setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:NSUnderlineStyleNone], NSUnderlineStyleAttributeName,
                                    [NTLNColors colorForHighlightedLink], NSForegroundColorAttributeName,
                                    [NSCursor pointingHandCursor], NSCursorAttributeName,
                                    nil]];
}

- (void) unhighlight {
    _highlighted = FALSE;
    [self setValueAndFormat:[[textView textStorage] string] colorForText:[NTLNColors colorForText]];
    [textView setSelectable:FALSE];
    if (![[Configuration instance] alwaysExpandMessage]) {
        [self setFrameSize:NSMakeSize([self frame].size.width, _defaultHeight)];
    }
    [textView setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:NSUnderlineStyleNone], NSUnderlineStyleAttributeName,
                                 [NTLNColors colorForLink], NSForegroundColorAttributeName,
                                 [NSCursor pointingHandCursor], NSCursorAttributeName,
                                 nil]];
}

- (BOOL) highlighted {
    return _highlighted;
}

- (void)scrollWheel:(NSEvent *)theEvent {
    [[self superview] scrollWheel:theEvent];
}

@end
