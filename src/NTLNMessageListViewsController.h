#import <Cocoa/Cocoa.h>
#import "NTLNMessageTableViewController.h"

@interface NTLNMessageListViewsController : NSObject {
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    
    NSMutableArray *_messageViewInfoArray;
    int _currentViewIndex;
    NSPredicate *_auxiliaryPredicate;
}
- (id) init;
//- (void) addInfoWithPredicate:(NSPredicate*)predicate;
- (IBAction) changeViewByToolbar:(id) sender;
- (IBAction) changeViewByMenu:(id) sender;
- (void) applyCurrentPredicate;
- (int) currentViewIndex;
- (void) addAuxiliaryPredicate:(NSPredicate*) predicate;
- (void) resetAuxiliaryPredicate;
@end
