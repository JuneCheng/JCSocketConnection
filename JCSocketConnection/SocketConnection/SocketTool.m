//
//  SocketTool.m
//  MobileCMS3
//
//  Created by JuneCheng on 2017/3/8.
//  Copyright © 2017年 zjhcsoft. All rights reserved.
//

#import "SocketTool.h"
@implementation SocketTool

#pragma mark 请求数据处理

+ (NSData *)getRequestData:(NSDictionary *)dicReq FuncNo:(NSString *)funcNo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dicReq];
    // 2.设置funcNo
    [dic setValue:funcNo forKey:@"functionno"];
    
    // TODO 字典 -> String 根据自己项目数据格式进行转换，转换成xml格式 || json格式
//    NSString *strReq = [dic XMLString];// 使用XMLDictionary
//    NSString *strReq = [mj_JSONString];// 使用MJExtension
    NSString *strReq = @"{@\"mobile\":@\"13666672771\",@\"password\":@\"123456\"}";
    NSString *logHeadTitle = [NSString stringWithFormat:@"%@ 请求报文", funcNo];
    LINEAROUND(logHeadTitle, strReq)
    // TODO 如果数据需要加密，自己实现
//    NSString *reqStringEncry = [DESTool encryptUseDES:strReq key:encryKey];
    NSString *reqStringEncry = strReq;
    NSMutableData *data = [[NSMutableData alloc] init];
    // 前4个字节为请求报文的长度
    [data appendData:[self intToBytes:[reqStringEncry lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
    [data appendData:[reqStringEncry dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

+ (NSData *)intToBytes:(NSInteger)value {
    Byte b1=value & 0xff;
    Byte b2=(value>>8) & 0xff;
    Byte b3=(value>>16) & 0xff;
    Byte b4=(value>>24) & 0xff;
    Byte byte[] = {b1,b2,b3,b4};
    NSData *lengthData = [NSData dataWithBytes:byte length:sizeof(byte)];
    return lengthData;
}

@end
