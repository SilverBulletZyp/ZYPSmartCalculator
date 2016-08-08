//
//  SettingViewController.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingView.h"
@implementation SettingViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self setupFrame];
}
- (void)setupFrame
{
    SettingView * settingView = [[SettingView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:settingView];
}
@end
