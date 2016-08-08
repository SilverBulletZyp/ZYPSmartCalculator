//
//  CalculatorInitCourseView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorInitCourseView;
@protocol CalculatorInitCourseViewDelegate <NSObject>
- (void)initViewResponse:(NSString *)string;
- (void)removeCalculatorInitView;
@end

@interface CalculatorInitCourseView : UIView
@property (nonatomic, assign) id <CalculatorInitCourseViewDelegate> delegate;
@end
