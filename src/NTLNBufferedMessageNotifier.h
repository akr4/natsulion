#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"

@interface NTLNBufferedMessageNotifier : NSObject {
    float _timeoutSeconds;
    int _maxMessage;
    NSMutableArray *_messages;
    NSTimer *_entireTimer;
    NSTimer *_shortTimer;
}
+ (id) notifierWithTimeout:(float)seconds maxMessage:(int)max;
- (id) initWithTimeout:(float)seconds maxMessage:(int)max;
- (void) addMessageViewController:(NTLNMessageViewController*)controller;
- (BOOL) contains:(NTLNMessageViewController*)controller;
@end
