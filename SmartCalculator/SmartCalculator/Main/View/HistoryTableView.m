//
//  HistoryTableView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/15.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "HistoryTableView.h"
#import "CalculatorDataModel.h"
#import "CacheManager.h"
@interface HistoryTableView()
{
    CacheManager * _fileManager;
}
@end
@implementation HistoryTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        
        self.historyArray = [[NSMutableArray alloc]init];
        [self getHistoryRecord];
        
        [self setupFrame];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:5.0];
        [self.layer setBorderWidth:0.1];
        self.delegate = self;
        self.dataSource = self;
        self.showsVerticalScrollIndicator = NO;
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(historyRecord:) name:@"historyRecordNotify" object:nil];
    }
    return self;
}

- (void)setupFrame
{
    CGFloat tabY = CGRectGetMaxY(CGRectMake(10, 30, SCREEN_WIDTH - 20, 120));
    CGFloat bottomH = 64;
    
    CGFloat height = self.historyArray.count * 50;
    if (height <= SCREEN_HEIGHT-tabY-bottomH - 40)
    {
        self.frame = CGRectMake(10, tabY + 20, SCREEN_WIDTH - 20, height);
    }
    else if (height > SCREEN_HEIGHT-tabY-bottomH - 40)
    {
        self.frame = CGRectMake(10, tabY + 20, SCREEN_WIDTH - 20, SCREEN_HEIGHT-tabY-bottomH - 40);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.historyArray.count != 0) {
        return self.historyArray.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, 50)];
        label.tag = 112;
        [cell.contentView addSubview:label];
        
    }
    
    if (self.historyArray.count != 0) {
        
        UILabel * label = (UILabel *)[cell viewWithTag:112];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:24.0];
        label.textColor = [UIColor grayColor];
        
        CalculatorDataModel * model = self.historyArray[indexPath.row];
        NSString * detailString = [NSString stringWithFormat:@"%@%@",model.calculatorPatternString,model.calculatorResultString];
        NSLog(@"detailString = %@",detailString);
        label.text = detailString;

    }
    return cell;
}
//要求委托方的编辑风格在表视图的一个特定的位置。
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    if ([tableView isEqual:self]) {
        result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
    }
    return result;
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{//设置是否显示一个可编辑视图的视图控制器。
    [super setEditing:editing animated:animated];
    [self setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row<[self.historyArray count]) {
            [self.historyArray removeObjectAtIndex:indexPath.row];//移除数据源的数据

            //移除indexPath.row在tableview中所在行对应的数据库表中的ID号
            NSMutableArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"IDArray"];
            NSString * tableNumString = array[indexPath.row];
            
            
            _fileManager = [CacheManager shareManager];
            _fileManager.database = [_fileManager dataBaseFilePath];
            [_fileManager removeObjectFromTableForCalculatorData:_fileManager.database index:tableNumString];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"historyRecordNotify" object:nil];
            
        }
    }
}


// 刷新表
- (void)historyRecord:(NSNotification *)notify
{
    NSLog(@"刷新纪录");
    [self getHistoryRecord];
    [self reloadData];
    [self setupFrame];
}
//取出数据
- (void)getHistoryRecord
{
    _fileManager = [CacheManager shareManager];
    _fileManager.database = [_fileManager dataBaseFilePath];
    self.historyArray = [_fileManager getTableForCalculatorData:_fileManager.database];
    
}
- (void)show
{
    self.alpha = 1.0;
}
- (void)hide
{
    self.alpha = 0;
}
@end
