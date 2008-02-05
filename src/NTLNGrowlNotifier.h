#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface NTLNGrowlNotifier : NSObject<GrowlApplicationBridgeDelegate> {

}
- (id) init;
- (void) sendToGrowlTitle:(NSString*)title
           andDescription:(NSString*)description
                  andIcon:(NSData*)iconData 
              andPriority:(int)priority
                andSticky:(BOOL)sticky;
@end
