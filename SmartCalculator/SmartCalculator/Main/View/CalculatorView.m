//
//  CalculatorView.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/11.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "CalculatorView.h"
#import "CalculatorDetails.h"
#import "CacheManager.h"
@interface CalculatorView()
{
    BOOL _flag; // YES:清零或完成计算
    
    // buttonAttributeTitle
    NSDictionary * _attributesDic;
    NSAttributedString * _attributeText;
    
    // 存放按钮数组
    NSArray * _buttonArray;
    
    // 存放按钮对应tag字典
    NSMutableDictionary * _buttonTagDictionary;
    
    // 可直接识别的tag部分归为数组
    NSArray * _buttonNumArray;
    
    NSMutableArray  *_operators;
    BOOL _error;
    
    CalculatorDetails *_calcultor;
}
@end
@implementation CalculatorView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.calculateShowPattern = [[NSString alloc]init];
        _calcultor = [[CalculatorDetails alloc]init];
        _flag = YES;
        _error = NO;
        _operators = [NSMutableArray array];
        self.alpha = 0;
        
        /**
         *  关于button.tag
         *
         *   0:AC,   1:<-,   2:%,   3:÷
         *   4:7,    5:8,    6:9,   7:×
         *   8:4,    9:5,   10:6,  11:-
         *  12:1,   13:2,   14:3,  15:+
         *  16:0,   17:.,   18:=
         */
        
        _attributesDic = [[NSDictionary alloc]init];
        _buttonArray = @[@"AC",@"<-",@"%",@"÷",
                         @"7",@"8",@"9",@"x",
                         @"4",@"5",@"6",@"-",
                         @"1",@"2",@"3",@"+",
                         @"0",@".",@"="];
        // 直接识别tag部分：4、5、6、8、9、10、11、12、13、14、15、16、17
        _buttonNumArray = @[@"4",@"5",@"6",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17"];
        
        _buttonTagDictionary = [[NSMutableDictionary alloc]init];
        for (int i = 0; i < 19; i ++) {
            [_buttonTagDictionary setObject:_buttonArray[i] forKey:[NSString stringWithFormat:@"%d",i]];
        }
        [self setupFrame];
    }
    return self;
}
- (void)setupFrame
{
    
    CGFloat width = SCREEN_WIDTH / 4;
    CGFloat height = 72.0;
    
    self.clearButton = [[UIButton alloc]init];
    self.clearButton.frame = CGRectMake(0, 0, width, height);
    self.clearButton.backgroundColor = DEF_COLOR_RGB(27, 31, 35, 1);
    self.clearButton.tag = 0;
    [self.clearButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.clearButton.layer setBorderWidth:1.0];
    [self.clearButton setTitle:_buttonArray[0] forState:UIControlStateNormal];
    [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(calculatorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setAttributedTitle:[self buttonTitleAttributeControl:CalculatorButtonStyle2 buttonTitle:self.clearButton.titleLabel.text] forState:UIControlStateNormal];
    [self addSubview:self.clearButton];
    
    for (int i = 1; i < 19; i++) {
        
        int x = i%4;
        int y = i/4;
        
        UIButton * button = [[UIButton alloc]init];
        button.frame = CGRectMake(x * width, y * height, width, height);
        button.backgroundColor = DEF_COLOR_RGB(27, 31, 35, 1);
        button.tag = i;
        [button.layer setBorderColor:[UIColor blackColor].CGColor];
        [button.layer setBorderWidth:1.0];
        [button setTitle:_buttonArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(calculatorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (i == 16) {
            button.frame = CGRectMake(x * width, y * height, width * 2, height);
        }
        if (i == 17|i == 18) {
            button.frame = CGRectMake((x+1) * width, y * height, width, height);
        }
        
        if (i == 1|i == 2|i == 3|i == 7|i == 11|i == 15|i ==18) {
            [button setAttributedTitle:[self buttonTitleAttributeControl:CalculatorButtonStyle2 buttonTitle:button.titleLabel.text] forState:UIControlStateNormal];
        }
        if (i == 4|i == 5|i == 6|i == 8|i == 9|i == 10|i == 12|i == 13|i == 14|i == 16|i == 17) {
            [button setAttributedTitle:[self buttonTitleAttributeControl:CalculatorButtonStyle1 buttonTitle:button.titleLabel.text] forState:UIControlStateNormal];
        }
        
        [self addSubview:button];
    }
}

- (NSAttributedString *)buttonTitleAttributeControl:(CalculatorButtonType)buttonType buttonTitle:(NSString *)title
{
    switch (buttonType) {
        case CalculatorButtonStyle1:
        {
            _attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:27.0]};
            break;
        }
        case CalculatorButtonStyle2:
        {
            _attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:27.0],NSForegroundColorAttributeName:[UIColor orangeColor]};
            break;
        }
    }
    _attributeText = [[NSAttributedString alloc]initWithString:title attributes:_attributesDic];
    return _attributeText;
}

