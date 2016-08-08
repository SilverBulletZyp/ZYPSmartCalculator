//
//  CalculatorInitCourseView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "CalculatorInitCourseView.h"
#import "CustomButton.h"

@implementation CalculatorInitCourseView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFrame];
    }
    return self;
}
- (void)setupFrame
{
    self.frame = CGRectMake(10, 160, SCREEN_WIDTH - 20, 360);
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:5.0];
    [self.layer setBorderWidth:0.1];
    
    
    NSArray * array = @[@"你可以按照以下说法使用计算器",@"\"3+5+7+9-20\"",@"\"8除以2加上3\"",@"\"6+3乘以23\"",@"\"5乘30减去20\"",@"不再提示"];
    
    for (int i = 0; i < 6; i ++) {
        
        if (i == 1|i == 2|i == 3|i == 4)
        {
            CustomButton * button = [[CustomButton alloc]initWithFrame:CGRectMake(2, 2 + i * 60, self.frame.size.width - 4, 56)];
            button.tag = i + 10;
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button titleRectForContentRect:button.frame];
            [button addTarget:self action:@selector(initButtonView:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        if (i == 0|i == 5) {
            UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(2, 2 + i * 60, self.frame.size.width - 4, 56)];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button titleRectForContentRect:button.frame];
            if (i == 5) {
                [button addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
            }
            [self addSubview:button];
        }
        
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, i * 60, self.frame.size.width, 1)];
        lineView.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
        [self addSubview:lineView];
    }

}
- (void)removeView
{
    if ([self.delegate respondsToSelector:@selector(removeCalculatorInitView)]) {
        [self.delegate removeCalculatorInitView];
    }
}
- (void)initButtonView:(UIButton *)button
{
    NSArray * array = @[@"你可以按照以下说法使用计算器",@"3+5+7+9-20",@"8除以2加上3",@"6+3乘以23",@"5乘30减去20",@"不再提示"];
    NSString * string = array[(int)button.tag - 10];
    if ([self.delegate respondsToSelector:@selector(initViewResponse:)]) {
        [self.delegate initViewResponse:string];
    }
}
@end
