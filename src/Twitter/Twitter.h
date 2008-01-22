#import <Cocoa/Cocoa.h>
#import "AsyncUrlConnection.h"
#import "IconRepository.h"

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
- (void) started;
- (void) stopped;
@end

@protocol TwitterPostCallback
- (void) finishedToPost;
- (void) failedToPost:(NSString*)message;
@end

@protocol TwitterPostInternalCallback
- (void) finishedToPost;
- (void) failedToPost:(NSString*)message;
@end

@protocol TwitterFavoriteCallback
- (void) finishedToChangeFavorite:(NSString*)statusId;
- (void) failedToChangeFavorite:(NSString*)statusId errorInfo:(NTLNErrorInfo*)info;
@end

// callback for post
@interface TwitterPostCallbackHandler : NSObject<AsyncUrlConnectionCallback> {
    id<TwitterPostInternalCallback> _callback;
}
- (id) initWithCallback:(id<TwitterPostInternalCallback>)callback;
@end

@interface TwitterFavoriteCallbackHandler : NSObject<AsyncUrlConnectionCallback> {
    id<TwitterFavoriteCallback> _callback;
    NSString *_statusId;
}
- (id) initWithStatusId:(NSString*)statusId callback:(id<TwitterFavoriteCallback>)callback;
@end

@interface Twitter : NSObject {
    
}
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password callback:(NSObject<TimelineCallback>*)callback;
- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback;
- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback;
@end

@interface TwitterImpl : Twitter <AsyncUrlConnectionCallback, IconCallback, TwitterPostInternalCallback> {
    NSObject<TimelineCallback> *_friendTimelineCallback;
    NSObject<TwitterPostCallback> *_twitterPostCallback;
    NSObject<TwitterFavoriteCallback> *_twitterFavoriteCallback;
    
    AsyncUrlConnection *_connectionForFriendTimeline;
    AsyncUrlConnection *_connectionForPost;
    AsyncUrlConnection *_connectionForFavorite;
    
    NSMutableDictionary *_waitingIconTwitterStatuses;
    IconRepository *_iconRepository;
    TwitterPostCallbackHandler *_postCallbackHandler;
    TwitterFavoriteCallbackHandler *_favoriteCallbackHandler;
    
    BOOL _downloadingTimeline;
    BOOL _postingMessage;
}
- (id) init;
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
