//
//  SettingView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewDelegate <NSObject>
- (void)voiceNameChange:(int)index;
@end

@interface SettingView : UIView
{
    BOOL _flagArray[1];
}
@property (nonatomic, assign) id<SettingViewDelegate>delegate;
@end
