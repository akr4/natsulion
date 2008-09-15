#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "NTLNMessage.h"

@protocol NTLNGrowlClickCallbackTarget
- (void) markAsRead:(NSString*)statusId;
@end

@interface NTLNGrowlNotifier : NSObject<GrowlApplicationBridgeDelegate> {
    NSObject<NTLNGrowlClickCallbackTarget> *_callbackTarget;
}

- (void) setCallbackTarget:(NSObject<NTLNGrowlClickCallbackTarget>*)target;
- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type;

- (void) sendToGrowl:(NTLNMessage*)message;
@end
