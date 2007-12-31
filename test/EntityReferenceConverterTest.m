#import "EntityReferenceConverterTest.h"
#import "EntityReferenceConverter.h"

@implementation EntityReferenceConverterTest

- (void) testGt {
    NSString *INPUT = @"hello,&gt;world";
    EntityReferenceConverter *converter = [[EntityReferenceConverter alloc] init];
    STAssertEqualObjects([converter dereference:INPUT], @"hello,>world", nil);
}

- (void) testLt {
    NSString *INPUT = @"hello,&lt;world";
    EntityReferenceConverter *converter = [[EntityReferenceConverter alloc] init];
    STAssertEqualObjects([converter dereference:INPUT], @"hello,<world", nil);
}

- (void) testMultiReferences {
    NSString *INPUT = @"hello,&lt;world&gt;";
    EntityReferenceConverter *converter = [[EntityReferenceConverter alloc] init];
    STAssertEqualObjects([converter dereference:INPUT], @"hello,<world>", nil);
}

@end
