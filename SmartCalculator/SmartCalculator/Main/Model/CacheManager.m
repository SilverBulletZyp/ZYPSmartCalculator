//
//  CacheManager.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/15.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#define kHistoryTable @"historyTable"
#define kInsertSql @"insert into '%@'(calculatePattern, calculateResult) values('%@', '%@');"
#define kQuerySql @"select * from '%@'"
#define kViewControllerDocument NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]

#import "CacheManager.h"
#import "CalculatorDataModel.h"

@interface CacheManager()

@end
@implementation CacheManager

/**
 *  单例初始化
 *
 *  @return MPFileManager对象
 */
+ (instancetype)shareManager
{
    static CacheManager * shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc]init];
    });
    return shareManager;
}
/**
 *  创建数据库
 *
 *  @return 数据库
 */
- (FMDatabase *)dataBaseFilePath
{
    NSString * filePath = [NSString stringWithFormat:@"%@/historyDB.db", kViewControllerDocument];
    _database = [FMDatabase databaseWithPath:filePath];
    NSLog(@"filePath = %@",filePath);
    return _database;
}
/**
 *  计算信息存储
 *
 *  @param database 数据库
 */
- (void)createTableForCalculatorData:(FMDatabase *)database pattern:(NSString *)partten result:(NSString *)result
{
    BOOL openSuccess = [database open];
    if (openSuccess) {
        BOOL createSuccess = [database executeUpdate:@"create table if not exists historyTable (ID INTEGER primary key, calculatePattern text, calculateResult text)"];
        NSLog(@"423");
        if (createSuccess) {
            NSString *insertSql = [NSString stringWithFormat:kInsertSql, kHistoryTable, partten, result];
            NSLog(@"插入表 = %@",insertSql);
            
            BOOL insertSuccess = [database executeUpdate:insertSql];
            
            if (insertSuccess) {
                [database close];
            }
            else
            {
                NSLog(@"openDB error = %@",[database lastErrorMessage]);
            }
        }
    }
    else
    {
        NSLog(@"openDB error = %@",[database lastErrorMessage]);
    }
}

/**
 *  计算信息取出
 *
 *  @param database     数据库
 *  @param searchArray  需取字段组成的数组
 *
 *  @return 需要取出的所有信息
 */
- (NSMutableArray *)getTableForCalculatorData:(FMDatabase *)database
{
    // 数组存储tableview行所对应表中的ID号
    NSMutableArray * arrayForID = [[NSMutableArray alloc]init];
    
    // 表展示计算公式与结果
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    BOOL openSuccess = [database open];
    if (openSuccess) {
        NSString * sql = [NSString stringWithFormat:kQuerySql,kHistoryTable];
        FMResultSet * set = [database executeQuery:sql];
        while ([set next]) {
            CalculatorDataModel * model = [[CalculatorDataModel alloc]init];
            model.calculatorPatternString = [set stringForColumn:@"calculatePattern"];
            model.calculatorResultString = [set stringForColumn:@"calculateResult"];
            [array addObject:model];
            
            NSString * idString = [set stringForColumn:@"ID"];
            [arrayForID addObject:idString];
            
        }
        // 将ID号数组存储至本地
        [[NSUserDefaults standardUserDefaults]setObject:arrayForID forKey:@"IDArray"];
        [database close];
    }
    else
    {
        NSLog(@"openDB error = %@",[database lastErrorMessage]);
    }
    NSLog(@"取出数据 = %@",array);
    return array;
}
/**
 *  移除数据库历史记录
 *
 *  @param index 元素在表的位置
 */
- (void)removeObjectFromTableForCalculatorData:(FMDatabase *)database index:(NSString *)indexString
{
    BOOL openSuccess = [database open];
    if (openSuccess) {
        NSString * deleteSql = [NSString stringWithFormat:@"delete from historyTable where ID = %@",indexString];
        NSLog(@"删除 = %@",deleteSql);
        
        BOOL reset = [database executeUpdate:deleteSql];
        if (reset) {
            NSLog(@"delete success");
        }
        else{
            NSLog(@"delete error");
        }
        [database close];
        
    }
    else
    {
        NSLog(@"openDB error = %@",[database lastErrorMessage]);
    }
    
}

/**
 *  删除整个表
 */
- (void)removeTableFromDatabase:(FMDatabase *)database
{
    BOOL openSuccess = [database open];
    if (openSuccess) {
        NSString * deleteSql = @"drop TABLE IF EXISTS historyTable;";
        NSLog(@"删除 = %@",deleteSql);
        
        BOOL reset = [database executeUpdate:deleteSql];
        if (!reset)
        {
            NSLog(@"Delete table error!");
        }
        NSLog(@"Delete table success!");
        
    }
    else
    {
        NSLog(@"openDB error = %@",[database lastErrorMessage]);
    }
}



@end
