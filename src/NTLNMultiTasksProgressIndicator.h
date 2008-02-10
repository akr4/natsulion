#import <Cocoa/Cocoa.h>


@interface NTLNMultiTasksProgressIndicator : NSProgressIndicator {
    int _runningTasks;
}
- (void) startTask;
- (void) stopTask;
@end
