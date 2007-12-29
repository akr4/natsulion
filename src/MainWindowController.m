#import "MainWindowController.h"
#import "PreferencesWindow.h"

#import "TwitterStatusViewController.h"
#import "TwitterStatus.h"

@implementation MainWindowController

- (id) init {
    NSLog(@"MainWindowController#init");
    [mainWindow setFrameAutosaveName:@"MainWindow"];
    
    _messageViewControllerArray = [[NSMutableArray alloc] initWithCapacity:100];
    _twitter = [[Twitter alloc] init];
    _messageTextFieldRow = 1;    
    
    [[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateStatus) userInfo:nil repeats:YES] fire];

    return self;
}

- (void) dealloc {
    [_messageViewControllerArray release];
    [_twitter release];
    [_growl release];
    [super dealloc];
}

- (void) awakeFromNib {
    NSLog(@"MainWindowController#awakeFromNib");
    [mainWindow setReleasedWhenClosed:FALSE];
    
    [messageTextField setCallback:self];
    
//    [messageViewArrayController setSortDescriptors:
//        [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"status.timestamp" ascending:TRUE] autorelease]]];
//    [messageViewArrayController setAutomaticallyRearrangesObjects:TRUE];    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"applicationDidFinishLaunching");
    [mainWindow setFrameAutosaveName:@"MainWindow"];
}

- (void) sendToGrowlTitle:(NSString*)title
           andDescription:(NSString*)description
                  andIcon:(NSData*)iconData 
              andPriority:(int)priority
                andSticky:(BOOL)sticky {
    if (!_growl) {
        _growl = [[GrowlNotifier alloc] init];
    }
    
    [_growl sendToGrowlTitle:title
              andDescription:description
                     andIcon:iconData
                 andPriority:priority
                   andSticky:sticky];
}

- (BOOL) isNewMessage:(Message*)message {
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc] initWithTwitterStatus:(TwitterStatus*)message] autorelease];
    
    if ([_messageViewControllerArray containsObject:newController]) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (void) addIfNewMessage:(Message*)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);    
    TwitterStatusViewController *newController = [[[TwitterStatusViewController alloc] initWithTwitterStatus:(TwitterStatus*)message] autorelease];
    
    if ([_messageViewControllerArray containsObject:newController]) {
        return;
    }
    
    int i;
    for (i = 0; i < [_messageViewControllerArray count]; i++) {
        Message *messageInArray = [(TwitterStatusViewController*)[_messageViewControllerArray objectAtIndex:i] status];
        
        if ([(NSDate*)[messageInArray timestamp] compare:[message timestamp]] == NSOrderedAscending) {
            [_messageViewControllerArray insertObject:newController atIndex:i];
            return;
        }
    }
    [_messageViewControllerArray addObject:newController];
    
    [messageTableViewController updateSelection];
}

- (NSArray*) messageViewControllerArray {
    return _messageViewControllerArray;
}

- (void) updateStatus {
    NSLog(@"MainWindowController#updateStatus");
    [_twitter friendTimelineWithCallback:self];
}

- (IBAction) sendMessage:(id) sender {    
    [messageTextField setEnabled:FALSE];
    [_twitter sendMessage:[messageTextField stringValue] withCallback:self];
}

//- (float) heightForString:(NSString*)myString andFont:(NSFont*)myFont andWidth:(float)myWidth {
//    NSTextStorage *textStorage = [[[NSTextStorage alloc]
//                                   initWithString:myString] autorelease];
//    NSTextContainer *textContainer = [[[NSTextContainer alloc]
//                                       initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] autorelease];
//    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]
//                                      autorelease];
//    [layoutManager addTextContainer:textContainer];
//    [textStorage addLayoutManager:layoutManager];
//    [textStorage addAttribute:NSFontAttributeName value:myFont
//                        range:NSMakeRange(0, [textStorage length])];
//    [textContainer setLineFragmentPadding:0.0];
//    (void) [layoutManager glyphRangeForTextContainer:textContainer];
//    return [layoutManager
//            usedRectForTextContainer:textContainer].size.height;
//}


// TwitterPostCallback methods ///////////////////////////////////////////////////
- (void) finishedToPost {
    [messageTextField setStringValue:@""];
    [messageTextField setEditable:TRUE];
    [messageTextField setEnabled:TRUE];
}


// TimelineCallback methods ///////////////////////////////////////////////////////
- (void) finishedToGetTimeline:(NSArray*)statuses {
    int i;
    for (i = 0; i < [statuses count]; i++) {
        TwitterStatus *s = [statuses objectAtIndex:i];
        if ([self isNewMessage:s]) {
            [self addIfNewMessage:s];
            int priority = 0;
            BOOL sticky = FALSE;
            switch ([s replyType]) {
                case MESSAGE_REPLY_TYPE_REPLY:
                    priority = 2;
                    sticky = TRUE;
                    break;
                case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
                    priority = 1;
                    sticky = TRUE;
                    break;
                default:
                    break;
            }
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_USE_GROWL]) {
                [self sendToGrowlTitle:[s name]
                        andDescription:[s text]
                               andIcon:[[s icon] TIFFRepresentation]
                           andPriority:priority
                             andSticky:sticky];
            }
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_SHOW_WINDOW_WHEN_NEW_MESSAGE]) {
                [mainWindow makeKeyAndOrderFront:nil];
            }
        }
    }
 
    [messageTableViewController reloadTableView];
}

- (void) started {
    [downloadProgress startAnimation:self];
}

- (void) stopped {
    [downloadProgress stopAnimation:self];
}


// NSApplicatoin delegate /////////////////////////////////////////////////////////////////
// TODO: this class should not be a delegate of NSApplication

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication {
    NSLog(@"%s", __PRETTY_FUNCTION__);    
    [mainWindow makeKeyAndOrderFront:nil];
    return TRUE;
}

// AutoResizingTextField callback ///////////////////////////////////////////////////////
- (void) autoResizingTextFieldResized:(float)heightDelta {
    [messageTableViewController resize:heightDelta];
}

@end
