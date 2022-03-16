//
//  ViewController.m
//  GrxOperationQueue
//
//  Created by GRX on 2022/3/16.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong)NSOperationQueue *qure;
@property(nonatomic,strong)NSBlockOperation *block1;
@property(nonatomic,strong)NSBlockOperation *block2;
@property(nonatomic,strong)NSMutableArray *block1Array;
@property(nonatomic,strong)NSMutableArray *block2Array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.block1Array = [NSMutableArray arrayWithCapacity:0];
    self.block2Array = [NSMutableArray arrayWithCapacity:0];
    NSArray *titleArray = @[@"NSOperationQueue",@"dispatchSemaphore",@"dispatchGroup"];
    for (int i=0; i<3; i++) {
        UIButton *sendBtn = [[UIButton alloc]init];
        [sendBtn setBackgroundColor:[UIColor blackColor]];
        [sendBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendBtn.frame = CGRectMake(100, 150+i*80, 200, 50);
        sendBtn.layer.cornerRadius = 5;
        sendBtn.tag = i+10;
        [self.view addSubview:sendBtn];
        [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)sendBtnClick:(UIButton *)sender{
    if (sender.tag==10) {
        [self addOperationQueue];
    }else if (sender.tag==11){
        [self dispatchSemaphore];
    }else{
        [self dispatchGroup];
    }
}

/** NSOperationQueue依赖  */
-(void)addOperationQueue{
    self.qure = [[NSOperationQueue alloc]init];
    self.block1 = [NSBlockOperation blockOperationWithBlock:^{
    }];
    self.block2 = [NSBlockOperation blockOperationWithBlock:^{
    }];
    NSBlockOperation *conmplater = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block1Array====%@",self.block1Array);
        NSLog(@"block2Array====%@",self.block2Array);
        NSLog(@"全部完成");
    }];
    [conmplater addDependency:self.block1];
    [conmplater addDependency:self.block2];
    [self.qure addOperation:conmplater];
    [self httpsRequest1];
    [self httpsRequest2];
}

/** GCD信号量  */
-(void)dispatchSemaphore{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_group_async(group, queue, ^{
            [self httpsRequest3:semaphore];
        });
        dispatch_group_async(group, queue, ^{
            [self httpsRequest4:semaphore];
        });
        dispatch_group_notify(group, queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"block1Array====%@",self.block1Array);
            NSLog(@"block2Array====%@",self.block2Array);
            NSLog(@"全部完成");
        });
}
/** GCD线程组  */
-(void)dispatchGroup{
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_group_async(group, queue, ^{
            dispatch_group_enter(group);
            [self httpsRequest5:group];
        });
        dispatch_group_async(group, queue, ^{
            dispatch_group_enter(group);
            [self httpsRequest6:group];
        });
        dispatch_group_notify(group, queue, ^{
            NSLog(@"block1Array====%@",self.block1Array);
            NSLog(@"block2Array====%@",self.block2Array);
            NSLog(@"全部完成");
        });
}

-(void)httpsRequest1{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block1Array removeAllObjects];
        for (int i=0; i<10; i++) {
            [self.block1Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.qure addOperation:self.block1];
       }] resume];
}
-(void)httpsRequest2{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block2Array removeAllObjects];
        for (int i=10; i<20; i++) {
            [self.block2Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.qure addOperation:self.block2];
       }] resume];
}
-(void)httpsRequest3:(dispatch_semaphore_t)semaphore{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block1Array removeAllObjects];
        for (int i=0; i<10; i++) {
            [self.block1Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        dispatch_semaphore_signal(semaphore);
       }] resume];
}
-(void)httpsRequest4:(dispatch_semaphore_t)semaphore{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block2Array removeAllObjects];
        for (int i=10; i<20; i++) {
            [self.block2Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        dispatch_semaphore_signal(semaphore);
       }] resume];
}
-(void)httpsRequest5:(dispatch_group_t)group{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block1Array removeAllObjects];
        for (int i=0; i<10; i++) {
            [self.block1Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        dispatch_group_leave(group);
       }] resume];
}
-(void)httpsRequest6:(dispatch_group_t)group{
    NSURL *url = [NSURL URLWithString:@"http://www.cocoachina.com"];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self.block2Array removeAllObjects];
        for (int i=10; i<20; i++) {
            [self.block2Array addObject:[NSString stringWithFormat:@"%d",i]];
        }
        dispatch_group_leave(group);
       }] resume];
}

@end
