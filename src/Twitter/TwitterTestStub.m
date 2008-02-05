#import "TwitterTestStub.h"
#import "NTLNMessage.h"
#import "TwitterStatus.h"

@implementation TwitterTestStub
- (NTLNMessage*) messageForId:(NSString*)statusId {
    NTLNMessage *m = [[[TwitterStatus alloc] init] autorelease];
    [m setStatusId:statusId]; 
    [m setName:@"akr"];
    [m setScreenName:@"akr"];
    [m setText:@"HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"];
    [m setTimestamp:[NSDate date]];
    [m finishedToSetProperties];
    return m;
}

- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterTimelineCallback>*)callback {
    
    NSMutableArray *messages = [[[NSMutableArray alloc] init] autorelease];

    for (int i = 0; i < 20; i++) {
        [messages addObject:[self messageForId:[[NSDate date] description]]];
    }
    
    [callback finishedToGetTimeline:messages];
    
//    [callback failedToGetTimeline:[NTLNErrorInfo infoWithType:999 originalMessage:nil]];
    [callback finishedAll];
}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback {
    
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback {
    [callback failedToChangeFavorite:statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_SERVER_ERROR originalMessage:@"fav failed"]];
}
@end