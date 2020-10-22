
#import <Foundation/Foundation.h>
#import "JHCProgressHUD.h"


//完成的回调
typedef void(^CompleteBlock)(void);

@interface JHCToastHud : NSObject

/**
 * JHCProgressHUD对象
 */
@property (nonatomic,strong) JHCProgressHUD       *hud;

/**
 * 单例模式
 */
+ (instancetype)sharedInstance;

/**
 * 菊花样式的加载提示
 */
+ (void)showLoadingWithMsg:(NSString *)msg inView:(UIView *)view;

/**
 * 进度加载提示
 */
+ (void)showLoadingProgressWihtMsg:(NSString *)msg inView:(UIView *)view;

/**
 * 普通的文字提示
 */
+ (void)showTipWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock;
/**
 * 成功的提示
 */
+ (void)showSuccessWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock;
/**
 * 失败的提示
 */
+ (void)showFailWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock;

/**
 * 移除
 */
+ (void)hideAnimated:(BOOL)animated;

/**
 * delay秒后移除
 */
+ (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;


@end

