//
//  ViewController.m
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/8.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import "ViewController.h"
#import "BottomView.h"
#import "CalculatorPanelView.h"
#import "CalculatorInitCourseView.h"
#import "SettingViewController.h"

#import "CalculatorDetails.h"
#import "CacheManager.h"
#import "HistoryTableView.h"

#import "Definition.h"
#import <QuartzCore/QuartzCore.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"

#import "TTSConfig.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>


@interface ViewController ()<BottomViewDelegate,CalculatorInitCourseViewDelegate>
{
    CalculatorDetails *_calcultor;
    NSString * _underResultString;
    
    NSString * voiceViewShowString;
    
}
@property (nonatomic, strong) BottomView * bottomView;
@property (nonatomic, strong) CalculatorPanelView * calculatorPanelView;
@property (nonatomic, strong) CalculatorInitCourseView * calculatorInitCourseView;
@property (nonatomic, strong) HistoryTableView * historyTableView;
@property (nonatomic, strong) UIView * voiceView;;
@end


@implementation ViewController
#pragma mark - 生命周期及UI
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self initRecognizer];//语音听写
    [self initSynthesizer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
    self.automaticallyAdjustsScrollViewInsets = false;
    [self setupFrame];
    
//    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
//    _iFlySpeechUnderstander.delegate = self;
//    
//    self.uploader = [[IFlyDataUploader alloc] init];
    
    //demo录音文件保存路径
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [paths objectAtIndex:0];
//    _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
    
//    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    //uri合成路径设置
//    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
//    //pcm播放器初始化
//    _audioPlayer = [[PcmPlayer alloc] init];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
//    [_iFlySpeechUnderstander cancel];//终止语义
//    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
//    
//    if ([IATConfig sharedInstance].haveView == NO) {//无界面
//        [_iFlySpeechRecognizer cancel]; //取消识别
//        [_iFlySpeechRecognizer setDelegate:nil];
//        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
//    }
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    [super viewWillDisappear:animated];
}
- (void)setupFrame
{
    [self historyTableView];
    [self calculatorInitCourseView];
    [self calculatorPanelView];
    [self bottomView];
    
}
- (BottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[BottomView alloc] initWithFrame:self.view.frame];
        _bottomView.delegate = self;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}
- (CalculatorPanelView *)calculatorPanelView{
    if (!_calculatorPanelView) {
        _calculatorPanelView = [[CalculatorPanelView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_calculatorPanelView];
    }
    return _calculatorPanelView;
}
- (HistoryTableView *)historyTableView
{
    if (!_historyTableView) {
        _historyTableView = [[HistoryTableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _historyTableView.backgroundColor = DEF_COLOR_RGB(241, 241, 241, 1);
        [_historyTableView hide];
        [self.view addSubview:_historyTableView];
    }
    return _historyTableView;
}

// 初始教程
- (CalculatorInitCourseView *)calculatorInitCourseView
{
    if (!_calculatorInitCourseView) {
        
        _calcultor = [[CalculatorDetails alloc]init];
        
        _calculatorInitCourseView = [[CalculatorInitCourseView alloc]initWithFrame:self.view.frame];
        _calculatorInitCourseView.delegate = self;
        [self.view addSubview:_calculatorInitCourseView];
    }
    return _calculatorInitCourseView;
}
// 初始教程操作
- (void)initViewResponse:(NSString *)string
{
    
    NSLog(@"%@",string);
    [self textUnderHander:string];
    
    [self performSelector:@selector(delayReadResult) withObject:nil afterDelay:0.5f];
}

// 延迟朗读结果
- (void)delayReadResult
{
    if (_underResultString) {
        NSLog(@"%@",_underResultString);
        NSData * dataString = [_underResultString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:dataString options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dict = %@",dict);
        [self jsonMethod:dict];
    }
}
// 移除初始化教程
- (void)removeCalculatorInitView
{
    [self.calculatorInitCourseView removeFromSuperview];
    [_historyTableView show];
}

// 设置
- (void)settingButtonResponse
{
    SettingViewController * vc = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
}


#pragma mark - JSON解析
- (void)jsonMethod:(NSDictionary *)jsonDic
{
    NSLog(@"JSON解析");
    if ([jsonDic objectForKey:@"error"]) {
        [self startVoiceSynHandler:@"语音录入有误，请重新录入"];
    }
    else if ([jsonDic objectForKey:@"expression"]) {
        NSLog(@"expression = %@",jsonDic[@"expression"]);
        NSLog(@"result = %@",jsonDic[@"result"]);
        
        NSString * expressionString = [NSString stringWithFormat:@"%@=",jsonDic[@"expression"]];
        NSString * resultString = [NSString stringWithFormat:@"%@",jsonDic[@"result"]];
        
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"/" withString:@"÷"];
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"×" withString:@"x"];
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"*" withString:@"x"];
        
        // 数据库存储
        CacheManager * fileManager = [CacheManager shareManager];
        fileManager.database = [fileManager dataBaseFilePath];
        [fileManager createTableForCalculatorData:fileManager.database pattern:expressionString result:resultString];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateShowPatternNotify" object:expressionString];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateResultNotify" object:resultString];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"historyRecordNotify" object:nil];
        
        
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"-" withString:@"减"];
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"+" withString:@"加"];
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"÷" withString:@"除以"];
        expressionString = [expressionString stringByReplacingOccurrencesOfString:@"x" withString:@"乘以"];
        //expressionString = [expressionString stringByReplacingOccurrencesOfString:@"*" withString:@"乘以"];
        NSString * string = [NSString stringWithFormat:@"%@%@",expressionString,jsonDic[@"result"]];
        
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isON"] boolValue]) {
            // 语音合成
            [self startVoiceSynHandler:string];
        }
        else
        {
            
        }
    }
}


