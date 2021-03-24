//
//  ViewController.m
//  JCSocketConnection
//
//  Created by JuneCheng on 2021/3/24.
//

#import "ViewController.h"
#import "SocketHelper.h"
#import "SocketConnection.h"
#import "SocketTool.h"

@interface ViewController ()<SocketConnectionDelegate> {
    SocketConnection *connection;
}
- (IBAction)blockAction:(id)sender;
- (IBAction)delegateAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Actions

- (IBAction)blockAction:(id)sender {
    [self blockRequest];
}

- (IBAction)delegateAction:(id)sender {
    [self delegateRequest];
}

#pragma mark - 交易

/** block方式 */
- (void)blockRequest {
    NSDictionary *dicReq = @{@"mobile":@"13666672771",
                             @"password":@"123456"};
    [[SocketHelper sharedInstance] writeData:dicReq tag:PDA_LOGIN dialogMsg:@"" success:^(NSDictionary *dic) {
        
    } fail:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        
    }];
}

/** delegate方式 */
- (void)delegateRequest {
    [self openConnection];
    NSDictionary *dicReq = @{@"mobile":@"13666672771",
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
