#import <Cocoa/Cocoa.h>

#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING 0
#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING 1

@protocol TimelineSortOrderChangeObserver;

@interface Configuration : NSObject {
    BOOL useGrowl;
    BOOL showWindowWhenNewMessage;
    BOOL alwaysExpandMessage;
    int refreshInterval;
    int timelineSortOrder;

    id<TimelineSortOrderChangeObserver> _timelineSortOrderChangeObserver;
}

@property BOOL useGrowl, showWindowWhenNewMessage, alwaysExpandMessage;
@property int refreshInterval;

+ (id) instance;
- (int) timelineSortOrder;
- (void) setTimelineSortOrder:(int)sortOrder;
- (void) setTimelineSortOrderChangeObserver:(id<TimelineSortOrderChangeObserver>)observer;

@end
