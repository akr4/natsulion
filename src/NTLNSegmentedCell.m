#import "NTLNSegmentedCell.h"


@implementation NTLNSegmentedCell

#pragma mark initialization
- (id) init {
    [super init];
    _normalImageArray = [[NSMutableArray alloc] initWithCapacity:10];
    _highlightedImageArray = [[NSMutableArray alloc] initWithCapacity:10];
    return self;
}

- (void) dealloc {
    [_normalImageArray release];
    [_highlightedImageArray release];
    [super dealloc];
}

#pragma mark overridden methods
- (void)setSelectedSegment:(NSInteger)selectedSegment {
    int s = [self selectedSegment] == -1 ? 0 : [self selectedSegment];
    [super setImage:[_normalImageArray objectAtIndex:s] forSegment:s];
    [super setSelectedSegment:selectedSegment];
    [super setImage:[_highlightedImageArray objectAtIndex:selectedSegment] forSegment:selectedSegment];
}

- (void)setImage:(NSImage *)image forSegment:(NSInteger)segment {
    [_normalImageArray insertObject:image atIndex:segment];
    [super setImage:image forSegment:segment];
}

#pragma mark public methods
- (void)setHighlightedImage:(NSImage*)image forSegment:(NSInteger)segment {
    [_highlightedImageArray insertObject:image atIndex:segment];
}

@end
