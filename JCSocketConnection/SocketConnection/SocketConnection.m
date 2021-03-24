//
//  SocketConnection.m
//  MobileCMS3
//
//  Created by JuneCheng on 17/3/8.
//  Copyright © 2017年 zjhcsoft. All rights reserved.
//

#import "SocketConnection.h"
#import "SocketTool.h"
//#import "MBProgressHUD+MJ.h"

@interface SocketConnection() {
    NSTimeInterval readTimeOut;
}

@property (nonatomic, strong) NSMutableData *buff;
@property (nonatomic, assign) int totalLength;

@end


@implementation SocketConnection

- (instancetype)init
{
    if (self = [super init]) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        readTimeOut = OVERTIME.intValue;
    }
    return self;
}

- (void)dealloc {
    _socket.delegate = nil;
    _socket = nil;
}

- (void)connectWithHost:(NSString *)hostName port:(int)port {
    NSLog(@"ip: %@  port: %d", hostName, port);
    NSError *error = nil;
    [_socket connectToHost:hostName onPort:port withTimeout:3 error:&error];
    if (error) {
        NSLog(@"[SocketConnection] connectWithHost error: %@", error.description);
        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
            [_delegate didDisconnectWithError:error];
        }
    }
}

/** TODO 不传入ip & port，直接使用内存中的数据，本demo中直接写死，自己根据业务修改 */
- (void)connectWithHost {
    [self connectWithHost:SERVER_IP port:SERVER_PORT.intValue];
}

- (void)disconnect {
    [_socket disconnect];
}

- (BOOL)isConnected {
    return [_socket isConnected];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    [_socket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data tag:(long)tag {
    [self writeData:data tag:tag dialogMsg:@""];
}

- (void)writeData:(NSData *)data tag:(long)tag dialogMsg:(NSString *)message {
    if (message) {
//        [MBProgressHUD showMessage:message];
    }
    
    [_socket writeData:data withTimeout:readTimeOut tag:tag];
}

#pragma mark GCDAsyncSocketDelegate method

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectToHost:port:)]) {
        [_delegate didConnectToHost:host port:port];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@"socketDidDisconnect-->%@",err);
//        [MBProgressHUD hideHUD];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
            [_delegate didDisconnectWithError:err];
        }
        NSLog(@"socketDidDisconnect--->%@",err.localizedFailureReason);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataWithTimeout:readTimeOut tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
    if (_totalLength == 0) {
        NSData *lengthData = [data subdataWithRange:NSMakeRange(0, 4)];// 截取前4个字节
        [lengthData getBytes:&_totalLength length:sizeof(_totalLength)];
    }
    [self.buff appendData:data];
    // 如果buff长度小于总长度+4，说明数据没接收完，继续接收。接收完后开始解析数据
    // 注意：前4个字节的长度一定要算上，否则某些交易会导致响应报文接收不全！！！
    if (self.buff.length < _totalLength + 4) {
        [sock readDataWithTimeout:readTimeOut tag:tag];
    } else {
        // 取报文数据并解析
        NSData *xmlData = [self.buff subdataWithRange:NSMakeRange(4, _totalLength)];
        NSString *messageEncry = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        // TODO 如果数据加密，需要解密，自己实现
//        NSString *message = [DESTool decryptUseDES:messageEncry key:encryKey];
        NSString *message = messageEncry;
        
        NSString *funcNo = tag > 999 ? [NSString stringWithFormat:@"%ld", tag] : [NSString stringWithFormat:@"0%ld", tag];
        NSString *logHeadTitle = [NSString stringWithFormat:@"%@ 响应报文", funcNo];
        LINEAROUND(logHeadTitle, message)
        
        // TODO 字符串 -> 字典 转换过程，自己实现
//        NSDictionary *resultDic = [NSDictionary dictionaryWithXMLString:message];
        NSDictionary *resultDic = @{@"result":@"ok",@"message":@"请求成功啦~~~"};
        
        // result = ok
        if ([resultDic[@"result"] isEqualToString:@"ok"]) {
            if (_delegate && [_delegate respondsToSelector:@selector(didReceiveData:tag:)]) {
                [_delegate didReceiveData:resultDic tag:tag];
            }
        } else { // result = ERROR
            NSLog(@"errorinfo--->%@",resultDic[@"errorinfo"]);
            
            if (_delegate && [_delegate respondsToSelector:@selector(didReceiveErrorData:tag:)]) {
                [_delegate didReceiveErrorData:resultDic tag:tag];
            }
        }
        self.buff = nil;
        _totalLength = 0;
    }
}

- (NSMutableData *)buff {
    if (!_buff) {
        _buff = [[NSMutableData alloc] init];
    }
    return _buff;
}

@end
