//
//  SettingView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "SettingView.h"
#import "CacheManager.h"
#import "TTSConfig.h"
@interface SettingView()<UITableViewDelegate,UITableViewDataSource>
{
    CacheManager * _fileManager;
    int _voiceNameNum;

}
@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)UISwitch * switchButton;
@property (nonatomic,strong)UISwitch * myswitchButton;
@property (nonatomic,strong)NSArray * sectionHeaderArray;
@property (nonatomic,strong)NSArray * cellArray;
@end
@implementation SettingView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"voiceNameRecord"] == nil) {
            _voiceNameNum = 4;
        }
        else
        {
            _voiceNameNum = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"voiceNameRecord"];
        }
        
        [self setupFrame];
    }
    return self;
}
- (void)setupFrame
{
    
   
    NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"isON"] boolValue]);
    self.switchButton = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 15, 50, 40)];
    [self.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isON"] boolValue]) {
        self.switchButton.on = YES;
    }
    else
    {
        self.switchButton.on = NO;
    }
    
    TTSConfig * instance = [TTSConfig sharedInstance];
    
    self.sectionHeaderArray = @[@"语音播放",@"清除历史",@"关于我们"];
    self.cellArray = instance.vcnNickNameArray;
    
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT * 1/5)];
    [self addSubview:topView];
    
    UILabel * versionLabel = [[UILabel alloc]init];
    versionLabel.text = @"版本号";
    versionLabel.textColor = [UIColor blueColor];
    versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:versionLabel];
    NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:versionLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint * centerY = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:versionLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [topView addConstraints:@[centerX,centerY]];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64 + SCREEN_HEIGHT * 1/5, SCREEN_WIDTH, SCREEN_HEIGHT - (64 + SCREEN_HEIGHT * 1/5)) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isON"] boolValue]) {
        if (section == 0) {
            return _cellArray.count;
        }
        return 0;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = _cellArray[indexPath.row];
        if (indexPath.row == _voiceNameNum) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    sectionView.backgroundColor = DEF_COLOR_RGB(169, 169, 169, 1);
    
    UIButton * sectionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    sectionButton.tag = (int)section;
    NSLog(@"section = %d",(int)sectionButton.tag);
    [sectionButton addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 75, 30)];
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.font = [UIFont systemFontOfSize:18.0];
    sectionLabel.text = _sectionHeaderArray[section];
    
    
    [sectionButton addSubview:sectionLabel];
    [sectionView addSubview:sectionButton];
    
    
    if (section == 0) {
        [sectionView addSubview:self.switchButton];
    }

    return sectionView;
}
- (void)sectionButtonClick:(UIButton *)button
{
    int i = (int)button.tag;
    switch (i) {
        case 0:
        {
            break;
        }
        case 1:
        {
            NSLog(@"清空");
            _fileManager = [CacheManager shareManager];
            _fileManager.database = [_fileManager dataBaseFilePath];
            [_fileManager removeTableFromDatabase:_fileManager.database];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"historyRecordNotify" object:nil];
            
            break;
        }
        case 2:
        {
            break;
        }
    }
}
- (void)switchAction:(id)sender
{

    self.myswitchButton = (UISwitch*)sender;

    if (self.myswitchButton.on)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"isON"];
        [self.tableView reloadData];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isON"];
        [self.tableView reloadData];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        int num = (int)indexPath.row;
        TTSConfig *instance = [TTSConfig sharedInstance];
        instance.vcnName = instance.vcnIdentiferArray[num];
        NSLog(@"发音人为 = %@",instance.vcnName);
        
        _voiceNameNum = num;
        [[NSUserDefaults standardUserDefaults]setInteger:_voiceNameNum forKey:@"voiceNameRecord"];
        [self.tableView reloadData];
        
    }
}
@end