#pragma mark - 语音听写模块
- (void)voiceButtonHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSLog(@"长按事件");
        self.isCanceled = NO;
        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {

        }else{

        }
        
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        NSLog(@"取消事件");
        [_iFlySpeechRecognizer stopListening];
    }
}
/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            [_iFlySpeechRecognizer setParameter:@"1" forKey:@"cua"];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            //[_iFlySpeechRecognizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
            //VOICE_NAME
        }
    }
    NSLog(@"识别参数");
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    NSLog(@"听写结果回调 = %@",dic);
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSLog(@"resultString = %@",resultString);
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    NSLog(@"resultFromJson = %@",resultFromJson);
    
//    if (isLast){
//        NSLog(@"听写结果(json)：%@测试",  self.result2);
//    }
//    
//    NSLog(@"听写结果：%@",resultFromJson);
//
//
    
    
    resultFromJson = [resultFromJson stringByReplacingOccurrencesOfString:@"-" withString:@"减"];
    resultFromJson = [resultFromJson stringByReplacingOccurrencesOfString:@"+" withString:@"加"];
    resultFromJson = [resultFromJson stringByReplacingOccurrencesOfString:@"÷" withString:@"除以"];
    resultFromJson = [resultFromJson stringByReplacingOccurrencesOfString:@"×" withString:@"乘以"];
    
    
    [self textUnderHander:resultFromJson];
    
    [self performSelector:@selector(delayReadResult) withObject:nil afterDelay:0.5f];
    
}
- (void)onResult:(NSArray *)resultArray isLast:(BOOL) isLast;
{
    NSLog(@"onresult =============");
}

/**
 写入音频流线程
 ****/
- (void)sendAudioThread
{
    NSLog(@"%s[IN]",__func__);
    NSData *data = [NSData dataWithContentsOfFile:_pcmFilePath];    //从文件中读取音频
    
    int count = 10;
    unsigned long audioLen = data.length/count;
    
    
    for (int i =0 ; i< count-1; i++) {    //分割音频
        char * part1Bytes = malloc(audioLen);
        NSRange range = NSMakeRange(audioLen*i, audioLen);
        [data getBytes:part1Bytes range:range];
        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
        
        int ret = [self.iFlySpeechRecognizer writeAudio:part1];//写入音频，让SDK识别
        free(part1Bytes);
        
        
        if(!ret) {     //检测数据发送是否正常
            NSLog(@"%s[ERROR]",__func__);
            [self.iFlySpeechRecognizer stopListening];
            
            return;
        }
    }
    
    //处理最后一部分
    unsigned long writtenLen = audioLen * (count-1);
    char * part3Bytes = malloc(data.length-writtenLen);
    NSRange range = NSMakeRange(writtenLen, data.length-writtenLen);
    [data getBytes:part3Bytes range:range];
    NSData * part3 = [NSData dataWithBytes:part3Bytes length:data.length-writtenLen];
    
    [_iFlySpeechRecognizer writeAudio:part3];
    free(part3Bytes);
    [_iFlySpeechRecognizer stopListening];//音频数据写入完成，进入等待状态
    NSLog(@"%s[OUT]",__func__);
}


