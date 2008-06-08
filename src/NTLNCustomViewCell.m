#import "NTLNCustomViewCell.h"

@implementation NTLNCustomViewCell

- (void) addView:(NSView*)view {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    if (_view) {
//        [_view removeFromSuperview];
//        [_view release];
//    }
    _view = view;
//    [_view retain];
}

- (void) dealloc {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    [_view release];
    [super dealloc];
}

- (void)setObjectValue:(id < NSCopying >)object {
    
}

- (id)objectValue {
    return _view;
}

//- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
//    
//}masu 

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//    NSLog(@"x: %.1f, y:%.1f, w:%.1f, h:%.1f", cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
    [super drawWithFrame:cellFrame inView:controlView];
    [_view setFrame:cellFrame];
    if ([_view superview] != controlView) {
        [controlView addSubview:_view];
    }
}

//- (NSBackgroundStyle)backgroundStyle {
//    return 4;
//}

//- (void)setHighlighted:(BOOL)flag {
//    NSLog(@"CustomViewCell#setHighlighted:%d", flag);
//    [super setHighlighted:flag];
//    if (flag) {
//        [_view highlight];
//    } else {
//        [_view lowlight];
//    }
//}

//- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//    NSLog(@"CustomViewCell#highlight:withFrame:inView");
//    if (flag) {
//        [_view highlight];
//    } else {
//        [_view lowlight];
//    }
//}

@end
