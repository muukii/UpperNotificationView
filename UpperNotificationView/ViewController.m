//
//  ViewController.m
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "ViewController.h"
#import "UpperNotificationView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonClick:(id)sender {
//    UpperNotificationView *notificationView = [[UpperNotificationView alloc] initWithMessage:@"hello" image:nil];
//    [notificationView showInView:self.view];

    UpperNotificationFaiureView *notification = [UpperNotificationFaiureView notificationWithMessage:@"Good Morning!" image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}
- (IBAction)caution:(id)sender {
    UpperNotificationCautionView *notification = [UpperNotificationCautionView notificationWithMessage:@"Caution!!! Caution!!! Caution!!! Caution!!! " image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}
- (IBAction)success:(id)sender {
    UpperNotificationSuccessView *notification = [UpperNotificationSuccessView notificationWithMessage:@"Success!!! Success!!! Success!!! Success!!! Success!!! Success!!! Success!!! Success!!! Success!!! " image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}

@end
