//
//  CustomButton.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 25;
    CGFloat titleY = contentRect.size.height/2 - 13;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - 30;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
@end
