// MMMUpperNotificationManager.m
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

#import "MMMUpperNotificationManager.h"

#import "MMMUpperNotificationView.h"

static const NSTimeInterval kMMMUpperNotificationManagerAnimationDuration = .3;

@interface MMMUpperNotificationManager ()
+ (instancetype)sharedManager:(BOOL)dealloc;
@property (nonatomic, strong) UIWindow *notificationWindow;
@property (nonatomic, strong) NSMutableArray *notifications;
@end

@implementation MMMUpperNotificationManager {
    UIDynamicAnimator *_dynamicAnimator;
    UIView *_dynamicAnimationView;
    struct {
        unsigned int isShowing:1;
        unsigned int isAnimatingToHide:1;
    } _viewFlags;
}

+ (instancetype)sharedManager:(BOOL)dealloc
{
    static MMMUpperNotificationManager *_sharedInstance = nil;
    if (dealloc) {
        _sharedInstance = nil;
    } else {
        if (nil == _sharedInstance) {
            _sharedInstance = [[[self class] alloc] init];
        }
    }
    return _sharedInstance;
}

+ (instancetype)sharedManager
{
    return [[self class] sharedManager:NO];
}

- (id)init
{
    self = [super init];
    if (self) {
        _notifications = [NSMutableArray array];
        _notificationWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, -1, CGRectGetWidth([UIScreen mainScreen].bounds), 64)];
        _dynamicAnimationView = [UIView new];
    }
    return self;
}

- (void)tapHandler:(MMMUpperNotificationView *)notificationView
{
    if (notificationView.tapHandler) {
        notificationView.tapHandler();
    }
    [self dismiss:notificationView];
}

- (void)panGestureHandler:(UIGestureRecognizer *)gesture notificationView:(MMMUpperNotificationView *)notificationView
{
    if (NSClassFromString(@"UIDynamicAnimator")) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
        [_dynamicAnimator removeAllBehaviors];
    }

    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    CGPoint p = [panGesture translationInView:notificationView.superview];
    CGPoint movedPoint = CGPointMake(notificationView.center.x, notificationView.center.y + p.y);
    CGFloat panLimit = CGRectGetHeight(notificationView.superview.frame) - (CGRectGetHeight(notificationView.frame) * .5);
    movedPoint.y = MIN(movedPoint.y, panLimit);
    notificationView.center = movedPoint;

    [panGesture setTranslation:CGPointZero inView:notificationView.superview];

    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (CGRectGetHeight(notificationView.superview.frame) - CGRectGetHeight(notificationView.frame) > CGRectGetMinY(notificationView.frame) + 25) {
            [self dismiss:notificationView];
        } else {
            [self display:notificationView];
        }
    }
}

- (void)showNotificationView:(MMMUpperNotificationView *)notificationView
{
    [_notifications addObject:notificationView];
    [self display];
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
                [[self class] sharedManager:YES];
            }
        });
        return;
    }
    
    if (_viewFlags.isShowing) {
        return;
    }
    _viewFlags.isShowing = true;
    
    MMMUpperNotificationView *showNotification = _notifications.firstObject;
    [self display:showNotification];

    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismiss:showNotification];
    });

}

- (void)display:(MMMUpperNotificationView *)showNotification
{
    if (NSClassFromString(@"UIDynamicAnimator")) {
        CGFloat hiddenHeight = 600;

        _dynamicAnimationView.frame = CGRectMake(0, -hiddenHeight + CGRectGetHeight(showNotification.frame) , 320, hiddenHeight);
        [_dynamicAnimationView addSubview:showNotification];

        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:_dynamicAnimationView];
        
        UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[showNotification]];
        CGFloat magnitude = CGRectGetHeight(showNotification.frame) * 0.01 * 3;
        [gravityBehavior setMagnitude:magnitude];
        [_dynamicAnimator addBehavior:gravityBehavior];
        
        UICollisionBehavior* collision = [[UICollisionBehavior alloc] initWithItems:@[showNotification]];
        collision.translatesReferenceBoundsIntoBoundary = YES;
        [_dynamicAnimator addBehavior:collision];

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
        [UIView animateWithDuration:kMMMUpperNotificationManagerAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            showNotification.center = originPoint;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismiss:(MMMUpperNotificationView *)notificationView
{
    if (NSClassFromString(@"UIDynamicAnimator")) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
        [_dynamicAnimator removeAllBehaviors];
    }
    
    if (_viewFlags.isAnimatingToHide) {
        return;
    }
    _viewFlags.isAnimatingToHide = false;
    
    [UIView animateWithDuration:kMMMUpperNotificationManagerAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint animationPoint = notificationView.center;
        animationPoint.y -= CGRectGetHeight(notificationView.frame);
        notificationView.center = animationPoint;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.notifications removeObject:notificationView];
            [notificationView removeFromSuperview];
            _viewFlags.isShowing = false;
            _viewFlags.isAnimatingToHide = false;
            [self display];
        }
    }];
}

@end
