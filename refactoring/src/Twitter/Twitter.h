#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "NTLNAsyncUrlConnection.h"
#import "NTLNIconRepository.h"

enum NTLNErrorType {
    NTLN_ERROR_TYPE_HIT_API_LIMIT,
    NTLN_ERROR_TYPE_NOT_AUTHORIZED,
    NTLN_ERROR_TYPE_SERVER_ERROR,
    NTLN_ERROR_TYPE_CONNECTION,
    NTLN_ERROR_TYPE_OTHER
};

@interface NTLNErrorInfo : NSObject {
    enum NTLNErrorType _type;
    NSString *_originalMessage;
}
+ (id) infoWithType:(enum NTLNErrorType)type originalMessage:(NSString*)message;
- (enum NTLNErrorType)type;
- (void) setType:(enum NTLNErrorType)type;
- (NSString*)originalMessage;
- (void) setOriginalMessage:(NSString*)message;
@end

@protocol TimelineCallback
- (void) finishedToGetTimeline:(NSArray *)statuses;
- (void) failedToGetTimeline:(NTLNErrorInfo*)info;
- (void) finishedAll;
@end

@protocol TwitterPostCallback
- (void) finishedToPost;
- (void) failedToPost:(NSString*)message;
@end

@protocol TwitterFavoriteCallback
- (void) finishedToChangeFavorite:(NSString*)statusId;
- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info;
@end

@protocol TwitterIconWaiterQueue
- (void) pushIconWaiter:(TwitterStatus*)waiter forUrl:(NSString*)url;
- (NSSet*) popIconWaiterSet:(NSString*)url;
@end

@interface TwitterTimelineCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback, NTLNIconCallback> {
    id<TimelineCallback> _callback;
    NTLNIconRepository *_iconRepository;
    id<TwitterIconWaiterQueue> _iconWaiterQueue;
}
- (id) initWithCallback:(id<TimelineCallback>)callback queue:(id<TwitterIconWaiterQueue>)iconWaiterQueue;
@end

@interface TwitterPostCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> {
    id<TwitterPostCallback> _callback;
}
- (id) initWithCallback:(id<TwitterPostCallback>)callback;
@end

@interface TwitterFavoriteCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> {
    id<TwitterFavoriteCallback> _callback;
    NSString *_statusId;
}
- (id) initWithStatusId:(NSString*)statusId callback:(id<TwitterFavoriteCallback>)callback;
@end

@interface Twitter : NSObject {
    
}
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post callback:(NSObject<TimelineCallback>*)callback;
- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback;
- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback;
@end

@interface TwitterImpl : Twitter<TwitterIconWaiterQueue> {
    id<TimelineCallback> _timelineCallback;
    
    NTLNAsyncUrlConnection *_connectionForFriendTimeline;
    NTLNAsyncUrlConnection *_connectionForPost;
    NTLNAsyncUrlConnection *_connectionForFavorite;
    
    NSMutableDictionary *_waitingIconTwitterStatuses;

    BOOL _downloadingTimeline;
}
- (id) init;
@end

#define NTLN_TWITTERCHECK_SUCESS 0
#define NTLN_TWITTERCHECK_AUTH_FAILURE 1
#define NTLN_TWITTERCHECK_FAILURE 2

@protocol TwitterCheckCallback
- (void) finishedToCheck:(int)result;
@end

@interface TwitterCheck : NSObject<NTLNAsyncUrlConnectionCallback> {
    NSObject<TwitterCheckCallback> *_callback;
    NTLNAsyncUrlConnection *_connection;
}    
- (void) checkAuthentication:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterCheckCallback>*)callback;
@end
