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

@interface MMMUpperNotificationController : UIViewController
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation MMMUpperNotificationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.hidden = YES;
}
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}
@end

@interface MMMUpperNotificationAnimationView : UIView
@end

@implementation MMMUpperNotificationAnimationView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
    	return nil;
    }
    return view;
}
@end

@implementation MMMUpperNotificationWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
    	return nil;
    }
    return view;
}
- (void)makeKeyAndVisible
{
    MMMUpperNotificationController *controller = [MMMUpperNotificationController new];
    [controller setStatusBarStyle:_statusBarStyle];
    self.rootViewController = controller;
    [super makeKeyAndVisible];
}
@end

@interface NSMutableArray (Queue)
- (id)dequeue;
- (void)enqueue:(id)anObject;
@end

@implementation NSMutableArray (Queue)
- (id)dequeue
{
    NSAssert(self.count, @"The array does not contain anything.");
    id obj = [self objectAtIndex:0];
    if (obj != nil) {
        [self removeObjectAtIndex:0];
    }
    return obj;
}
- (void)enqueue:(id)anObject
{
    [self addObject:anObject];
}
@end

@interface MMMUpperNotificationManager ()
+ (instancetype)sharedManager:(BOOL)dealloc;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (readwrite, nonatomic, strong) NSOperationQueue *queue;
@end

static const NSTimeInterval kMMMUpperNotificationManagerAnimationDuration = .3;
@implementation MMMUpperNotificationManager {
    UIDynamicAnimator *_dynamicAnimator;
    MMMUpperNotificationAnimationView *_dynamicAnimationView;
    struct {
        unsigned int isShowing:1;
        unsigned int isAnimatingToHide:1;
    } _viewFlags;
}

static UIStatusBarStyle _statusBarStyle;
+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
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
        _notificationWindow = [[MMMUpperNotificationWindow alloc] initWithFrame:CGRectMake(0, -1, CGRectGetWidth([UIScreen mainScreen].bounds), 64)];
        _dynamicAnimationView = [MMMUpperNotificationAnimationView new];
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
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
    [_dynamicAnimator removeAllBehaviors];


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
    [self.notifications enqueue:notificationView];
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

    if (self.hiddenNotification) {
        [self.notifications dequeue];
        return;
    }

    if (_viewFlags.isShowing) {
        return;
    }
    _viewFlags.isShowing = true;
    
    MMMUpperNotificationView *showNotification = [self.notifications dequeue];
    


    [self display:showNotification];

    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismiss:showNotification];
    });

}

- (void)display:(MMMUpperNotificationView *)showNotification
{
    CGFloat hiddenHeight = 600;


    if (1) {
        [_notificationWindow addSubview:showNotification];

        CGPoint originPoint = showNotification.center;
        CGPoint animationPoint = originPoint;
        animationPoint.y -= CGRectGetHeight(showNotification.frame);
        showNotification.center = animationPoint;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
            showNotification.center = originPoint;

        } completion:^(BOOL finished) {

        }];

    } else {

        _dynamicAnimationView.frame = CGRectMake(0, -hiddenHeight + CGRectGetHeight(showNotification.frame) , 320, hiddenHeight);
        [_dynamicAnimationView addSubview:showNotification];

        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:_dynamicAnimationView];

        UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[showNotification]];
        CGFloat magnitude = CGRectGetHeight(showNotification.frame) * 0.01 * 7;
        [gravityBehavior setMagnitude:magnitude];
        [_dynamicAnimator addBehavior:gravityBehavior];

        UICollisionBehavior* collision = [[UICollisionBehavior alloc] initWithItems:@[showNotification]];
        collision.translatesReferenceBoundsIntoBoundary = YES;
        [_dynamicAnimator addBehavior:collision];

        [_notificationWindow addSubview:_dynamicAnimationView];
    }

    _notificationWindow.windowLevel = UIWindowLevelAlert;
    _notificationWindow.statusBarStyle = _statusBarStyle;
    [_notificationWindow makeKeyAndVisible];
}

- (void)dismiss:(MMMUpperNotificationView *)notificationView
{
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:nil];
    [_dynamicAnimator removeAllBehaviors];

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
            [notificationView removeFromSuperview];
            _viewFlags.isShowing = false;
            _viewFlags.isAnimatingToHide = false;
            [self display];
        }
    }];
}

@end
