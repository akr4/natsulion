#import <Cocoa/Cocoa.h>

@interface Account : NSObject {
    NSString *_password;
}

+ (id) instance;
+ (id) newInstance;

- (NSString*) username;
- (NSString*) password;
- (BOOL) addOrUpdateKeyChainWithPassword:(NSString*)password;

@end


