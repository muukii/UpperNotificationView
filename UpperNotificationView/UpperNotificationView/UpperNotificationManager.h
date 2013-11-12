//
//  UpperNotificationManager.h
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/12.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UpperNotificationView;
@interface UpperNotificationManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, retain) UIWindow *notificationWindow;
@property (nonatomic, retain) NSMutableArray *notifications;

- (void)showInView:(UIView *)view notificationView:(UpperNotificationView *)notificationView;
- (void)tapHandler:(UpperNotificationView *)notificationView;
@end
