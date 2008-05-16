#import "NTLNMessageListViewsController.h"
#import "NTLNAccount.h"
#import "NTLNConfiguration.h"
#import "TwitterStatusViewController.h"
#import "NTLNNotification.h"

// class holds an information of a message view which can be switched by messageViewSelector.
@interface NTLNMessageViewInfo : NSObject {
    NSPredicate *_predicate;
    float _knobPosition;
    SEL _predicateFactoryMethod;
}
- (id) initWithPredicate:(NSPredicate*)predicate;
- (id) initWithPredicateFactory:(SEL)selector;
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

+ (id) infoWithPredicateFactory:(SEL)selector {
    return [[[[self class] alloc] initWithPredicateFactory:selector] autorelease];
}

- (id) initWithPredicateFactory:(SEL)selector {
    _predicateFactoryMethod = selector;
    return self;
}

- (void) dealloc {
    [_predicate release];
    [super dealloc];
}

- (NSPredicate*)predicateForSentMessages {
    return [NSPredicate predicateWithFormat:@"message.screenName == %@", [[NTLNAccount instance] username]];
}

- (NSPredicate*)predicate {
    if (_predicate) {
        return _predicate;
    }
    return [self performSelector:_predicateFactoryMethod];
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
    
//    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:nil]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:
                                      [NSPredicate predicateWithFormat:@"timestamp > %@",
                                       [NSDate dateWithTimeIntervalSince1970:[[NTLNConfiguration instance] latestTimestampOfMessage]]]]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:
                                      [NSPredicate predicateWithFormat:@"message.replyType IN %@",
                                       [NSArray arrayWithObjects:
                                        [NSNumber numberWithInt:NTLN_MESSAGE_REPLY_TYPE_REPLY],
                                        [NSNumber numberWithInt:NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE],
                                        nil]]]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicateFactory:@selector(predicateForSentMessages)]];
    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:
                                      [NSPredicate predicateWithFormat:@"message.status == 0"]]];
    
    return self;
}

- (void) dealloc {
    [_messageViewInfoArray release];
    [_auxiliaryPredicate release];
    [super dealloc];
}

// not used yet
//- (void) addInfoWithPredicate:(NSPredicate*)predicate {
//    [_messageViewInfoArray addObject:[NTLNMessageViewInfo infoWithPredicate:predicate]];
//}

- (void) changeView:(int)index {
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGING object:nil];
    
    // save status
    [[_messageViewInfoArray objectAtIndex:_currentViewIndex] setKnobPosition:[messageTableViewController knobPosition]];
    
    _currentViewIndex = index;
    // change view
    NTLNMessageViewInfo *messageViewInfo = [_messageViewInfoArray objectAtIndex:_currentViewIndex];
    // to use original one causes an exception
    [messageViewControllerArrayController setFilterPredicate:[[messageViewInfo predicate] copy]];
    [messageTableViewController reloadTableView];
    [messageTableViewController setKnobPosition:[messageViewInfo knobPosition]];

    for (int i = 0; i < [[messageViewControllerArrayController arrangedObjects] count]; i++) {
        TwitterStatusViewController *c = [[messageViewControllerArrayController arrangedObjects] objectAtIndex:i];
        [c exitFromScrollView];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED object:nil];
}

- (IBAction) changeViewByToolbar:(id) sender {
    [self changeView:[sender selectedSegment]];
}

- (IBAction) changeViewByMenu:(id) sender {
    [self changeView:[sender tag]];
}

- (NSPredicate*) currentPredicate {
    return [[[_messageViewInfoArray objectAtIndex:_currentViewIndex] predicate] copy];
}

- (void) applyCurrentPredicate {
    [messageViewControllerArrayController
     setFilterPredicate:[NSCompoundPredicate
                         andPredicateWithSubpredicates:[NSArray arrayWithObjects:[self currentPredicate], _auxiliaryPredicate, nil]]];
}

- (int) currentViewIndex {
    return _currentViewIndex;
}

- (void) addAuxiliaryPredicate:(NSPredicate*) predicate {
    if (_auxiliaryPredicate) {
        [_auxiliaryPredicate release];
    }
    _auxiliaryPredicate = predicate;
    [_auxiliaryPredicate retain];

    [messageViewControllerArrayController setFilterPredicate:
     [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[self currentPredicate], predicate, nil]]]; 
}

- (void) resetAuxiliaryPredicate {
    [_auxiliaryPredicate release];
    _auxiliaryPredicate = nil;
}
     
@end
