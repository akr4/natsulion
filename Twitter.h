#import <Cocoa/Cocoa.h>
#import "AsyncUrlConnection.h"
#import "IconRepository.h"

@protocol TimelineCallback
- (void) finishedToGetTimeline:(NSArray *)statuses;
- (void) started;
- (void) stopped;
@end

@protocol TwitterPostCallback
- (void) finishedToPost;
@end

// callback for post
@interface TwitterPostCallbackHandler : NSObject<AsyncUrlConnectionCallback> {
    id _parent;
}
- (id) initWithParentId:(id)parent;
@end

@interface Twitter : NSObject <AsyncUrlConnectionCallback, IconCallback> {
    NSObject<TimelineCallback> *_friendTimelineCallback;
    NSObject<TwitterPostCallback> *_twitterPostCallback;
    
    NSMutableDictionary *_waitingIconTwitterStatuses;
    IconRepository *_iconRepository;
    
    BOOL _downloadingTimeline;
    BOOL _postingMessage;
}
- (id) init;
- (void) friendTimelineWithCallback:(NSObject<TimelineCallback>*)callback;
- (void) sendMessage:(NSString*)message withCallback:(NSObject<TwitterPostCallback>*)callback;

// only for private class
- (void) finishedToSendMessage;
@end
