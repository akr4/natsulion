#import <Cocoa/Cocoa.h>

typedef enum replyType_enum {
    NORMAL,
    DIRECT,
    REPLY,
    REPLY_PROBABLE,
} replyType_t;



@interface Message : NSObject {
    NSString *statusId;
    NSString *name;
    NSString *screenName;
    NSString *text;
    NSDate *timestamp;
    NSImage *icon;
    replyType_t replyType;
}

@property(readwrite, retain) NSString *statusId, *name, *screenName, *text;
@property(readwrite, retain) NSImage *icon;
@property(readwrite, retain) NSDate *timestamp;
@property(readwrite) replyType_t replyType;

- (BOOL) isEqual:(id)anObject;

@end
