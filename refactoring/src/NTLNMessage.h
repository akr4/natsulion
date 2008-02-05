#import <Cocoa/Cocoa.h>

enum NTLNReplyType {
    MESSAGE_REPLY_TYPE_NORMAL,
    MESSAGE_REPLY_TYPE_DIRECT,
    MESSAGE_REPLY_TYPE_REPLY,
    MESSAGE_REPLY_TYPE_REPLY_PROBABLE,
};

@interface NTLNMessage : NSObject {
    NSString *statusId;
    NSString *name;
    NSString *screenName;
    NSString *text;
    NSDate *timestamp;
    NSImage *icon;
    enum NTLNReplyType replyType;
}

@property(readwrite, retain) NSString *statusId, *name, *screenName, *text;
@property(readwrite, retain) NSImage *icon;
@property(readwrite, retain) NSDate *timestamp;
@property(readwrite) enum NTLNReplyType replyType;

- (BOOL) isEqual:(id)anObject;
- (void) finishedToSetProperties;

@end
