//
//  JHCQRCodeConfigure.h
//  JHCScanDemo
//
//  Created by mac on 2020/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * 扫描配置文件
 */
@interface JHCQRCodeConfigure : NSObject

/** 单例创建 */
+ (instancetype)defaultConfigure;

/** 会话预置，默认为：AVCaptureSessionPreset1920x1080 */
@property (nonatomic, copy) NSString *sessionPreset;

/** 元对象类型，默认为：AVMetadataObjectTypeQRCode */
@property (nonatomic, strong) NSArray *metadataObjectTypes;

/** 扫描范围，默认整个视图（每一个取值 0 ～ 1，以屏幕右上角为坐标原点）*/
@property (nonatomic, assign) CGRect rectOfScan;

/** 是否需要样本缓冲代理（光线强弱），默认为：NO */
@property (nonatomic, assign) BOOL sampleBufferDelegate;

/** 打印信息，默认为：NO */
@property (nonatomic, assign) BOOL openLog;


@end


NS_ASSUME_NONNULL_END
