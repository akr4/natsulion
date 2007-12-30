#import "TwitterStatusViewMessageField.h"
#import "URLExtractor.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return [attrString autorelease];
}
@end

@implementation TwitterStatusViewMessageField

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setAllowsEditingTextAttributes:TRUE];
}

- (void) highlight {
    [super highlight];
    [self setSelectable:TRUE];
}

- (void) lowlight {
    [super lowlight];
    [self setSelectable:FALSE];
}

- (void) setValueAndFormat:(NSString*)aString {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    URLExtractor *extractor = [[[URLExtractor alloc] init] autorelease];
    NSArray *tokens = [extractor tokenize:aString];
    
    NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] init] autorelease];
    int i;
    for (i = 0; i < [tokens count]; i++) {
        NSString *token = [tokens objectAtIndex:i];
//        NSLog(@"token: %@", token);
        if ([token rangeOfString:URLEXTRACTOR_PROTOCOL_HEAD_HTTP].location == 0) {
//            NSLog(@"URL found  -------------------------");
            [string appendAttributedString:[NSAttributedString hyperlinkFromString:token withURL:[NSURL URLWithString:token]]];
        } else {
            [string appendAttributedString:[[[NSAttributedString alloc] initWithString:token] autorelease]];
        }
    }
    [self setAttributedStringValue:string];
}

- (void) setMessage:(NSString*)message {
    [self setValueAndFormat:message];
}

@end
