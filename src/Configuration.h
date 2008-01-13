#import <Cocoa/Cocoa.h>

#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING 0
#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING 1

@protocol TimelineSortOrderChangeObserver;

@interface Configuration : NSObject {
    IBOutlet NSObject<TimelineSortOrderChangeObserver> *timelineSortOrderChangeObserver;
    
    BOOL useGrowl;
    BOOL showWindowWhenNewMessage;
    BOOL alwaysExpandMessage;
    int refreshInterval;
    int timelineSortOrder;
}

@property BOOL useGrowl, showWindowWhenNewMessage, alwaysExpandMessage;
@property int refreshInterval;

- (int) timelineSortOrder;
- (void) setTimelineSortOrder:(int)sortOrder;

@end
