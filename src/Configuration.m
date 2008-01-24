#import "Configuration.h"
#import "MainWindowController.h"

@implementation Configuration

@synthesize useGrowl, showWindowWhenNewMessage, alwaysExpandMessage, refreshInterval, usePost;

static id _instance = nil;

// this should be an instance variable but I couldn't make this class a perfect singleton (override allocWithZone, copyWithZone, retain, retainCount, release, autorelease)
// due to "Controller cannot be nil" error at a boot time. Then I allow multiple instance (allow IB to instantiate this class), and make this a class variable to be shared by all instances.
static id<TimelineSortOrderChangeObserver> _timelineSortOrderChangeObserver;

+ (id) instance {
    @synchronized (self) {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

//+ (id)allocWithZone:(NSZone*)zone {
//    @synchronized(self) {
//        if (!_instance) {
//            _instance = [super allocWithZone:zone];
//            return _instance;
//        }
//    }
//    return nil;
//}
//
//- (id)copyWithZone:(NSZone*)zone {
//    return self;
//}
//
//- (id)retain {
//    return self;
//}
//
//- (unsigned)retainCount {
//    return UINT_MAX;
//}
//
//- (void)release {
//}
//
//- (id)autorelease {
//    return self;
//}

- (void) bindToProperty:(NSString*)propertyName {
    [self bind:propertyName
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:[@"values." stringByAppendingString:propertyName]
       options:nil];
}

- (id) init {
    [self bindToProperty:@"useGrowl"];
    [self bindToProperty:@"showWindowWhenNewMessage"];
    [self bindToProperty:@"alwaysExpandMessage"];
    [self bindToProperty:@"usePost"];
    [self bindToProperty:@"refreshInterval"];
    return self;
}

- (int) timelineSortOrder {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"timelineSortOrder"];
}

- (void) setTimelineSortOrder:(int)sortOrder {
    [[NSUserDefaults standardUserDefaults] setInteger:sortOrder forKey:@"timelineSortOrder"];
    [_timelineSortOrderChangeObserver timelineSortOrderChangeObserverSortOrderChanged];
}

+ (void) setTimelineSortOrderChangeObserver:(id<TimelineSortOrderChangeObserver>)observer {
    _timelineSortOrderChangeObserver = observer;
}

@end
