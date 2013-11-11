//
//  UpperNotificationView.h
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapHandler)();

@interface UpperNotificationView : UIView
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) UIImage *image;

- (void)setTapHandler:(TapHandler)tapHandler;

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image;
+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler;

- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image;
- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler;
- (void)showInView:(UIView *)view;
@end
