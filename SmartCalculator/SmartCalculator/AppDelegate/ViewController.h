//
//  ViewController.h
//  SmartCalculator
//
//  Created by 赵云鹏 on 16/3/8.
//  Copyright © 2016年 赵云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyMSC.h"
#import <AVFoundation/AVFoundation.h>
#import "PcmPlayer.h"

@class IFlyDataUploader;
@class IFlySpeechRecognizer;


//@class IFlySpeechUnderstander;
//@class IFlySpeechSynthesizer;


typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};


typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};



@interface ViewController : UIViewController<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,IFlySpeechSynthesizerDelegate>


/**
 语音听写demo
 使用该功能仅仅需要四步
 1.创建识别对象；
 2.设置识别参数；
 3.有选择的实现识别回调；
 4.启动识别
 */
@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象

@property (nonatomic, strong) NSString * result;
@property (nonatomic, assign) BOOL isCanceled;

/**
 语音理解demo
 使用该功能仅仅需要三步
 *
 1.创建语义理解对象；
 2.有选择的实现识别回调；
 3.启动语义理解
 ****/
////语音语义理解对象
//@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
//文本语义理解对象
@property (nonatomic,strong) IFlyTextUnderstander *iFlyUnderStand;
//
//@property (nonatomic, strong) NSString * result;
//@property (nonatomic, assign) BOOL isCanceled;
//
//
//// ================
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, assign) BOOL hasError;


//@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;


@end

