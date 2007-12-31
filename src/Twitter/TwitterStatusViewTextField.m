#import "TwitterStatusViewTextField.h"
#import "EntityReferenceConverter.h"

@implementation TwitterStatusViewTextField

- (void) setStatus:(TwitterStatus*)status {
    _status = status;
    [status retain];
    
    [self setStringValue:[[[self decodeEntityReferences:[status name]]
                           stringByAppendingString:@"/"] 
                          stringByAppendingString:[self decodeEntityReferences:[status screenName]]]];
}

- (void) awakeFromNib {
    _defaultColor = [[self textColor] retain];
}

- (void) dealloc {
    [_defaultColor release];
    [_status release];
    [super dealloc];
}

- (void) highlight {
    [self setTextColor:[NSColor whiteColor]];
}

- (void) lowlight {
    [self setTextColor:_defaultColor];
}

- (NSString*) decodeEntityReferences:(NSString*)aString {
    EntityReferenceConverter *converter = [[[EntityReferenceConverter alloc] init] autorelease];
    return [converter dereference:aString];
}

@end
