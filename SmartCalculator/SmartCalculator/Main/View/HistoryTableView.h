//
//  HistoryTableView.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/15.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableView : UITableView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray * historyArray;
- (void)show;
- (void)hide;
@end
