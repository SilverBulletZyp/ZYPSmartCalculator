//
//  CalculatorDataModel.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/15.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "CalculatorDataModel.h"

@implementation CalculatorDataModel
+ (instancetype)share
{
    static CalculatorDataModel * _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc]init];
    });
    return _shared;
}
@end
