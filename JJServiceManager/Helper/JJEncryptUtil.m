
#import "JJEncryptUtil.h"
#import "JJBase64.h"

#import "CommonCrypto/CommonCryptor.h"
#import "CommonCrypto/CommonDigest.h"
#import <Security/Security.h>

#define kChosenDigestLength     CC_SHA1_DIGEST_LENGTH
#define kYZTgIv @"1234567812345678"

@implementation JJEncryptUtil

const Byte yztIv[] = {1, 2, 3, 4, 5, 6, 7, 8};

+ (NSString *)encryptUseDES:(NSData *)plainText key:(NSString *)key
{
    if (plainText.length == 0) {
        return nil;
    }
    NSUInteger bufferSize = [plainText length] + 40;
    NSString *ciphertext = nil;
    NSData *textData = plainText;//[plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    
    unsigned char *buffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    //unsigned char buffer[bufferSize];
    memset(buffer, 0, sizeof(unsigned char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          yztIv,
                                          [textData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [JJBase64 encode:data];
    }
    
    //
    if(buffer){
        free(buffer);
    }
    
    return ciphertext;
}

+ (NSString *)encryptServerDES:(NSData *)plainText key:(NSString *)key
{
    if (plainText.length == 0) {
        return nil;
    }
    NSUInteger bufferSize = [plainText length] + 40;
    NSString *ciphertext = nil;
    NSData *textData = plainText;//[plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    
    unsigned char *buffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    //unsigned char buffer[bufferSize];
    memset(buffer, 0, sizeof(unsigned char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          yztIv,
                                          [textData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [JJBase64 encode:data];
    }
    
    //
    if(buffer){
        free(buffer);
    }
    
    return ciphertext;
}

+ (NSData *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
{
    if (cipherText.length == 0) {
        return nil;
    }
    NSData *plaindata = nil;
    NSData *cipherdata = [JJBase64 decode:cipherText];
    NSUInteger bufferSize = [cipherdata length] + 4;
    
    unsigned char *buffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    
//    unsigned char buffer[bufferSize];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          yztIv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
    }
    
    if(buffer){
        free(buffer);
    }
    
    return plaindata;
}

+ (NSData *)decryptServerDES:(NSString *)cipherText key:(NSString *)key
{
    if (cipherText.length == 0) {
        return nil;
    }
    NSData *plaindata = nil;
    NSData *cipherdata = [JJBase64 decode:cipherText];
    NSUInteger bufferSize = [cipherdata length] + 4;
    
    unsigned char *buffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    
    //    unsigned char buffer[bufferSize];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          yztIv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
    }
    
    if(buffer){
        free(buffer);
    }
    
    return plaindata;
}

+ (NSString *)encryptUse3DES:(NSData *)data key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [data length];
    vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    return ccStatus == kCCSuccess ? [JJBase64 encode:myData] : nil;
}

+ (NSData *)decryptUse3DES:(NSString *)cipherText key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    NSData *EncryptData = [JJBase64 decode:cipherText];
    plainTextBufferSize = [EncryptData length];
    vplainText = [EncryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    return ccStatus == kCCSuccess ? [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] : nil;
}

+ (NSString *)parseByte2HexString:(Byte *) bytes
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    return hexStr;
}

+ (NSString *)parseByteArray2HexString:(Byte[]) bytes
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    return hexStr;
}



+(NSData *)encryptuseAES:(NSString *)plainText withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [kYZTgIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    long newSize = 1;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x20;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          0x0000,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        
        return resultData;
        //return [AdrInterface_Crypt Encode_JJBase64_NSDataToNSString:resultData];
    }
    free(buffer);
    return nil;
}

+(NSString *)decryptuseAES:(NSString *)encryptStr withKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [kYZTgIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data;
    data = [[NSData alloc]initWithBase64EncodedString:encryptStr options:0];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

+(NSString *)getCacheDesKey
{
    //@"(7Bg[#KjbmSegR/#"
    NSString *_r = @"";
    
    Byte _bList[16];
    
    _bList[0] = 255 - '(';
    _bList[1]=  255 - '7';
    _bList[2]=  255 - 'B';
    _bList[3]=  255 - 'g';
    
    _bList[4] = 255 - '[';
    _bList[5]=  255 - '#';
    _bList[6]=  255 - 'K';
    _bList[7]=  255 - 'j';
    
    _bList[8] = 255 - 'b';
    _bList[9]=  255 - 'm';
    _bList[10]=  255 - 'S';
    _bList[11]=  255 - 'e';
    
    _bList[12] = 255 - 'g';
    _bList[13]=  255 - 'R';
    _bList[14]=  255 - '/';
    _bList[15]=  255 - '#';
    
    char _a[2];
    for (int i = 0; i < 16; i++) {
        _a[0] = 255 - _bList[i];
        _a[1] = '\0';
        _r =  [_r stringByAppendingString:[NSString stringWithCString:_a encoding:NSASCIIStringEncoding]]  ;
        
    }
    
    return _r;
}

@end
