#import <Cocoa/Cocoa.h>

@protocol AsyncUrlConnectionCallback 
- (void) responseArrived:(NSData*)response statusCode:(int)code;
- (void) connectionFailed:(NSError*)error;
@end

@interface AsyncUrlConnection : NSObject {
    NSObject<AsyncUrlConnectionCallback> *_callback;
    NSURLConnection *_connection;
    NSMutableData *_recievedData;
    int _statusCode;
    NSString *_username;
    NSString *_password;
}
- (id) initWithUrl:(NSString*)url callback:(NSObject<AsyncUrlConnectionCallback>*)callback;
- (id) initWithUrl:(NSString*)url username:(NSString*)username password:(NSString*)password callback:(NSObject<AsyncUrlConnectionCallback>*)callback;
- (id) initPostConnectionWithUrl:(NSString*)url bodyString:(NSString*)bodyString username:(NSString*)username password:(NSString*)password callback:(NSObject<AsyncUrlConnectionCallback>*)callback;
@end
