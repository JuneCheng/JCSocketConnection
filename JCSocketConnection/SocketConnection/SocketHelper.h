//
//  SocketHelper.h
//  MobileCMS3
//
//  Created by JuneCheng on 2020/12/10.
//  Copyright © 2020 zjhcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SocketSuccessBlock)(NSDictionary *dic);
typedef void (^SocketFailBlock)(NSDictionary *dic);
typedef void (^SocketErrorBlock)(NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface SocketHelper : NSObject

+ (instancetype)sharedInstance;

/**
 * 用于登录成功后的交易，host port使用登录返回的值，进程框提示文本为@""
 *
 * @param dicReq   请求字典
 * @param tag      交易号
 * @param success  交易成功回调
 * @param fail     交易失败回调
 */
- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail;

/**
 * 用于登录成功后的交易，host port使用登录返回的值
 *
 * @param dicReq   请求字典
 * @param tag      交易号
 * @param message  进程框提示文本
 * @param success  交易成功回调
 * @param fail     交易失败回调
 */
- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail;

/**
 * 用于登录成功后的交易，host port使用登录返回的值
 *
 * @param dicReq   请求字典
 * @param tag      交易号
 * @param message  进程框提示文本
 * @param success  交易成功回调
 * @param fail     交易失败回调
 * @param error    连接失败回调
 */
- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail error:(SocketErrorBlock)error;

/**
 * 用于登录交易
 *
 * @param dicReq   请求字典
 * @param tag      交易号
 * @param message  进程框提示文本
 * @param hostName 服务器地址
 * @param port     端口号
 * @param success  交易成功回调
 * @param fail     交易失败回调
 * @param error    连接失败回调
 */
- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message host:(NSString *)hostName port:(int)port success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail error:(SocketErrorBlock)error;

@end

NS_ASSUME_NONNULL_END
