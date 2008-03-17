#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "NTLNMultiTasksProgressIndicator.h"

@interface NTLNBufferedMessageNotifier : NSObject {
    float _timeoutSeconds;
    int _maxMessage;
    NSMutableArray *_messages;
    NSTimer *_entireTimer;
    NSTimer *_shortTimer;
    NTLNMultiTasksProgressIndicator *_progressIndicator;
}
+ (id) notifierWithTimeout:(float)seconds maxMessage:(int)max progressIndicator:(NTLNMultiTasksProgressIndicator*)progressIndicator;
- (id) initWithTimeout:(float)seconds maxMessage:(int)max progressIndicator:(NTLNMultiTasksProgressIndicator*)progressIndicator;
- (void) addMessageViewController:(NTLNMessageViewController*)controller;
- (BOOL) contains:(NTLNMessageViewController*)controller;
@end
