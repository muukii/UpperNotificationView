//
//  UpperNotificationView.m
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

#import "UpperNotificationView.h"
@interface UpperNotificationManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, retain) NSMutableArray *notifications;

- (void)showInView:(UIView *)view notificationView:(UpperNotificationView *)notificationView;

@end

@implementation UpperNotificationManager
static id _sharedInstance = nil;
+ (instancetype)sharedManager
{
    if (nil == _sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [[self alloc] init];
        });
    }
    return _sharedInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.notifications = [NSMutableArray array];
    }
    return self;
}

- (void)showInView:(UIView *)view notificationView:(UpperNotificationView *)notificationView
{

}

@end



#define ANIMATION_DURATION 0.3
#define SELF_MINIMUM_HEIGHT 44.f
#define MESSAGE_MARGIN 20.f
@interface UpperNotificationView ()
@property (nonatomic, retain) UIView *animationView;
@end
@implementation UpperNotificationView
{
    TapHandler _tapHandler;
    UIDynamicAnimator *_dynamicAnimator;
    UIPushBehavior *_pushBehavior;
    UIGravityBehavior *_gravityBehavior;
    UICollisionBehavior* _collision;
    CGFloat statusBarHeight;
    UIWindow *notificationWindow;
}
+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image
{
    UpperNotificationView *notificationView = [[self alloc] initWithMessage:message image:image];
    return notificationView;
}

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler{
    UpperNotificationView *notificationView = [[self alloc] initWithMessage:message image:image tapHandler:tapHandler];
    return notificationView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image
{
    return [self initWithMessage:message image:image tapHandler:NULL];
}
- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler
{
    CGRect rect = CGRectMake(0, 0, 320, SELF_MINIMUM_HEIGHT);
    self = [self initWithFrame:rect];
    if (self) {
        [self setTapHandler:tapHandler];
        [self configureView];
        [self configureColor];
        if (IsIOS7) {
            [self configureDynamicAnimation];
        }
        [self setGesture];
        [self setMessage:message];
        [self setImage:image];
    }
    return self;
}

- (void)configureView
{
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    self.animationView = [[UIView alloc] initWithFrame:CGRectMake(0, -600, 320, 600)];
    self.animationView.opaque = NO;
    self.animationView.backgroundColor = [UIColor clearColor];

    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 270 , 0)];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.numberOfLines = 0;
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];


    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.imageView.contentMode = UIViewContentModeCenter;


    [self addSubview:self.messageLabel];
    [self addSubview:self.imageView];

}

- (void)configureColor
{
    [self setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    self.messageLabel.textColor = [UIColor whiteColor];
}

- (void)configureDynamicAnimation
{

}

- (void)setGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapGestureHandler:(id)sender
{
    if (IsIOS7) {
        [_dynamicAnimator removeAllBehaviors];
    }
    if (_tapHandler) {
        _tapHandler();
    }
    [self dismiss];
}

- (void)setMessage:(NSString *)message
{

    _message = message;

    CGSize size;
    CGSize cropSize = CGSizeMake(CGRectGetWidth(self.messageLabel.frame), 1000);
    if (IsIOS7) {
        size = [message boundingRectWithSize:cropSize options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil].size;
    } else {
        size = [message sizeWithFont:self.messageLabel.font constrainedToSize:cropSize lineBreakMode:NSLineBreakByWordWrapping];
    }


    NSLog(@"%@",NSStringFromCGSize(size));

    size.height += MESSAGE_MARGIN + statusBarHeight;
    if (size.height > SELF_MINIMUM_HEIGHT - MESSAGE_MARGIN) {
        CGRect messageLabelRect = self.messageLabel.frame;
        messageLabelRect.size = size;
        self.messageLabel.frame = messageLabelRect;

        CGRect selfRect = self.frame;
        selfRect.size.height = size.height;
        self.frame = selfRect;

        CGPoint messageLabelCenter = self.messageLabel.center;
        messageLabelCenter.y = CGRectGetMidY(self.frame) + statusBarHeight/2;
        self.messageLabel.center = messageLabelCenter;

        if (IsIOS7) {
            CGRect animationViewRect = self.animationView.frame;
            animationViewRect.origin.y += self.frame.size.height;
            self.animationView.frame = animationViewRect;
        }
    }
    self.messageLabel.text = message;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}
- (void)setTapHandler:(TapHandler)tapHandler
{
    _tapHandler = tapHandler;
}
- (void)showInView:(UIView *)view
{
    UIWindow *window = view.window;
//    window.windowLevel = UIWindowLevelAlert;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];

    notificationWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    notificationWindow.windowLevel = UIWindowLevelAlert;
    [notificationWindow makeKeyAndVisible];

    [queue addOperationWithBlock:^{
        [[UpperNotificationManager sharedManager].notifications addObject:self];

        if (IsIOS7) {
            [self.animationView addSubview:self];
            [notificationWindow addSubview:self.animationView];
        } else {
            [view addSubview:self];
        }
        [self display];

        double delayInSeconds;
        if (IsIOS7) {
            delayInSeconds = 3.f;
        } else {
            delayInSeconds = 2.f;
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismiss];
        });

    }];
}

- (void)display
{


    if (IsIOS7) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.animationView];

        _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
        [_pushBehavior setPushDirection:CGVectorMake(0, 1)];

        _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self]];
        CGFloat magnitude = CGRectGetHeight(self.frame) * 0.01 * 3;
        [_gravityBehavior setMagnitude:magnitude];
        _collision = [[UICollisionBehavior alloc]
                      initWithItems:@[self]];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [_dynamicAnimator addBehavior:_collision];
        [_dynamicAnimator addBehavior:_gravityBehavior];
    } else {
        CGPoint originPoint = self.center;
        CGPoint animationPoint = originPoint;
        animationPoint.y -= CGRectGetHeight(self.frame);
        self.center = animationPoint;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.center = originPoint;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint animationPoint = self.center;
        animationPoint.y -= CGRectGetHeight(self.frame);
        self.center = animationPoint;
    } completion:^(BOOL finished) {
        if (IsIOS7) {
            [self.animationView removeFromSuperview];
        } else {
            [self removeFromSuperview];
        }
        NSLog(@"%@",[UpperNotificationManager sharedManager].notifications);
        [[UpperNotificationManager sharedManager].notifications removeObject:self];
        notificationWindow = nil;
    }];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end


@implementation UpperNotificationSuccessView

- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.851 green:0.682 blue:0.188 alpha:0.500];
    self.messageLabel.textColor = [UIColor whiteColor];

}

@end

@implementation UpperNotificationCautionView

- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.337 green:0.569 blue:0.384 alpha:0.500];
    self.messageLabel.textColor = [UIColor whiteColor];

}

@end

@implementation UpperNotificationFaiureView
- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.469 green:0.426 blue:0.770 alpha:0.500];
    self.messageLabel.textColor = [UIColor whiteColor];
}

@end
