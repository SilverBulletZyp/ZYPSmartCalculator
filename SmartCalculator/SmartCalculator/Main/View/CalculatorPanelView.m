//
//  CalculatorPanelView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "CalculatorPanelView.h"

@implementation CalculatorPanelView
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
    self.frame = CGRectMake(10, 30, SCREEN_WIDTH - 20, 120);
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:5.0];
    [self.layer setBorderWidth:0.1];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(80, 60, self.frame.size.width - 80, 1)];
    lineView.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
    [self addSubview:lineView];
    
    self.panelTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, self.frame.size.width - 20, self.frame.size.height / 2 - 4)];
    self.panelTopLabel.textAlignment = NSTextAlignmentRight;
    self.panelTopLabel.font = [UIFont systemFontOfSize:28.0];
    self.panelTopLabel.textColor = [UIColor grayColor];
    self.panelTopLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.panelTopLabel];
    
    self.panelBottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 62, self.frame.size.width - 20, self.frame.size.height / 2 - 4)];
    self.panelBottomLabel.textAlignment = NSTextAlignmentRight;
    self.panelBottomLabel.font = [UIFont systemFontOfSize:32.0];
    self.panelBottomLabel.textColor = [UIColor blackColor];
    self.panelBottomLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.panelBottomLabel];
    
    [self receiveNotification];
    
}

- (void)receiveNotification
{
    // 接收通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resultChange:) name:@"calculateResultNotify" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showPatternChange:) name:@"calculateShowPatternNotify" object:nil];
}
- (void)showPatternChange:(NSNotification *)notify
{
    self.panelTopLabel.text = notify.object;
    NSLog(@"show = %@",notify.object);
}
- (void)resultChange:(NSNotification *)notify
{
    self.panelBottomLabel.text = notify.object;
    NSLog(@"bottom = %@",notify.object);
}

@end
