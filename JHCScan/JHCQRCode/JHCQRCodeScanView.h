//
//  JHCQRCodeScanView.h
//  JHCScan
//
//  Created by mac on 2020/10/21.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JHCScanCornerLoction)
{
    JHCScanCornerLoction_Default  =  0, // 默认与边框同中心
    JHCScanCornerLoction_Inside,        // 在边框线内测
    JHCScanCornerLoction_Outside        // 在边框线外测
};

typedef NS_ENUM(NSUInteger, JHCScanAnimatinStyle)
{
    JHCScanAnimatinStyle_Default  =  0, // 单线扫描样式
    JHCScanAnimatinStyle_Grid           // 网格扫描样式
};


@interface JHCQRCodeScanView : UIView

/** 扫描样式，默认 JHCScanAnimatinStyle_Default */
@property (nonatomic, assign) JHCScanAnimatinStyle scanAnimationStyle;
/** 扫描线名 */
@property (nonatomic, copy) NSString *scanImageName;
/** 边框颜色，默认白色 */
@property (nonatomic, strong) UIColor *borderColor;
/** 边角位置，默认 JHCScanCornerLoction_Default */
@property (nonatomic, assign) JHCScanCornerLoction cornerLocation;
/** 边角颜色，默认微信颜色 */
@property (nonatomic, strong) UIColor *cornerColor;
/** 边角宽度，默认 2.f */
@property (nonatomic, assign) CGFloat cornerWidth;
/** 扫描区周边颜色的 alpha 值，默认 0.2f */
@property (nonatomic, assign) CGFloat backgroundAlpha;
/** 扫描线动画时间，默认 0.02s */
@property (nonatomic, assign) NSTimeInterval animationTimeInterval;

/** 添加定时器 */
- (void)addTimer;
/** 移除定时器 */
- (void)removeTimer;


@end

NS_ASSUME_NONNULL_END
