//
//  UpperNotificationManager.m
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/12.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "UpperNotificationManager.h"
#import "UpperNotificationView.h"
#define ANIMATION_DURATION 0.3

@implementation UpperNotificationManager
{
    UIDynamicAnimator *_dynamicAnimator;
    UIPushBehavior *_pushBehavior;
    UIGravityBehavior *_gravityBehavior;
    UICollisionBehavior* _collision;
    UIView *_dynamicAnimationView;
    BOOL showing;
}
static id _sharedInstance = nil;
+ (instancetype)sharedManager
{
    if (nil == _sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        _notifications = [NSMutableArray array];
        _notificationWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        _dynamicAnimationView = [UIView new];
    }
    return self;
}

- (void)showInView:(UIView *)view notificationView:(UpperNotificationView *)notificationView
{
    [_notifications addObject:notificationView];
    [self display];

    }
- (void)tapHandler:(UpperNotificationView *)notificationView
{
    if (IsIOS7) {
        [_dynamicAnimator removeAllBehaviors];
    }
    if (notificationView.tapHandler) {
        notificationView.tapHandler();
    }
    [self dismiss:notificationView];
}

- (void)displayDynamicAnimation
{


}
- (void)display
{
    if (!_notifications.count) {
        _sharedInstance = nil;

        return;
    }
    if (showing) {
        return;
    } else {
        showing = YES;
    }

    UpperNotificationView *showNotification = _notifications.firstObject;
    NSLog(@"%@",_notifications);
    if (IsIOS7) {
        CGFloat hiddenHeight = 600;

        _dynamicAnimationView.frame = CGRectMake(0, -hiddenHeight + CGRectGetHeight(showNotification.frame) , 320, hiddenHeight);
        [_dynamicAnimationView addSubview:showNotification];

        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:_dynamicAnimationView];
        _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[showNotification] mode:UIPushBehaviorModeInstantaneous];
        [_pushBehavior setPushDirection:CGVectorMake(0, 1)];

        _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[showNotification]];
        CGFloat magnitude = CGRectGetHeight(showNotification.frame) * 0.01 * 3;
        [_gravityBehavior setMagnitude:magnitude];
        _collision = [[UICollisionBehavior alloc]
                      initWithItems:@[showNotification]];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [_dynamicAnimator addBehavior:_collision];
        [_dynamicAnimator addBehavior:_gravityBehavior];

        [_notificationWindow addSubview:_dynamicAnimationView];
        _notificationWindow.windowLevel = UIWindowLevelAlert;
        [_notificationWindow makeKeyAndVisible];
    } else {
        [_notificationWindow addSubview:showNotification];
        _notificationWindow.windowLevel = UIWindowLevelAlert;
        [_notificationWindow makeKeyAndVisible];

        CGPoint originPoint = showNotification.center;
        CGPoint animationPoint = originPoint;
        animationPoint.y -= CGRectGetHeight(showNotification.frame);
        showNotification.center = animationPoint;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            showNotification.center = originPoint;
        } completion:^(BOOL finished) {

        }];
    }

    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismiss:showNotification];
    });

}
- (void)dismiss:(UpperNotificationView *)notificationView
{
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint animationPoint = notificationView.center;
        animationPoint.y -= CGRectGetHeight(notificationView.frame);
        notificationView.center = animationPoint;
    } completion:^(BOOL finished) {
        [self.notifications removeObject:notificationView];
        [notificationView removeFromSuperview];
        showing = NO;
        [self display];
    }];
}
- (void)dealloc
{
    NSLog(@"UpperNotificationManager dealloc");
}

@end
