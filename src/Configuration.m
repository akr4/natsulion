#import "Configuration.h"
#import "MainWindowController.h"

@implementation Configuration

@synthesize useGrowl, showWindowWhenNewMessage, alwaysExpandMessage, refreshInterval;

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
//    NSLog(@"timelineSortOrder:%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"timelineSortOrder"]);
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"timelineSortOrder"];
}

- (void) setTimelineSortOrder:(int)sortOrder {
    [[NSUserDefaults standardUserDefaults] setInteger:sortOrder forKey:@"timelineSortOrder"];
    [timelineSortOrderChangeObserver timelineSortOrderChangeObserverSortOrderChanged];
}


@end
