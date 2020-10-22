//
//  JHCQRCodeManager.h
//  JHCScanDemo
//
//  Created by mac on 2020/10/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class JHCQRCodeConfigure, JHCQRCodeManager;


NS_ASSUME_NONNULL_BEGIN


/** 二维码扫描结果回调 */
typedef void(^JHCQRCodeScanResultBlock)(JHCQRCodeManager *manager, NSString *_Nullable result);
/** 二维码扫描结果回调, 带光度强弱 */
typedef void(^JHCQRCodeScanBrightnessResultBlock)(JHCQRCodeManager *manager, CGFloat brightness);
/** 相册扫描结果回调 */
typedef void(^JHCQRCodeScanAlbumResultBlock)(JHCQRCodeManager *manager, NSString *_Nullable result);
/** 相册扫描取消回调 */
typedef void(^JHCQRCodeScanAlbumCancelResultBlock)(JHCQRCodeManager *manager);
typedef void(^VoidBlock)(void);

/**
 * 扫描工具类
 */
@interface JHCQRCodeManager : NSObject

/** 单例创建 */
+ (instancetype)sharedManager;

/** 销毁单例 */
- (void)clearAlldata;


#pragma mark -- 生成二维码
/**
 * 生成二维码
 * originString: 需要生成二维码的文字
 * QRCodesize: 二维码的大小
 */
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize;

/**
 * 生成二维码(自定义颜色)
 * originString: 需要生成二维码的文字
 * QRCodesize: 二维码的大小
 * QRCodeColor: 二维码的颜色
 * QRCodeBackgroundcolor: 二维码的背景颜色
 */
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize QRCodeColor:(UIColor *)QRCodeColor QRCodeBackgroundcolor:(UIColor *)QRCodeBackgroundcolor;

/**
 * 生成带logo的二维码
 * originString: 需要生成二维码的文字
 * QRCodesize: 二维码的大小
 * logoImage: logo
 * logoRatio: logo相对二维码的比例（取值范围 0.0 ～ 0.5f）
 */
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize logoImage:(UIImage *)logoImage logoRatio:(CGFloat)logoRatio;

/**
 * 生成带logo的二维码(扩展)
 * originString: 需要生成二维码的文字
 * QRCodesize: 二维码的大小
 * logoImage: logo
 * logoRatio: logo相对二维码的比例（取值范围 0.0 ～ 0.5f）
 * logoImageCornerRadius: logo外边框圆角（取值范围 0.0 ～ 10.0f）
 * logoImageBorderWidth: logo外边框宽度（取值范围 0.0 ～ 10.0f）
 * logoImageBorderColor: logo外边框颜色
 */
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize logoImage:(UIImage *)logoImage logoRatio:(CGFloat)logoRatio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor;



#pragma mark -- 扫描二维码
/**
 * 扫描二维码的方法
 * controller: 依赖的控制器
 * configure: 扫描的配置
 * brightnessBlock: 扫描二维码光线强弱回调方法；调用之前配置属性 sampleBufferDelegate 必须为 YES
 * scanResultBlock: 扫描二维码回调方法
 */
- (void)scanQRCodeWithController:(UIViewController *)controller configure:(JHCQRCodeConfigure *)configure scanBrightnessBlock:(JHCQRCodeScanBrightnessResultBlock)brightnessBlock scanResultBlock:(JHCQRCodeScanResultBlock)scanResultBlock;

/**
 * 开启扫描
 * breforeBlock: 开启之前的回调
 * completeBlock: 开启完成的回调
 **/
- (void)startScanningWithBreforeBlock:(VoidBlock _Nullable)breforeBlock completeBlock:(VoidBlock _Nullable)completeBlock;

/**
 * 停止扫描
 */
- (void)stopScanning;

/**
 * 播放音效文件
 */
- (void)playSoundName:(NSString *)soundName;



#pragma mark -- 相册中读取二维码

/** 是否开启相册权限 */
@property (nonatomic, assign) BOOL isPHAuthorization;

/**
 * 创建相册并获取相册授权
 * controller: 依赖的控制器
 * scanAlbumResultBlock: 扫描结果的回调
 * cancelAlbumResultBlock: 取消扫描的回调
 */
- (void)generateAuthorizationQRCodeWithAlbumWithController:(UIViewController * _Nullable)controller scanAlbumResultBlock:(JHCQRCodeScanAlbumResultBlock)scanAlbumResultBlock  cancelAlbumResultBlock:(JHCQRCodeScanAlbumCancelResultBlock)cancelAlbumResultBlock;



#pragma mark -- 手电筒

/** 打开手电筒 */
- (void)openFlashLight;

/** 关闭手电筒 */
- (void)closeFlashLight;


@end

NS_ASSUME_NONNULL_END
