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

- (void)showNotificationView:(UpperNotificationView *)notificationView;
- (void)dismiss:(UpperNotificationView *)notificationView;
- (void)tapHandler:(UpperNotificationView *)notificationView;
- (void)panGestureHandler:(UIGestureRecognizer *)gesture notificationView:(UpperNotificationView *)notificationView;
@end