#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        //[_popUpView removeFromSuperview];
        return;
    }
    
    //NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    //[_popUpView showText: vol];
}
/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
    
    self.voiceView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 4, self.view.frame.size.height / 3, self.view.frame.size.width / 2, 90)];
    self.voiceView.backgroundColor = [UIColor blackColor];
    [self.voiceView.layer setMasksToBounds:YES];
    [self.voiceView.layer setCornerRadius:5.0];
    [self.voiceView.layer setBorderWidth:0.1];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, self.voiceView.frame.size.width - 20, self.voiceView.frame.size.height - 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:26.0];
    label.text = @"正在录音";
    label.textColor = [UIColor whiteColor];
    [self.voiceView addSubview:label];
    [self.view addSubview:self.voiceView];
    
    //[_popUpView showText: @"正在录音"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    [self.voiceView removeFromSuperview];
    //[_popUpView showText: @"停止录音"];
}
/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        
        if (self.isCanceled) {
            text = @"识别取消";
            
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            }else {
                text = @"识别成功";
            }
        }else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        
        //[_popUpView showText: text];
        
    }else {
        //[_popUpView showText:@"识别结束"];
        NSLog(@"errorCode:%d",[error errorCode]);
    }
    
    
}




//#pragma mark - 语音理解
//- (void)voiceRecognizerStart
//{
//    //设置为麦克风输入语音
//    [_iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
//    
//    bool ret = [_iFlySpeechUnderstander startListening];
//    
//    if (ret) {
//        
//        self.isCanceled = NO;
//    }
//    else
//    {
//        NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束
//    }
//}
//- (void)voiceRecognizerCancel
//{
//    [_iFlySpeechUnderstander stopListening];
//}

///**
// 开始识别回调
// ****/
//- (void) onBeginOfSpeech
//{
//    NSLog(@"正在录音");
//}
//
///**
// 停止录音回调
// ****/
//- (void) onEndOfSpeech
//{
//    NSLog(@"停止录音");
//}
//

///**
// 语义理解服务结束回调（注：无论是否正确都会回调）
// error.errorCode =
// 0     听写正确
// other 听写出错
// ****/
//- (void) onError:(IFlySpeechError *) error
//{
//    NSLog(@"%s",__func__);
//    
//    NSString *text ;
//    if (self.isCanceled) {
//        text = @"语义理解取消";
//    }
//    else if (error.errorCode ==0 ) {
//        if (_result.length==0) {
//            text = @"无识别结果";
//        }
//        else
//        {
//            text = @"识别成功";
//        }
//    }
//    else
//    {
//        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
//        NSLog(@"%@",text);
//    }
//
//}
//
//
///**
// 语义理解结果回调
// result 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
// isLast：表示最后一次
// ****/
//- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
//{
//    NSMutableString *result = [[NSMutableString alloc] init];
//    NSDictionary *dic = results [0];
//    
//    NSLog(@"dic = %@",dic);
//
//    
//    for (NSString *key in dic) {
//        [result appendFormat:@"%@",key];
//    }
//    
//    NSLog(@"听写结果：%@",result);
//    NSData * dataString = [result dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:dataString options:NSJSONReadingMutableContainers error:nil];
//
//    NSLog(@"dict = %@",dict);
//    
//    _result = result;
//    [self jsonMethod:dict];
//
//}
///**
// 设置识别参数
// ****/
//-(void)initRecognizer
//{
//    //语义理解单例
//    if (_iFlySpeechUnderstander == nil) {
//        _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
//        [_iFlySpeechUnderstander setParameter:@"1" forKey:@"cua"];
//    }
//    
//    _iFlySpeechUnderstander.delegate = self;
//    
//    if (_iFlySpeechUnderstander != nil) {
//        IATConfig *instance = [IATConfig sharedInstance];
//        
//        //参数意义与IATViewController保持一致，详情可以参照其解释
//        [_iFlySpeechUnderstander setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
//        [_iFlySpeechUnderstander setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
//        [_iFlySpeechUnderstander setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
//        [_iFlySpeechUnderstander setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
//        [_iFlySpeechUnderstander setParameter:@"1" forKey:@"cua"];
//        
//        if ([instance.language isEqualToString:[IATConfig chinese]]) {
//            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
//            [_iFlySpeechUnderstander setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
//        }else if ([instance.language isEqualToString:[IATConfig english]]) {
//            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
//        }
//        [_iFlySpeechUnderstander setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
//    }
//}
///**
//  取消回调
//  当调用了[_iFlySpeechUnderstander cancel]后，会回调此函数，
//  ****/
//- (void) onCancel
//{
//    NSLog(@"识别取消");
//}


