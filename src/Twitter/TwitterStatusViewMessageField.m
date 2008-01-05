#import "TwitterStatusViewMessageField.h"
#import "URLExtractor.h"
#import "TwitterUtils.h"
#import "NTLNColors.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL colorForLink:(NSColor*)color;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL colorForLink:(NSColor*)color {
    NSMutableAttributedString* attrString = [[[NSMutableAttributedString alloc] initWithString: inString] autorelease];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    // next make the text appear with an underline
//    [attrString addAttribute:
//     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return attrString;
}
@end

@implementation TwitterStatusViewMessageField

- (void) awakeFromNib {
    [super awakeFromNib];
    _defaultHeight = [self frame].size.height;
    [self setAllowsEditingTextAttributes:TRUE];
}


// internal methods /////////////////////////////////////////////////////////////////////////////////////

- (float) heightForString:(NSAttributedString*)myString andWidth:(float)myWidth {
    NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithAttributedString:myString] autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textContainer setLineFragmentPadding:4];
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager
            usedRectForTextContainer:textContainer].size.height;
}

- (void) setValueAndFormat:(NSString*)aString colorForLink:(NSColor*)colorForLink {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    URLExtractor *extractor = [[[URLExtractor alloc] init] autorelease];
    NSArray *tokens = [extractor tokenizeByAll:aString];
    
    NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] init] autorelease];
    int i;
    for (i = 0; i < [tokens count]; i++) {
        NSString *token = [tokens objectAtIndex:i];
        //        NSLog(@"token: %@", token);
        if ([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_HTTP].location == 0 && [token length] > [NTLN_URLEXTRACTOR_PREFIX_HTTP length]) {
            [string appendAttributedString:[NSAttributedString hyperlinkFromString:token URL:[NSURL URLWithString:token] colorForLink:colorForLink]];
        } else if ([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_ID].location == 0  && [token length] > [NTLN_URLEXTRACTOR_PREFIX_ID length]) {
            [string appendAttributedString:
             [NSAttributedString hyperlinkFromString:token
                                                 URL:[NSURL URLWithString:[[[[TwitterUtils alloc] init] autorelease] userPageURLString:[token substringFromIndex:1]]]
                                        colorForLink:colorForLink]];
        } else {
            [string appendAttributedString:[[[NSAttributedString alloc] initWithString:token] autorelease]];
        }
    }
    [self setAttributedStringValue:string];
}

// public methods //////////////////////////////////////////////////////////////////////
// returns delta of expaned height
- (float) expandIfNeeded {
    float height = [self heightForString:[self attributedStringValue] andWidth:([self frame].size.width - 16)] + 2;
    if (height > _defaultHeight) {
//        NSRect rect = [self frame];
//        rect.size.height = height;
//        rect.origin.y = 63;
        
        
//        [self setFrame:rect];
        [self setFrameSize:NSMakeSize([self frame].size.width, height)];
    }
    
    return height - _defaultHeight;
}

- (void) setMessage:(NSString*)message {
    [self setValueAndFormat:message colorForLink:[NTLNColors colorForLink]];
}

- (void) highlight {
    [super highlight];
    [self setValueAndFormat:[self stringValue] colorForLink:[NTLNColors colorForHighlightedText]];
    [self setSelectable:TRUE];
}

- (void) unhighlight {
    [super unhighlight];
    [self setValueAndFormat:[self stringValue] colorForLink:[NTLNColors colorForLink]];
    [self setSelectable:FALSE];
    [self setFrameSize:NSMakeSize([self frame].size.width, _defaultHeight)];
}

@end
