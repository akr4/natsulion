#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "NTLNMessage.h"

@interface NTLNGrowlNotifier : NSObject<GrowlApplicationBridgeDelegate> {

}

- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type;

- (void) sendToGrowl:(NTLNMessage*)message;
@end
