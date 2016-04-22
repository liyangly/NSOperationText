//
//  ViewController.m
//  NSOperationText
//
//  Created by 李阳 on 16/4/21.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "ViewController.h"

#define kURL @"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //1.NSOperation
//    [self NSOperation];
    
    //2.GCD
//    [self GCDText];
    
    //3.GCD dispatch_group_async的使用
//    [self GCD_GROUP_TEXT];
    
    //4.GCD dispatch_barrier_async的使用
    [self GCD_BARRIER_TEXT];
    
    
    //5.GCD dispatch_apply的使用
//    [self GCD_APPLY_TEXT];
    
}

- (void)NSOperation {
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(downloadImage:)
                                                                              object:kURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    //线程池中的线程数，也就是并发操作数。默认情况下是-1，-1表示没有限制，这样会同时运行队列中的全部的操作。
    //    [queue setMaxConcurrentOperationCount:5];
}

- (void)GCDText {
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 并行队列 可同时执行多个派遣任务dispatch
    //dispatch_get_main_queue() (串行队列)主队列 可按先后顺序执行多个派遣任务dispatch
    //dispatch_queue_create(<#const char *label#>, <#dispatch_queue_attr_t attr#>) 私有队列 根据第二个参数可以设置为并行海事串行队列 只能执行一个派遣任务dispatch
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //好使的操作
        NSURL *url0 = [NSURL URLWithString:kURL];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url0];
        UIImage *image = [[UIImage alloc] initWithData:data];
        NSAssert(image, @"图片不存在");
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI
            self.imageView.image = image;
        });
    });
}

- (void)GCD_GROUP_TEXT {
    
    NSLog(@"开始！！！");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    // dispatch_group_async可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"group-1");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"group-2");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        NSLog(@"group-3");
    });
    // dispatch_group_notify group中的线程执行完后执行
    dispatch_group_notify(group, queue, ^{
        NSLog(@"updateUI");
    });
}

- (void)GCD_BARRIER_TEXT {
    // dispatch_barrier_async是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
    //dispatch_queue_create(<#const char *label#>, <#dispatch_queue_attr_t attr#>) 参数1只是标识这个队列，参数2表示队列的类型
    //DISPATCH_QUEUE_SERIAL 或者 NULL 时，为串行队列；DISPATCH_QUEUE_CONCURRENT 为并行队列
    /*dispatch queue分为下面三种：
    Serial
    又称为private dispatch queues，同时只执行一个任务。Serial queue通常用于同步访问特定的资源或数据。当你创建多个Serial queue时，虽然它们各自是同步执行的，但Serial queue与Serial queue之间是并发执行的。
    
    Concurrent
    又称为global dispatch queue，可以并发地执行多个任务，但是执行完成的顺序是随机的。
    
    Main dispatch queue
    它是全局可用的serial queue，它是在应用程序主线程上执行任务的。
     */
    dispatch_queue_t queue = dispatch_queue_create("gcdtextbarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"diapatch_async-1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"dispatch_async-2");
    });
    
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"dispatch_barrier_asynv");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        NSLog(@"dispatch_async-3");
    });
    
}

- (void)GCD_APPLY_TEXT {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(5, queue, ^(size_t index) {
        NSLog(@"执行 %zu",index);
    });
}

- (void)downloadImage:(NSString *)url {
    
    NSLog(@"加载图片了");
    NSURL *nsurl = [NSURL URLWithString:url];
    NSData *data = [[NSData alloc] initWithContentsOfURL:nsurl];
    UIImage *image = [[UIImage alloc] initWithData:data];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
    
}

- (void)updateUI:(id)image {
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
