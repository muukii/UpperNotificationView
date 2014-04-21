//
//  ViewController.m
//  MMMUpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "ViewController.h"

#import "MMMUpperNotificationView.h"

@interface MMMUpperNotificationFaiureView : MMMUpperNotificationView <MMMUpperNotificationViewHook>
@end

@interface MMMUpperNotificationCautionView : MMMUpperNotificationView <MMMUpperNotificationViewHook>
@end

@interface MMMUpperNotificationSuccessView : MMMUpperNotificationView <MMMUpperNotificationViewHook>
@end

@interface ViewController ()
- (IBAction)failure:(id)sender;
- (IBAction)caution:(id)sender;
- (IBAction)success:(id)sender;
@end

@implementation MMMUpperNotificationSuccessView
- (void)hookConfiguration
{
    self.backgroundColor = [UIColor colorWithRed:0.000 green:0.643 blue:0.878 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];
}
@end

@implementation MMMUpperNotificationCautionView
- (void)hookConfiguration
{
    self.backgroundColor = [UIColor colorWithRed:0.851 green:0.839 blue:0.235 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];
}
@end

@implementation MMMUpperNotificationFaiureView
- (void)hookConfiguration
{
    self.backgroundColor = [UIColor colorWithRed:0.761 green:0.278 blue:0.016 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - IBAction methods

- (IBAction)failure:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationFaiureView class])];
    MMMUpperNotificationFaiureView *notification = [MMMUpperNotificationFaiureView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"Tapped %@", NSStringFromClass([MMMUpperNotificationFaiureView class]));
    }];
    [notification show];
}

- (IBAction)caution:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationCautionView class])];
    MMMUpperNotificationCautionView *notification = [MMMUpperNotificationCautionView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"Tapped %@", NSStringFromClass([MMMUpperNotificationCautionView class]));
    }];
    [notification show];
}

- (IBAction)success:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"This is a message for %@.", NSStringFromClass([MMMUpperNotificationSuccessView class])];
    MMMUpperNotificationSuccessView *notification = [MMMUpperNotificationSuccessView notificationWithMessage:message image:nil tapHandler:^{
        NSLog(@"Tapped %@", NSStringFromClass([MMMUpperNotificationSuccessView class]));
    }];
    [notification show];
}

@end
