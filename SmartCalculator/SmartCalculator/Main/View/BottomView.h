//
//  BottomView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorView.h"
@protocol BottomViewDelegate <NSObject>
- (void)settingButtonResponse;
- (void)voiceButtonHandler:(UILongPressGestureRecognizer *)gestureRecognizer;
@end

@interface BottomView : UIView
@property (nonatomic, assign) BOOL openState;
@property (nonatomic, strong) CalculatorView *calculatorView;
@property (nonatomic, weak) id <BottomViewDelegate>delegate;
@end
