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
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password callback:(NSObject<TimelineCallback>*)callback;
- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback;

// only for private class
- (void) finishedToSendMessage;
@end


#define NTLN_TWITTERCHECK_SUCESS 0
#define NTLN_TWITTERCHECK_AUTH_FAILURE 1
#define NTLN_TWITTERCHECK_FAILURE 2

@protocol TwitterCheckCallback
- (void) finishedToCheck:(int)result;
@end

@interface TwitterCheck : NSObject<AsyncUrlConnectionCallback> {
    NSObject<TwitterCheckCallback> *_callback;
    AsyncUrlConnection *_connection;
}    
- (void) checkAuthentication:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterCheckCallback>*)callback;
@end
