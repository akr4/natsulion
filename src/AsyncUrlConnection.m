#import "AsyncUrlConnection.h"
#import "PreferencesWindow.h"

@implementation AsyncUrlConnection

- (id)initWithUrl:(NSString*)url andCallback:(NSObject<AsyncUrlConnectionCallback>*)callback {
    NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
//    NSLog(@"sending request to %@", encodedUrl);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:encodedUrl]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0];
    [request setHTTPShouldHandleCookies:FALSE];

//    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
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

- (id) initPostConnectionWithUrl:(NSString*)url andBodyString:(NSString*)bodyString andCallback:(NSObject<AsyncUrlConnectionCallback>*)callback {
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
    [self release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
//    NSLog(@"receiving response... status code = %d", statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_callback responseArrived:_recievedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*) error {
    NSLog(@"connection:didFailWithError - %@", [error localizedFailureReason]);
    [_callback connectionFailed];
}

-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge { 
    if ([challenge previousFailureCount] == 0) { 
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // TODO: this class should not know user defaults key
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:[defaults objectForKey:PREFERENCE_USERID] password:[defaults objectForKey:PREFERENCE_PASSWORD] persistence:NSURLCredentialPersistenceNone]; 
        
//        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"xi42" password:@"FNe3T5i49nOPxkfU" persistence:NSURLCredentialPersistenceNone]; 
        NSLog([newCredential description]);
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge]; 
    } else { 
        NSLog(@"authentication failure");
        [[challenge sender] cancelAuthenticationChallenge:challenge]; 
        // inform the user that the user name and password 
        // in the preferences are incorrect 
        //        [self showPreferencesCredentialsAreIncorrectPanel:self]; 
    } 
}    
@end