//
//  CalculatorView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    CalculatorButtonStyle1,
    CalculatorButtonStyle2
}CalculatorButtonType;

@class CalculatorView;
@protocol CalculatorViewDelegate <NSObject>
- (void)calculatorView:(CalculatorView *)view didSelected:(UIButton *)sender;

@end

@interface CalculatorView : UIView
@property (nonatomic,strong) UIButton * clearButton;
@property (nonatomic,copy) NSString * calculatePattern;//样式
@property (nonatomic,copy) NSString * calculateShowPattern;//展示样式
@property (nonatomic,copy) NSString * calculateResult;//结果
@property (nonatomic, weak) id <CalculatorViewDelegate>delegate;

- (void)show;
- (void)hide;

- (NSString *)replaceInputStrWithPassStr:(NSString *)inputStr;

@end
