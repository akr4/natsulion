#import "XMLHTTPEncoderTest.h"
#import "XMLHTTPEncoder.h"

@implementation XMLHTTPEncoderTest

- (void) testGtDecode {
    NSString *INPUT = @"hello,&gt;world";
    NSString *OUTPUT = @"hello,>world";
    STAssertEqualObjects([[XMLHTTPEncoder encoder] decodeXML:INPUT], OUTPUT, nil);
}

- (void) testLtDecode {
    NSString *INPUT = @"hello,&lt;world";
    NSString *OUTPUT= @"hello,<world";
    STAssertEqualObjects([[XMLHTTPEncoder encoder] decodeXML:INPUT], OUTPUT, nil);
}

- (void) testLtAndGtDecode {
    NSString *INPUT = @"hello,&lt;&amp;world&gt;";
    NSString *OUTPUT = @"hello,<&world>";
    STAssertEqualObjects([[XMLHTTPEncoder encoder] decodeXML:INPUT], OUTPUT, nil);
}

- (void) testEncode {
    NSString *INPUT = @"hello,<+&?\" >world";
    NSString *OUTPUT = @"hello,%3C%2B%26%3F%22%20%3Eworld";
    STAssertEqualObjects([[XMLHTTPEncoder encoder] encodeHTTP:INPUT], OUTPUT, nil);
}

@end
