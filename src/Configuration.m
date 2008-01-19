#import "Configuration.h"
#import "MainWindowController.h"

@implementation Configuration

@synthesize useGrowl, showWindowWhenNewMessage, alwaysExpandMessage, refreshInterval;

+ (id) instance {
    static id _instance = nil;
    @synchronized (self) {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

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

- (void) setTimelineSortOrderChangeObserver:(id<TimelineSortOrderChangeObserver>)observer {
    _timelineSortOrderChangeObserver = observer;
}

@end
