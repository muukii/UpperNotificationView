// MMMUpperNotificationView.m
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

#import "MMMUpperNotificationView.h"

#import "MMMUpperNotificationManager.h"


#define SELF_MINIMUM_HEIGHT 65.f
#define MESSAGE_MARGIN 20.f
@interface MMMUpperNotificationView () <UIGestureRecognizerDelegate>
@end
@implementation MMMUpperNotificationView
{
    TapHandler _tapHandler;
    UIDynamicAnimator *_dynamicAnimator;
    UIPushBehavior *_pushBehavior;
    UIGravityBehavior *_gravityBehavior;
    UICollisionBehavior* _collision;
    CGFloat statusBarHeight;
    UIWindow *notificationWindow;
}
+ (instancetype)notification
{
    MMMUpperNotificationView *notificationView = [[self alloc] initWithMessage:nil image:nil];
    return notificationView;
}
+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image
{
    MMMUpperNotificationView *notificationView = [[self alloc] initWithMessage:message image:image];
    return notificationView;
}

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler{
    MMMUpperNotificationView *notificationView = [[self alloc] initWithMessage:message image:image tapHandler:tapHandler];
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
- (instancetype)initNotification
{
    return [self initWithMessage:nil image:nil];
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
        if (message) {
            [self setMessage:message];
        }
        if (image) {
            [self setImage:image];
        }
    }
    return self;
}

- (void)configureView
{
//    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    statusBarHeight = 0;

    CGFloat messageLabelX = 64;
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(messageLabelX, 0, 320 - messageLabelX - 10 , 64)];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.numberOfLines = 3;
    [self.messageLabel setFont:[UIFont systemFontOfSize:14]];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];


    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    self.imageView.contentMode = UIViewContentModeCenter;


    [self addSubview:self.messageLabel];
    [self addSubview:self.imageView];

}
- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    _backgroundViewColor = backgroundViewColor;
    [self setBackgroundColor:backgroundViewColor];
}
- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    [self setMessageTextColor:messageTextColor];
}
- (void)configureColor
{
    self.backgroundViewColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    self.messageTextColor = [UIColor whiteColor];
}

- (void)configureDynamicAnimation
{

}

- (void)setGesture
{
//    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGestureHandler:)];
//    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
//    swipeUpGesture.delegate = self;
//    [self addGestureRecognizer:swipeUpGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self addGestureRecognizer:panGesture];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)tapGestureHandler:(id)sender
{
    [[MMMUpperNotificationManager sharedManager] tapHandler:self];
}

- (void)panGestureHandler:(id)sender
{
    [[MMMUpperNotificationManager sharedManager] panGestureHandler:sender notificationView:self];
}
- (void)swipeUpGestureHandler:(id)sender
{
    [[MMMUpperNotificationManager sharedManager] dismiss:self];

}

- (void)setMessage:(NSString *)message
{

    _message = message;

//    CGSize size;
//    CGSize cropSize = CGSizeMake(CGRectGetWidth(self.messageLabel.frame), 1000);
//    if (IsIOS7) {
//        size = [message boundingRectWithSize:cropSize options:
//                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
//                                     attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil].size;
//    } else {
//        size = [message sizeWithFont:self.messageLabel.font constrainedToSize:cropSize lineBreakMode:NSLineBreakByWordWrapping];
//    }
//
//
//    NSLog(@"%@",NSStringFromCGSize(size));
//
//    size.height += MESSAGE_MARGIN + statusBarHeight;
//    if (size.height > SELF_MINIMUM_HEIGHT - MESSAGE_MARGIN) {
//        CGRect messageLabelRect = self.messageLabel.frame;
//        messageLabelRect.size = size;
//        self.messageLabel.frame = messageLabelRect;
//
//        CGRect selfRect = self.frame;
//        selfRect.size.height = size.height;
//        self.frame = selfRect;
//
//        CGPoint messageLabelCenter = self.messageLabel.center;
//        messageLabelCenter.y = CGRectGetMidY(self.frame) + statusBarHeight/2;
//        self.messageLabel.center = messageLabelCenter;
//
//    }
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
- (TapHandler)tapHandler
{
    return _tapHandler;
}
- (void)show
{
    [[MMMUpperNotificationManager sharedManager] showNotificationView:self];
}


- (void)dealloc
{
    NSLog(@"dealloc");
}

@end


@implementation MMMUpperNotificationSuccessView

- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.000 green:0.643 blue:0.878 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];
}

@end

@implementation MMMUpperNotificationCautionView

- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.851 green:0.839 blue:0.235 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];

}

@end

@implementation MMMUpperNotificationFaiureView
- (void)configureColor
{
    self.backgroundColor = [UIColor colorWithRed:0.761 green:0.278 blue:0.016 alpha:0.950];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.image = [UIImage imageNamed:@"icon"];

}

@end
