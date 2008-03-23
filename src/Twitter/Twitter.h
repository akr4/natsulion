#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"
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
    int _code;
}
+ (id) infoWithType:(enum NTLNErrorType)type originalMessage:(NSString*)message;
- (enum NTLNErrorType)type;
- (void) setType:(enum NTLNErrorType)type;
- (NSString*)originalMessage;
- (void) setOriginalMessage:(NSString*)message;
@end

@protocol TwitterTimelineCallback
- (void) finishedToGetTimeline:(NSArray *)statuses;
- (void) failedToGetTimeline:(NTLNErrorInfo*)info;
- (void) twitterStartTask;
- (void) twitterStopTask;
@end

@protocol TwitterPostCallback
- (void) finishedToPost;
- (void) failedToPost:(NSString*)message;
- (void) twitterStartTask;
- (void) twitterStopTask;
@end

@protocol TwitterFavoriteCallback
- (void) finishedToChangeFavorite:(NSString*)statusId;
- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info;
- (void) twitterStartTask;
- (void) twitterStopTask;
@end

@interface TwitterTimelineCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> {
    id<TwitterTimelineCallback> _callback;
    id _parent;
}
- (id) initWithCallback:(id<TwitterTimelineCallback>)callback parent:(id)parent;
@end

@interface TwitterPostCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> {
    id<TwitterPostCallback> _callback;
}
- (id) initWithPostCallback:(id<TwitterPostCallback>)callback;
@end

@interface TwitterFavoriteCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> {
    id<TwitterFavoriteCallback> _callback;
    NSString *_statusId;
}
- (id) initWithStatusId:(NSString*)statusId callback:(id<TwitterFavoriteCallback>)callback;
@end

@interface Twitter : NSObject {
    
}
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post;
- (void) repliesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post;
- (void) sentMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post;
- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password;
- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password;
@end

@interface TwitterImpl : Twitter<NTLNIconCallback> {
    id<TwitterTimelineCallback, TwitterFavoriteCallback, TwitterPostCallback> _callback;
    NTLNIconRepository *_iconRepository;
    
    NTLNAsyncUrlConnection *_connectionForFriendTimeline;
    NTLNAsyncUrlConnection *_connectionForReplies;
    NTLNAsyncUrlConnection *_connectionForSentMessages;
    NTLNAsyncUrlConnection *_connectionForPost;
    NTLNAsyncUrlConnection *_connectionForFavorite;
    
    NSMutableDictionary *_waitingIconTwitterStatuses;
}
- (id) initWithCallback:(id<TwitterTimelineCallback, TwitterFavoriteCallback, TwitterPostCallback>)callback;

// methods for TwitterTimelineCallbackHandler
- (void) pushIconWaiter:(NTLNMessage*)waiter forUrl:(NSString*)url;
- (NSSet*) popIconWaiterSet:(NSString*)url;
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
