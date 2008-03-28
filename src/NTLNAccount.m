#import "NTLNAccount.h"
#import "NTLNKeyChain.h"
#import "NTLNPreferencesWindowController.h"

static NTLNAccount *_instance;

@implementation NTLNAccount

+ (id) instance {
    if (!_instance) {
        return [NTLNAccount newInstance];
    }
    return _instance;
}

+ (id) newInstance {
    if (_instance) {
        [_instance release];
        _instance = nil;
    }
    
    _instance = [[NTLNAccount alloc] init];
    return _instance;
}

+ (id) newInstanceWithUsername:(NSString*)username {
    if (_instance) {
        [_instance release];
        _instance = nil;
    }
    
    _instance = [[NTLNAccount alloc] initWithUsername:username];

    return _instance;
}

- (id) initWithUsername:(NSString*)username {
    _username = username;
    [_username retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_username forKey:NTLN_PREFERENCE_USERID];
    [defaults synchronize];
    
    return self;
}

- (void) dealloc {
    [_username release];
    [super dealloc];
}

- (NSString*) username {
    if (!_username) {
        _username = [[NSUserDefaults standardUserDefaults] objectForKey:NTLN_PREFERENCE_USERID];
    }
    return _username;
}

- (NSString*) password {
    return [[NTLNKeyChain keychain] getPasswordForUsername:[self username]];
}

- (BOOL) addOrUpdateKeyChainWithPassword:(NSString*)password {
    return [[NTLNKeyChain keychain] addOrUpdateWithUsername:[self username] password:password];
}


@end
