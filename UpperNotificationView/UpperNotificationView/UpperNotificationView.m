//
//  UpperNotificationView.m
//  UpperNotificationView
//
//  Created by Muukii on 2013/11/11.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "UpperNotificationView.h"
@interface UpperNotificationManager : NSObject
@property (nonatomic, retain) NSMutableArray *notifications;
@end

@implementation UpperNotificationManager

@end



#define ANIMATION_DURATION 0.3
@implementation UpperNotificationView
{
    TapHandler _tapHandler;
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
    CGRect rect = CGRectMake(0, 0, 320, 44);
    self = [self initWithFrame:rect];
    if (self) {
        [self setTapHandler:tapHandler];
        [self configureView];
        [self setGesture];
        [self setMessage:message];
        [self setImage:image];
    }
    return self;
}

- (void)configureView
{
    [self setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];


    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 280 , 44)];
    self.messageLabel.backgroundColor = [UIColor clearColor];


    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.imageView.contentMode = UIViewContentModeCenter;


    [self addSubview:self.messageLabel];
    [self addSubview:self.imageView];

}

- (void)setGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapGestureHandler:(id)sender
{
    if (_tapHandler) {
        _tapHandler();
    }
    [self dismiss];
}

- (void)setMessage:(NSString *)message
{
    _message = message;
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
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [queue addOperationWithBlock:^{
        [view addSubview:self];
        [self display];

        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismiss];
        });

    }];
}

- (void)display
{
    CGPoint originPoint = self.center;
    CGPoint animationPoint = originPoint;
    animationPoint.y -= 100;
    self.center = animationPoint;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = originPoint;
    } completion:^(BOOL finished) {

    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint animationPoint = self.center;
        animationPoint.y -= 100;
        self.center = animationPoint;
    } completion:^(BOOL finished) {

    }];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
