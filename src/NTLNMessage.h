#import <Cocoa/Cocoa.h>

enum NTLNReplyType {
    MESSAGE_REPLY_TYPE_NORMAL = 0,
    MESSAGE_REPLY_TYPE_DIRECT,
    MESSAGE_REPLY_TYPE_REPLY,
    MESSAGE_REPLY_TYPE_REPLY_PROBABLE,
};

enum NTLNMessageStatus {
    NTLN_MESSAGE_STATUS_NORMAL = 0,
    NTLN_MESSAGE_STATUS_READ,
};

@interface NTLNMessage : NSObject {
    NSString *statusId;
    NSString *name;
    NSString *screenName;
    NSString *text;
    NSDate *timestamp;
    NSImage *icon;
    enum NTLNReplyType replyType;
    enum NTLNMessageStatus status;
}

@property(readwrite, retain) NSString *statusId, *name, *screenName, *text;
@property(readwrite, retain) NSImage *icon;
@property(readwrite, retain) NSDate *timestamp;
@property(readwrite) enum NTLNReplyType replyType;
@property(readwrite) enum NTLNMessageStatus status;

- (BOOL) isEqual:(id)anObject;
- (void) finishedToSetProperties;

@end
