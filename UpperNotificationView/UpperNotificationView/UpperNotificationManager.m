// UpperNotificationManager.m
//
// Copyright (c) 2014 Muukii (http://www.muukii.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
    BOOL closeAnimate;
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
        _notificationWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, -1, 320, 64)];
        _dynamicAnimationView = [UIView new];
    }
    return self;
}

- (void)showNotificationView:(UpperNotificationView *)notificationView
{
    [_notifications addObject:notificationView];
    [self display];
}
- (void)tapHandler:(UpperNotificationView *)notificationView
{
    if (notificationView.tapHandler) {
        notificationView.tapHandler();
    }
    [self dismiss:notificationView];
}
- (void)panGestureHandler:(UIGestureRecognizer *)gesture notificationView:(UpperNotificationView *)notificationView
{
    if (IsIOS7) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
        [_dynamicAnimator removeAllBehaviors];
    }

    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    CGPoint p = [panGesture translationInView:notificationView.superview];
    CGPoint movedPoint = CGPointMake(notificationView.center.x, notificationView.center.y + p.y);
    CGFloat panLimit = CGRectGetHeight(notificationView.superview.frame) - (CGRectGetHeight(notificationView.frame)/2);
    if (panLimit <= movedPoint.y) {
        movedPoint.y = panLimit;
    }
    notificationView.center = movedPoint;

    [panGesture setTranslation:CGPointZero inView:notificationView.superview];

    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        NSLog(@"%f %f",CGRectGetHeight(notificationView.superview.frame) - CGRectGetHeight(notificationView.frame),CGRectGetMinY(notificationView.frame));
        if (CGRectGetHeight(notificationView.superview.frame) - CGRectGetHeight(notificationView.frame) > CGRectGetMinY(notificationView.frame) + 25) {
            [self dismiss:notificationView];
        } else {
            [self displayAgain:notificationView];
        }
    }
}
- (void)displayDynamicAnimation
{


}
- (void)display
{
    if (!_notifications.count) {
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (!_notifications.count) {
                _sharedInstance = nil;
            }
        });
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
- (void)displayAgain:(UpperNotificationView *)showNotification
{
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
}
- (void)dismiss:(UpperNotificationView *)notificationView
{
    if (IsIOS7) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
        [_dynamicAnimator removeAllBehaviors];
    }
    if (closeAnimate) {
        return;
    } else {
        closeAnimate = YES;
    }
    closeAnimate = YES;
    NSLog(@"animation");
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint animationPoint = notificationView.center;
        animationPoint.y -= CGRectGetHeight(notificationView.frame);
        notificationView.center = animationPoint;
    } completion:^(BOOL finished) {
        [self.notifications removeObject:notificationView];
        [notificationView removeFromSuperview];
        showing = NO;
        closeAnimate = NO;
        [self display];
    }];
}
- (void)dealloc
{
    NSLog(@"UpperNotificationManager dealloc");
}

@end
