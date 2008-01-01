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

- (void) dealloc {
    [_status release];
    [super dealloc];
}

- (NSString*) decodeEntityReferences:(NSString*)aString {
    EntityReferenceConverter *converter = [[[EntityReferenceConverter alloc] init] autorelease];
    return [converter dereference:aString];
}

@end
