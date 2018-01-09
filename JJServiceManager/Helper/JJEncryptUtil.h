//
//  EncryptUtil.h
//
//
//  Created by JJ on 15/3/17.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJEncryptUtil : NSObject

// DES加密
+ (NSString *)encryptUseDES:(NSData *)plainText key:(NSString *)key;
// DES加密(可与后端交互)
+ (NSString *)encryptServerDES:(NSData *)plainText key:(NSString *)key;
+ (NSData *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
// DES解密(可与后端交互)
+ (NSData *)decryptServerDES:(NSString *)cipherText key:(NSString *)key;

// 3DES加密
+ (NSString *)encryptUse3DES:(NSData *)plainText key:(NSString *)key;
// 3DES解密
+ (NSData *)decryptUse3DES:(NSString *)cipherText key:(NSString *)key;


// AES加密
+(NSData *)encryptuseAES:(NSString *)plainText withKey:(NSString *)key;
// AES解密
+(NSString *)decryptuseAES:(NSString *)encryptStr withKey:(NSString *)key;

/**
 获取Cashe用des key

 @return des key
 */
+(NSString *)getCacheDesKey;

@end
