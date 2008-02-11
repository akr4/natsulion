#import <Cocoa/Cocoa.h>
#import "NTLNMessageTableViewController.h"

@interface NTLNMessageListViewsController : NSObject {
    IBOutlet NSArrayController *messageViewControllerArrayController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    
    NSMutableArray *_messageViewInfoArray;
    int _currentViewIndex;
}
- (id) init;
//- (void) addInfoWithPredicate:(NSPredicate*)predicate;
- (IBAction) changeViewByToolbar:(id) sender;
- (IBAction) changeViewByMenu:(id) sender;
- (void) applyCurrentPredicate;
@end
