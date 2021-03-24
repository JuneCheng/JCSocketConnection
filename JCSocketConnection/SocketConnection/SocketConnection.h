//
//  SocketConnection.h
//  MobileCMS3
//
//  Created by JuneCheng on 17/3/8.
//  Copyright © 2017年 zjhcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol SocketConnectionDelegate <NSObject>

@optional

- (void)didDisconnectWithError:(NSError *)error;
- (void)didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)didReceiveErrorData:(NSDictionary *)dic tag:(long)tag;
- (void)didReceiveData:(NSDictionary *)dic tag:(long)tag;

@end

@interface SocketConnection : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@property (nonatomic, weak) id<SocketConnectionDelegate> delegate;

- (void)connectWithHost:(NSString *)hostName port:(int)port;
- (void)connectWithHost;
- (void)disconnect;
- (BOOL)isConnected;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data tag:(long)tag;
- (void)writeData:(NSData *)data tag:(long)tag dialogMsg:(NSString *)message;

@end
