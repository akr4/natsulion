// Thanks Namakemono!
// http://blog.livedoor.jp/faulist/archives/713437.html

#import "Crypto.h"

@implementation NSString (Crypto)

- (NSData *)dataHashedWithSHA1
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] dataHashedWithSHA1];
}

- (NSString *)stringHexHashedWithSHA1
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] stringHexHashedWithSHA1];
}

- (NSString *)stringEncodedWithBase64
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] stringEncodedWithBase64];
}

@end

@implementation NSData (Crypto)

- (NSString *)stringHexHashedWithSHA1
{
	unsigned char digest[20];
	char finaldigest[40];
	int i;
	
	SHA1([self bytes],[self length],digest);
	for(i=0;i<20;i++) sprintf(finaldigest+i*2,"%02x",digest[i]);
	
	return [NSString stringWithCString:finaldigest length:40];
}

- (NSData *)dataHashedWithSHA1
{
	unsigned char digest[20];
	
	SHA1([self bytes],[self length],digest);
	
	return [NSData dataWithBytes:&digest length:20];
}

+ (NSData *)dataWithBase64String:(NSString *)aString
{
	BIO *b64, *bmem;
	int length = [aString lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
    
	char *buffer = (char *)malloc(length);
	memset(buffer, 0, length);
	b64 = BIO_new(BIO_f_base64());
	bmem = BIO_new_mem_buf((char *)[aString cStringUsingEncoding:NSASCIIStringEncoding], length);
	bmem = BIO_push(b64, bmem);
    
	BIO_read(bmem, buffer, length);
	BIO_free_all(bmem);
	
	return [NSData dataWithBytes:buffer length:length];
}

- (NSString *)stringEncodedWithBase64
{
	BIO *bmem, *b64;
	BUF_MEM *bptr;
	
	b64 = BIO_new(BIO_f_base64());
	bmem = BIO_new(BIO_s_mem());
	b64 = BIO_push(b64, bmem);
	BIO_write(b64, [self bytes], [self length]);
	BIO_flush(b64);
	BIO_get_mem_ptr(b64, &bptr);
    
	NSString *buff = [NSString stringWithCString:bptr->data length:bptr->length-1];
	BIO_free_all(b64);
	
	return buff;
}

@end