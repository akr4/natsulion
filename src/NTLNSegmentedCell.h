#import <Cocoa/Cocoa.h>


@interface NTLNSegmentedCell : NSSegmentedCell {
    NSMutableArray *_normalImageArray;
    NSMutableArray *_highlightedImageArray;
}

- (void)setHighlightedImage:(NSImage*)image forSegment:(NSInteger)segment;

@end
