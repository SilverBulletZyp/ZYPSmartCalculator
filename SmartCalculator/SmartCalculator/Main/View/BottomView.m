//
//  BottomView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "BottomView.h"


@interface BottomView()
{
    UIButton * _voiceButton;
    UIButton * _calculatorButton;
    UIButton * _settingButton;
}
@end
@implementation BottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 64);
        _openState = NO;
        _voiceButton = [[UIButton alloc]init];
        _calculatorButton = [[UIButton alloc]init];
        _settingButton = [[UIButton alloc]init];
        [self setupFrameWithState:_openState];
    }
    return self;
}

- (void)setupFrameWithState:(BOOL)state
{
    // 开启状态
    if (state == YES)
    {
//        self.frame = CGRectMake(0, SCREEN_HEIGHT - 64 - 72 * 5, SCREEN_WIDTH, 72 * 5 + 64);
//        self.backgroundColor = DEF_COLOR_RGB(135, 135, 135, 1);
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(0, SCREEN_HEIGHT - 64 - 72 * 5, SCREEN_WIDTH, 72 * 5 + 64);
            self.backgroundColor = DEF_COLOR_RGB(135, 135, 135, 1);
        }];
    }
    // 关闭状态
    if (state == NO)
    {
//        self.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 64);
//        self.backgroundColor = DEF_COLOR_RGB(135, 135, 135, 1);
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 64);
            self.backgroundColor = DEF_COLOR_RGB(135, 135, 135, 1);
        }];
    }
    _openState = state;
    [self baseBottomViewFrameWithState:_openState];
}

- (void)baseBottomViewFrameWithState:(BOOL)state
{
    _calculatorButton.frame = CGRectMake(2, 2, 64 - 2 * 2, 64 - 2 * 2);
    [_calculatorButton setImage:[UIImage imageNamed:@"calculator"] forState:UIControlStateNormal];
    [_calculatorButton addTarget:self action:@selector(calculatorShow:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_calculatorButton];
    
    _voiceButton.frame = CGRectMake(64 + 3, 10, SCREEN_WIDTH - 128 - 6, 64 - 20);
    _voiceButton.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnLong:)];
    [_voiceButton addGestureRecognizer:longPress];
    [_voiceButton setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [_voiceButton.layer setMasksToBounds:YES];
    [_voiceButton.layer setCornerRadius:5.0];
    [_voiceButton.layer setBorderWidth:0.3];
    [self addSubview:_voiceButton];
    
    _settingButton.frame = CGRectMake(SCREEN_WIDTH - 64 + 2, 2, 64 - 2 * 2, 64 - 2 * 2);
    [_settingButton setImage:[UIImage imageNamed:@"cog"] forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(settingViewShow:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_settingButton];

    // 打开
    if (state == YES) {
        [self.calculatorView show];
    }
}
- (CalculatorView *)calculatorView{
    if (!_calculatorView) {
        _calculatorView = [[CalculatorView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 72*5)];
        [self addSubview:_calculatorView];
    }
    return _calculatorView;
}
- (void)calculatorShow:(UIButton *)button
{
    // 计算器开启状态 -> 关闭计算器，回收
    if (_openState == YES) {
        [self setupFrameWithState:NO];
    }
    // 计算器关闭状态 -> 打开计算器，弹出
    else if (_openState == NO) {
        [self setupFrameWithState:YES];
    }
}

- (void)settingViewShow:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(settingButtonResponse)]) {
        [self.delegate settingButtonResponse];
    }
}

- (void)btnLong:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(voiceButtonHandler:)]) {
        [self.delegate voiceButtonHandler:gestureRecognizer];
    }
}
@end
