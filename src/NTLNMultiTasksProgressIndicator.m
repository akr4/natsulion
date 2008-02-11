#import "NTLNMultiTasksProgressIndicator.h"


@implementation NTLNMultiTasksProgressIndicator
- (void) startTask {
    if (_runningTasks == 0) {
        [self startAnimation:self];
    }
    _runningTasks++;
//    NSLog(@"start task: %d", _runningTasks);
}

- (void) stopTask {
    _runningTasks--;
    if (_runningTasks == 0) {
        [self stopAnimation:self];
    }
//    NSLog(@"stop task: %d", _runningTasks);
}
@end
