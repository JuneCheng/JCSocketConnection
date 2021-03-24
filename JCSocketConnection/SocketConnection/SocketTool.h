//
//  SocketTool.h
//  MobileCMS3
//
//  Created by JuneCheng on 2017/3/8.
//  Copyright © 2017年 zjhcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

// 查看一段变量，用分隔符包起来
#define lineBreak @"-------------------------------"
#define LINEAROUND(title, message) NSLog(@"\n%@ %@ %@\n\n%@\n\n-------------%@%@",lineBreak,title,lineBreak,message,lineBreak,lineBreak);

static NSString * const SERVER_IP = @"218.205.57.111";
static NSString * const SERVER_PORT = @"1111";
static NSString * const OVERTIME = @"30";

#define PDA_LOGIN @"0101" // 登录

@interface SocketTool : NSObject

+ (NSData *)getRequestData:(NSDictionary *)dicReq FuncNo:(NSString *)funcNo;

+ (NSData *)intToBytes:(NSInteger)value;

@end
