//
//  ViewController.m
//  MMMUpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "ViewController.h"

#import "MMMUpperNotificationView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBAction methods

- (IBAction)buttonClick:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationFaiureView class])];
    MMMUpperNotificationFaiureView *notification = [MMMUpperNotificationFaiureView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}

- (IBAction)caution:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationCautionView class])];
    MMMUpperNotificationCautionView *notification = [MMMUpperNotificationCautionView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}

- (IBAction)success:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationSuccessView class])];
    MMMUpperNotificationSuccessView *notification = [MMMUpperNotificationSuccessView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"hellow");
    }];
    [notification show];
}

@end
