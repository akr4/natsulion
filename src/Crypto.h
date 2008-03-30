// Thanks Namakemono!
// http://blog.livedoor.jp/faulist/archives/713437.html
#import <openssl/md5.h>
#import <openssl/sha.h>
#import <openssl/evp.h>
#import <openssl/bio.h>
#import <openssl/buffer.h>

#import <Foundation/Foundation.h>

@interface NSString (Crypto)

- (NSData *)dataHashedWithSHA1;
- (NSString *)stringHexHashedWithSHA1;
- (NSString *)stringEncodedWithBase64;

@end

@interface NSData (Crypto)

+ (NSData *)dataWithBase64String:(NSString *)pstrBase64;
- (NSData *)dataHashedWithSHA1;
- (NSString *)stringHexHashedWithSHA1;
- (NSString *)stringEncodedWithBase64;

@end