- (void)calculatorButtonClick:(UIButton *)button
{
    switch (button.tag)
    {
        case 0:// AC
        {
            self.calculateShowPattern = [NSString stringWithFormat:@"0"];
            self.calculateResult = [NSString stringWithFormat:@"0"];
            [self.clearButton setAttributedTitle:[self buttonTitleAttributeControl:CalculatorButtonStyle2 buttonTitle:@"AC"] forState:UIControlStateNormal];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateResultNotify" object:self.calculateResult];
            _flag = YES;
            break;
        }
        case 1:// <-
        {
            NSUInteger calculateShowPatternLength = [self.calculateShowPattern length];
            if (calculateShowPatternLength == 0) {
                return;
            }
            NSRange showPatternRange = {0,calculateShowPatternLength - 1};
            self.calculateShowPattern = [self.calculateShowPattern substringWithRange:showPatternRange];
            NSLog(@"展示公式 = %@",self.calculateShowPattern);
            break;
        }
        case 2:// %
        {
            self.calculateShowPattern = [self.calculateShowPattern stringByAppendingString:@"%"];
            NSLog(@"展示公式 = %@",self.calculateShowPattern);
            break;
        }
        case 3:// ÷
        {
            self.calculateShowPattern = [self.calculateShowPattern stringByAppendingString:@"÷"];
            NSLog(@"展示公式 = %@",self.calculateShowPattern);
            break;
        }
        case 7:// ×
        {
            self.calculateShowPattern = [self.calculateShowPattern stringByAppendingString:@"x"];
            NSLog(@"展示公式 = %@",self.calculateShowPattern);
            break;
        }
        case 18:// =
        {
            if ([self.calculateShowPattern isEqualToString:@"0"]|[self.calculateShowPattern isEqualToString:@""]|self.calculateShowPattern == nil){
                
            }
            else
            {
                NSString * tempString = [self replaceInputStrWithPassStr:self.calculateShowPattern];
                self.calculateShowPattern = [self.calculateShowPattern stringByAppendingString:@"="];
                NSLog(@"临时 = %@",tempString);
                NSString * result = [_calcultor calculatingWithString:tempString andAnswerString:@"0"];
                NSLog(@"结果为 = %@",result);
                _flag = YES;
//if(!_error) {
//    
//    //_calculatePanel.text = [NSString stringWithFormat:@"=%@", result];
//    //BOOL flag = [self insertHistory:_calculateShowPattern result:result];
//    
//    if (!_flag) {
//        NSAssert(!_flag, @"数据插入失败");
//    }
//}else {
//    //_calculatePanel.text = [NSString stringWithFormat:@"%@", @"您的输入有误"];
//    _error = NO;
//}
                
                if ([result isEqualToString:@"error"]) {
                    result = @"您的输入有误";
                }
                self.calculateResult = result;
                NSLog(@"最终展示结果为 = %@",self.calculateResult);
                
                
                // 数据库
                CacheManager * fileManager = [CacheManager shareManager];
                fileManager.database = [fileManager dataBaseFilePath];
                [fileManager createTableForCalculatorData:fileManager.database pattern:self.calculateShowPattern result:self.calculateResult];
                
                // 通知
                [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateResultNotify" object:self.calculateResult];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateShowPatternNotify" object:self.calculateShowPattern];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"historyRecordNotify" object:nil];
                
            }
            return;
        }
        default:
        {
            NSString * string = [_buttonTagDictionary objectForKey:[NSString stringWithFormat:@"%d",(int)button.tag]];
            if (_flag)
            {
                NSLog(@"flag");
                self.calculateShowPattern = [NSString stringWithFormat:@"%@",string];
                NSLog(@"展示公式 = %@",self.calculateShowPattern);
                
//[self.clearButton setAttributedTitle:[self buttonTitleAttributeControl:CalculatorButtonStyle1 buttonTitle:@"C"] forState:UIControlStateNormal];
                _flag = NO;
            }
            else
            {
                self.calculateShowPattern = [NSString stringWithFormat:@"%@%@",self.calculateShowPattern,string];
                NSLog(@"展示公式 = %@",self.calculateShowPattern);
            }
        }
            break;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateShowPatternNotify" object:self.calculateShowPattern];
}

#pragma - mark Utility Methods
- (NSString *)replaceInputStrWithPassStr:(NSString *)inputStr{
    NSString *tempString = inputStr;
    //将字符串长度大于1的运算符换成单字符，以便后面的操作
    if (!([tempString rangeOfString:@"sin"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"sin" withString:@"s"];
    }
    if (!([tempString rangeOfString:@"cos"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"cos" withString:@"c"];
    }
    if (!([tempString rangeOfString:@"tan"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"tan" withString:@"t"];
    }
    if (!([tempString rangeOfString:@"log"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"log" withString:@"l"];
    }
    if (!([tempString rangeOfString:@"ln"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"ln" withString:@"e"];
    }
    //替换根号符，由于根号符编码超过了unichar，所以换成字母
    if (!([tempString rangeOfString:@"√"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"√" withString:@"g"];
    }
    //替换除号，由于除号编码超过了unichar，所以换成字母
    if (!([tempString rangeOfString:@"÷"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"÷" withString:@"d"];
    }
    //将Ans换成上一次答案，若上一次出错或者为空，则使其置0
//    if (!([tempString rangeOfString:@"Ans"].location == NSNotFound)) {
//        if ([_lastAnswer isEqualToString:@"error"]||[_lastAnswer isEqualToString:@""]) {
//            tempString = [tempString stringByReplacingOccurrencesOfString:@"Ans" withString:@"0"];
//        } else {
//            tempString = [tempString stringByReplacingOccurrencesOfString:@"Ans" withString:[NSString stringWithFormat:@"%g",[_lastAnswer doubleValue]]];
//        }
//    }
    return tempString;
}
- (void)show{
    self.alpha = 1.0;
}
- (void)hide{
    self.alpha = 0;
}
@end
