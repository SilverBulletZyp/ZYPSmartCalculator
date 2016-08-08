//
//  CacheManager.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/15.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface CacheManager : NSObject
@property (nonatomic,strong)FMDatabase * database;
/**
 *  单例初始化
 *
 *  @return CacheManager对象
 */
+ (instancetype)shareManager;

/**
 *  创建数据库
 *
 *  @return 数据库
 */
- (FMDatabase *)dataBaseFilePath;

/**
 *  计算信息存储
 *
 *  @param database 数据库
 */
- (void)createTableForCalculatorData:(FMDatabase *)database pattern:(NSString *)partten result:(NSString *)result;

/**
 *  计算信息取出
 *
 *  @param database     数据库
 *  @param searchArray  需取字段组成的数组
 *
 *  @return 需要取出的所有信息
 */
- (NSMutableArray *)getTableForCalculatorData:(FMDatabase *)database;
/**
 *  移除数据库历史记录
 *
 *  @param index 元素在表的位置
 */
- (void)removeObjectFromTableForCalculatorData:(FMDatabase *)database index:(NSString *)indexString;

/**
 *  删除整个表
 */
- (void)removeTableFromDatabase:(FMDatabase *)database;
@end
