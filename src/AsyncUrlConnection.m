#import "AsyncUrlConnection.h"

@implementation AsyncUrlConnection

- (id) initWithUrl:(NSString*)url callback:(NSObject<AsyncUrlConnectionCallback>*)callback {
    return [self initWithUrl:url username:nil password:nil callback:callback];
}

- (id)initWithUrl:(NSString*)url username:(NSString*)username password:(NSString*)password callback:(NSObject<AsyncUrlConnectionCallback>*)callback {
    
    _username = username;
    [_username retain];
    _password = password;
    [_password retain];
    
    NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
//    NSLog(@"sending request to %@", encodedUrl);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:encodedUrl]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:10.0];
    [request setHTTPShouldHandleCookies:FALSE];

    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"failed to get connection.");
        return nil;
    }
    
    _callback = callback;
    [_callback retain];
    _recievedData = [[NSMutableData alloc] init];
    return self;
}

- (id) initPostConnectionWithUrl:(NSString*)url bodyString:(NSString*)bodyString username:(NSString*)username password:(NSString*)password callback:(NSObject<AsyncUrlConnectionCallback>*)callback {
    
    _username = username;
    [_username retain];
    _password = password;
    [_password retain];

    NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
//    NSLog(@"sending (encoded) request to %@", encodedUrl);

    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:encodedUrl]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:FALSE];
 
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"failed to get connection.");
        return nil;
    }
    
    _callback = callback;
    [_callback retain];
    _recievedData = [[NSMutableData alloc] init];
    return self;
}

- (void)delalloc {
    [_callback release];
    [_recievedData release];
    [_username release];
    [_password release];
    [self release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    _statusCode = [httpResponse statusCode];
//    NSLog(@"receiving response... status code = %d", statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_callback responseArrived:_recievedData statusCode:_statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*) error {
    NSLog(@"connection:didFailWithError - %@ - %d - %@", [error localizedFailureReason], [error code], [error description]);
    [_callback connectionFailed:error];
}

-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge { 
    if ([challenge previousFailureCount] == 0) { 
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone]; 
        NSLog([newCredential description]);
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge]; 
    } else { 
        NSLog(@"authentication failure");
        // TODO: should be "real" code
//        _statusCode = 401;
        [[challenge sender] cancelAuthenticationChallenge:challenge]; 
    } 
}    
@end