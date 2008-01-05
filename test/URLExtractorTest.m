#import "URLExtractorTest.h"
#import "URLExtractor.h"

@implementation URLExtractorTest

- (void) testURL1 {
    NSString *INPUT = @"hello http://www.physalis.net world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)3, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.physalis.net", nil);
    STAssertEqualObjects([results objectAtIndex:2], @" world", @"[%@]", nil);
}

- (void) testURL2 {
    NSString *INPUT = @"hello http://www.physalis.net abc http://www.yahoo.co.jp world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)5, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.physalis.net", nil);
    STAssertEqualObjects([results objectAtIndex:2], @" abc ", nil);
    STAssertEqualObjects([results objectAtIndex:3], @"http://www.yahoo.co.jp", nil);
    STAssertEqualObjects([results objectAtIndex:4], @" world", nil);
}

- (void) testStartsWithURL {
    NSString *INPUT = @"http://www.physalis.net world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)2, nil);
    STAssertEqualObjects([results objectAtIndex:0], @"http://www.physalis.net", nil);
    STAssertEqualObjects([results objectAtIndex:1], @" world", nil);
}

- (void) testEndsWithURL {
    NSString *INPUT = @"hello http://www.physalis.net";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)2, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.physalis.net", nil);
}

- (void) testSign {
    NSString *INPUT = @"hello http://www.physalis.net/ss?wicket:interface=:152:leftPanel:leftPanel-3:tag:22:link::ILinkListener world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)3, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.physalis.net/ss?wicket:interface=:152:leftPanel:leftPanel-3:tag:22:link::ILinkListener", nil);
    STAssertEqualObjects([results objectAtIndex:2], @" world", @"[%@]", nil);
}

- (void) testJapaneseCharacters {
    NSString *INPUT = @"hello http://www.physalis.net同じエントリのコメント欄 world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByURL:INPUT];
    STAssertEquals([results count], (NSUInteger)3, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.physalis.net", nil);
    STAssertEqualObjects([results objectAtIndex:2], @"同じエントリのコメント欄 world", @"[%@]", nil);
}

- (void) testID0 {
    NSString *INPUT = @"hello @ world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByID:INPUT];
    STAssertEquals([results count], (NSUInteger)3, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"@", nil);
    STAssertEqualObjects([results objectAtIndex:2], @" world", @"[%@]", nil);
}

- (void) testID1 {
    NSString *INPUT = @"hello @akr world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByID:INPUT];
    STAssertEquals([results count], (NSUInteger)3, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"@akr", nil);
    STAssertEqualObjects([results objectAtIndex:2], @" world", @"[%@]", nil);
}

- (void) testAll1 {
    NSString *INPUT = @"hello http://www.yahoo.com@akr world";
    URLExtractor *extractor = [[URLExtractor alloc] init];
    NSArray *results = [extractor tokenizeByAll:INPUT];
    STAssertEquals([results count], (NSUInteger)4, nil);
    STAssertEqualObjects((NSString*)[results objectAtIndex:0], @"hello ", nil);
    STAssertEqualObjects([results objectAtIndex:1], @"http://www.yahoo.com", nil);
    STAssertEqualObjects([results objectAtIndex:2], @"@akr", nil);
    STAssertEqualObjects([results objectAtIndex:3], @" world", @"[%@]", nil);
}

- (void) testIsWhiteSpace1 {
    STAssertTrue([[URLExtractor extractor] isWhiteSpace:@" "], nil);
    STAssertTrue([[URLExtractor extractor] isWhiteSpace:@"  "], nil);
    STAssertTrue([[URLExtractor extractor] isWhiteSpace:@""], nil);
    STAssertTrue([[URLExtractor extractor] isWhiteSpace:nil], nil);
    STAssertFalse([[URLExtractor extractor] isWhiteSpace:@"a"], nil);
    STAssertFalse([[URLExtractor extractor] isWhiteSpace:@"a "], nil);
    STAssertFalse([[URLExtractor extractor] isWhiteSpace:@" a"], nil);
    STAssertFalse([[URLExtractor extractor] isWhiteSpace:@" a "], nil);
}
@end
