# JCSocketConnection
对CocoaAsyncSocket进行二次封装&amp;三次封装，做了数据的封包&amp;黏包等处理，提供两种block和delegate调用方式，详见代码。

# 注意
ip 和 port号修改成自己的。代码中标注TODO的地方需要自己去实现或修改，全局搜索下即可

# 使用方法一

此方法在方法二上做了进一步的封装，代码简洁、易读、方便

```

/** block方式 */
- (void)blockRequest {
    NSDictionary *dicReq = @{@"mobile":@"13666666666",
                             @"password":@"123456"};
    [[SocketHelper sharedInstance] writeData:dicReq tag:PDA_LOGIN dialogMsg:@"" success:^(NSDictionary *dic) {
        
    } fail:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
}

```

# 使用方法二

声明SocketConnection对象，实现SocketConnectionDelegate代理

```
@interface ViewController ()<SocketConnectionDelegate> {
    SocketConnection *connection;
}

@end

```

发起交易，实现代理方法

```

/** delegate方式 */
- (void)delegateRequest {
    [self openConnection];
    NSDictionary *dicReq = @{@"mobile":@"13666666666",
                             @"password":@"123456"};
    NSData *dataReq = [SocketTool getRequestData:dicReq FuncNo:PDA_LOGIN];
    [connection writeData:dataReq tag:PDA_LOGIN.intValue dialogMsg:nil];
}


#pragma mark SocketConnectionDelegate

- (void)didDisconnectWithError:(NSError *)error {
    NSLog(@"didDisconnectWithError...");
    [self closeConnection];
}

- (void)didReceiveErrorData:(NSDictionary *)dic tag:(long)tag {
    NSLog(@"didReceiveErrorData...");
    [self closeConnection];
}

- (void)didReceiveData:(NSDictionary *)dic tag:(long)tag {
    NSLog(@"didReceiveData...");
    [self closeConnection];
    if (tag == PDA_LOGIN.intValue) {
        
    }
}

#pragma mark RHSocketConnection method

- (void)openConnection {
    connection = [[SocketConnection alloc] init];
    connection.delegate = self;
//    [connection connectWithHost:<#(NSString *)#> port:<#(int)#>];
    [connection connectWithHost];// 不传参数会使用内存中的数据
}

- (void)closeConnection {
    if (connection) {
        connection.delegate = nil;
        [connection disconnect];
        connection = nil;
    }
}

@end

```
