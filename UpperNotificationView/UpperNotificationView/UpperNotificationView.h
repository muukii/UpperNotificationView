//
//  UpperNotificationView.h
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//
UIKIT_STATIC_INLINE BOOL
__isIOS7()
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version hasPrefix:@"7"]) {
        return YES;
    } else {
        return NO;
    }
}
#define IsIOS7 __isIOS7()


#import <UIKit/UIKit.h>

typedef void(^TapHandler)();

@interface UpperNotificationView : UIView
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) UIImage *image;

- (void)configureColor;
- (void)setTapHandler:(TapHandler)tapHandler;
- (TapHandler)tapHandler;

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image;
+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler;

- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image;
- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler;
- (void)showInView:(UIView *)view;

@end

@interface UpperNotificationCautionView : UpperNotificationView

@end

@interface UpperNotificationSuccessView : UpperNotificationView

@end

@interface UpperNotificationFaiureView : UpperNotificationView

@end