#pragma mark - 文本理解
- (void)textUnderHander:(NSString *)string
{
    if(self.iFlyUnderStand == nil)
    {
        self.iFlyUnderStand = [[IFlyTextUnderstander alloc] init];
    }
    
    //启动文本语义搜索
    [self.iFlyUnderStand understandText:string withCompletionHandler:^(NSString* restult, IFlySpeechError* error)
     {
         NSLog(@"result is : %@",restult);
         _underResultString = restult;
         if (error!=nil && error.errorCode!=0) {
             
             NSString* errorText = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
             _underResultString = errorText;
         }
     }];
}
//
//
#pragma mark - 语音合成
- (void)startVoiceSynHandler:(NSString *)resultString
{
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    _synType = NomalType;
    
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    self.isCanceled = NO;
    
    _iFlySpeechSynthesizer.delegate = self;
    [_iFlySpeechSynthesizer startSpeaking:resultString];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
    
    
}



/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    //[_inidicateView hide];
    self.isCanceled = NO;
    if (_state  != Playing) {
        //[_popUpView showText:@"开始播放"];
    }
    
    
    _state = Playing;
}

/**
 缓冲进度回调
 
 progress 缓冲进度
 msg 附加信息
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
//    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 播放进度回调
 
 progress 缓冲进度
 
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakProgress:(int) progress
{
//    NSLog(@"speak progress %2d%%.", progress);
}


/**
 合成暂停回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakPaused
{
//    [_inidicateView hide];
//    [_popUpView showText:@"播放暂停"];
//    
//    _state = Paused;
}



/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakResumed
{
//    [_popUpView showText:@"播放继续"];
//    _state = Playing;
}

/**
 合成结束（完成）回调
 
 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    
//    if (error.errorCode != 0) {
//        [_inidicateView hide];
//        [_popUpView showText:[NSString stringWithFormat:@"错误码:%d",error.errorCode]];
//        return;
//    }
//    NSString *text ;
//    if (self.isCanceled) {
//        text = @"合成已取消";
//    }else if (error.errorCode == 0) {
//        text = @"合成结束";
//    }else {
//        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
//        self.hasError = YES;
//        NSLog(@"%@",text);
//    }
//    
//    [_inidicateView hide];
//    [_popUpView showText:text];
//    
//    _state = NotStart;
//    
//    if (_synType == UriType) {//Uri合成类型
//        
//        NSFileManager *fm = [NSFileManager defaultManager];
//        if ([fm fileExistsAtPath:_uriPath]) {
//            [self playUriAudio];//播放合成的音频
//        }
//    }
}

///**
// 开始uri合成
// ****/
//- (void)uriSynthesizeBtnHandler:(NSString *)resultString
//{
//    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
//        [_audioPlayer stop];
//    }
//    
//    _synType = UriType;
//    
//    self.hasError = NO;
//    
//    [NSThread sleepForTimeInterval:0.05];
//    
//    
//    self.isCanceled = NO;
//    
//    _iFlySpeechSynthesizer.delegate = self;
//    
//    [_iFlySpeechSynthesizer synthesize:resultString toUri:_uriPath];
//    if (_iFlySpeechSynthesizer.isSpeaking) {
//        _state = Playing;
//    }
//}


/**
 取消合成回调
 ****/
- (void)onSpeakCancel
{
//    if (_isViewDidDisappear) {
//        return;
//    }
//    self.isCanceled = YES;
//    
//    if (_synType == UriType) {
//        
//    }else if (_synType == NomalType) {
//        [_inidicateView setText: @"正在取消..."];
//        [_inidicateView show];
//    }
//    
//    [_popUpView removeFromSuperview];
    
}


#pragma mark - 设置语音合成参数
- (void)initSynthesizer
{
    NSLog(@"%s",__func__);
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    //[_iFlySpeechSynthesizer setParameter:@"1" forKey:@"cua"];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"voiceNameRecord"] == nil) {
        int voiceNameNum = 4;
        instance.vcnName = instance.vcnIdentiferArray[voiceNameNum];
    }
    else
    {
        int voiceNameNum = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"voiceNameRecord"];
        instance.vcnName = instance.vcnIdentiferArray[voiceNameNum];
    }
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"calculateResultNotify" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"calculateShowPatternNotify" object:nil];
}

@end
