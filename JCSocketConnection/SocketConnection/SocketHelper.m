//
//  SocketHelper.m
//  MobileCMS3
//
//  Created by JuneCheng on 2020/12/10.
//  Copyright © 2020 zjhcsoft. All rights reserved.
//

#import "SocketHelper.h"
#import "SocketTool.h"
#import "SocketConnection.h"

@interface SocketHelper ()<SocketConnectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *connectionDict;///<
@property (nonatomic, strong) NSMutableDictionary *successBlockDict;///<
@property (nonatomic, strong) NSMutableDictionary *failBlockDict;///<
@property (nonatomic, strong) NSMutableDictionary *errorBlockDict;///<

@end

@implementation SocketHelper

+ (instancetype)sharedInstance {
    static SocketHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SocketHelper alloc] init];
        _sharedInstance.connectionDict = [NSMutableDictionary dictionary];
        _sharedInstance.successBlockDict = [NSMutableDictionary dictionary];
        _sharedInstance.failBlockDict = [NSMutableDictionary dictionary];
        _sharedInstance.errorBlockDict = [NSMutableDictionary dictionary];
    });
    return _sharedInstance;
}

- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail {
    [self writeData:dicReq tag:tag dialogMsg:@"" success:success fail:fail];
}

- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail {
    [self writeData:dicReq tag:tag dialogMsg:message host:@"" port:0 success:success fail:fail error:^(NSError *error){}];
}

- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail error:(SocketErrorBlock)error {
    [self writeData:dicReq tag:tag dialogMsg:message host:@"" port:0 success:success fail:fail error:error];
}

- (void)writeData:(NSDictionary *)dicReq tag:(NSString *)tag dialogMsg:(nullable NSString *)message host:(NSString *)hostName port:(int)port success:(SocketSuccessBlock)success fail:(SocketFailBlock)fail error:(SocketErrorBlock)error {
    // 1.上传参数处理并转换成数据流
    NSData *dataReq = [SocketTool getRequestData:dicReq FuncNo:tag];
    // 2.创建交易对象并连接
    SocketConnection *connection = [[SocketConnection alloc] init];
    connection.delegate = self;
    if (hostName.length > 0 && port > 0) {
        [connection connectWithHost:hostName port:port];
    } else {
        [connection connectWithHost];
    }
    // 3.记录交易对应的连接，先记录再发起交易writeData，否则影响mock数据展示
    self.connectionDict[@(tag.intValue)] = connection;
    if (success) self.successBlockDict[@(tag.intValue)] = success;
    if (fail) self.failBlockDict[@(tag.intValue)] = fail;
    if (error) self.errorBlockDict[@(tag.intValue)] = error;
    // 4.发起交易
    [connection writeData:dataReq tag:tag.intValue dialogMsg:message];
}

#pragma mark SocketConnectionDelegate method socket方法重写

- (void)didDisconnectWithError:(NSError *)error {
    NSLog(@"didDisconnectWithError");
    // 连接失败，关闭所有的连接
    for (int i = 0; i < self.connectionDict.allKeys.count; i ++) {
        NSString *tag = self.connectionDict.allKeys[i];
        SocketErrorBlock errorBlock = self.errorBlockDict[@(tag.intValue)];
        [self closeConnection:tag.intValue];
        if (errorBlock) {
            errorBlock(error);
        }
    }
}

- (void)didReceiveErrorData:(NSDictionary *)dic tag:(long)tag {
    NSLog(@"didReceiveErrorData...");
    SocketFailBlock failBlock = self.failBlockDict[@(tag)];
    [self closeConnection:tag];
    if (failBlock) {
        failBlock(dic);
    }
}

- (void)didReceiveData:(NSDictionary *)dic tag:(long)tag {
    NSLog(@"didReceiveData...");
    SocketSuccessBlock successBlock = self.successBlockDict[@(tag)];
    [self closeConnection:tag];
    if (successBlock) {
        successBlock(dic);
    }
}

#pragma mark RHSocketConnection method

- (void)closeConnection:(long)tag {
    SocketConnection *connection = (SocketConnection *)self.connectionDict[@(tag)];
    if (connection) {
        connection.delegate = nil;
        [connection disconnect];
        connection = nil;
    }
    [self.connectionDict removeObjectForKey:@(tag)];
    [self.successBlockDict removeObjectForKey:@(tag)];
    [self.failBlockDict removeObjectForKey:@(tag)];
    [self.errorBlockDict removeObjectForKey:@(tag)];
}

@end
