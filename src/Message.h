#import <Cocoa/Cocoa.h>

typedef enum replyType_enum {
    MESSAGE_REPLY_TYPE_NORMAL,
    MESSAGE_REPLY_TYPE_DIRECT,
    MESSAGE_REPLY_TYPE_REPLY,
    MESSAGE_REPLY_TYPE_REPLY_PROBABLE,
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
- (void) finishedToSetProperties;

@end
