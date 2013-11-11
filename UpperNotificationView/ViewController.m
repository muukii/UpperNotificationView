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

    UpperNotificationView *notification = [UpperNotificationView notificationWithMessage:@"hello" image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification showInView:self.view];
}

@end
