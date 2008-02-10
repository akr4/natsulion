#import "NTLNMessageListViewsController.h"
#import "NTLNAccount.h"

// class holds an information of a message view which can be switched by messageViewSelector.
@interface NTLNMessageViewInfo : NSObject {
    NSPredicate *_predicate;
    float _knobPosition;
}
- (id) initWithPredicate:(NSPredicate*)predicate;
- (NSPredicate*)predicate;
- (float) knobPosition;
- (void) setKnobPosition:(float)position;
@end

@implementation NTLNMessageViewInfo

+ (id) infoWithPredicate:(NSPredicate*)predicate {
    return [[[[self class] alloc] initWithPredicate:predicate] autorelease];
}

- (id) initWithPredicate:(NSPredicate*)predicate {
    [predicate retain];
    _predicate = predicate;
    return self;
}

- (void) dealloc {
    [_predicate release];
    [super dealloc];
}

- (NSPredicate*)predicate {
    return _predicate;
}

- (float) knobPosition {
    return _knobPosition;
}

- (void) setKnobPosition:(float)position {
    _knobPosition = position;
}

@end

/////////////////////////////////////////////////////////////////////////////////////
@implementation NTLNMessageListViewsController
- (id) init {
    _messageViewInfoArray = [[NSMutableArray alloc] initWithCapacity:10];
    _currentViewIndex = 0;
    
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:nil]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:
                                      [NSPredicate predicateWithFormat:@"message.replyType == %@", [NSNumber numberWithInt:MESSAGE_REPLY_TYPE_REPLY]]]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:
                                      [NSPredicate predicateWithFormat:@"message.screenName == %@", [[NTLNAccount instance] username]]]];
    
    return self;
}

- (void) dealloc {
    [_messageViewInfoArray release];
    [super dealloc];
}

// not used yet
//- (void) addInfoWithPredicate:(NSPredicate*)predicate {
//    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:predicate]];
//}

- (IBAction) changeView:(id) sender {
    // save status
    [[_messageViewInfoArray objectAtIndex:_currentViewIndex] setKnobPosition:[messageTableViewController knobPosition]];
    
    // change view
    _currentViewIndex = [sender selectedSegment];
    NTLNMessageViewInfo *messageViewInfo = [_messageViewInfoArray objectAtIndex:_currentViewIndex];
    // to use original one causes an exception
    [messageViewControllerArrayController setFilterPredicate:[[messageViewInfo predicate] copy]];
    [messageTableViewController reloadTableView];
    [messageTableViewController setKnobPosition:[messageViewInfo knobPosition]];
}

- (void) applyCurrentPredicate {
    [messageViewControllerArrayController setFilterPredicate:[[[_messageViewInfoArray objectAtIndex:_currentViewIndex] predicate] copy]];
}
     
@end
