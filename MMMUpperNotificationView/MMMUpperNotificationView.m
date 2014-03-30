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

static const CGFloat kMMMUpperNotificationViewHeight = 65.;

@interface MMMUpperNotificationView () <UIGestureRecognizerDelegate, MMMUpperNotificationViewHook>
@end

@implementation MMMUpperNotificationView

#pragma mark - MMMUpperNotificationView useful methods

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler
{
    return [[[self class] alloc] initWithMessage:message image:image tapHandler:tapHandler];
}

+ (instancetype)notificationWithMessage:(NSString *)message image:(UIImage *)image
{
    return [[self class] notificationWithMessage:message image:image tapHandler:nil];
}

+ (instancetype)notification
{
    return [[self class] notificationWithMessage:nil image:nil tapHandler:nil];
}

#pragma mark - MMMUpperNotificationView initializing methods

- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image tapHandler:(TapHandler)tapHandler
{
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kMMMUpperNotificationViewHeight);
    self = [self initWithFrame:rect];
    if (self) {
        [self configureView];
        [self setTapHandler:tapHandler];
        [self setGesture];
        if (message) {
            [self setMessage:message];
        }
        if (image) {
            [self setImage:image];
        }
        [self hookConfiguration];
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message image:(UIImage *)image
{
    return [self initWithMessage:message image:image tapHandler:NULL];
}

- (instancetype)initNotification
{
    return [self initWithMessage:nil image:nil];
}

- (void)configureView
{
    CGFloat messageLabelX = 64;
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(messageLabelX, 0, 320 - messageLabelX - 10 , 64)];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.numberOfLines = 3;
    [self.messageLabel setFont:[UIFont systemFontOfSize:14]];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 36, 36)];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeCenter;
    
    self.backgroundViewColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    self.messageTextColor = [UIColor whiteColor];

    [self addSubview:self.messageLabel];
    [self addSubview:self.imageView];
}

- (void)hookConfiguration
{
}

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    _backgroundViewColor = backgroundViewColor;
    [self setBackgroundColor:backgroundViewColor];
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    [self.messageLabel setTextColor:messageTextColor];
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

- (void)setGesture
{
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

- (void)show
{
    [[MMMUpperNotificationManager sharedManager] showNotificationView:self];
}

@end
