//
//  CalculatorPanelView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorPanelView : UIView
@property (nonatomic, strong) UILabel * panelTopLabel;
@property (nonatomic, strong) UILabel * panelBottomLabel;
- (void)receiveNotification;
@end
