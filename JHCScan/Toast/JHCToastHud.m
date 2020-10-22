
#import "JHCToastHud.h"

#define kToastHideDuration  1.5f

typedef NS_ENUM(NSUInteger, JHCToastHUDMode) {
    /// UIActivityIndicatorView.
    JHCToastHUDModeIndeterminate,
    /// Ring-shaped progress view.
    JHCToastHUDModeAnnularDeterminate,
    // Shows a Success view.
    JHCToastHUDModeSuccess,
    // Shows a Success view.
    JHCToastHUDModeFail,
    /// Shows only labels.
    JHCToastHUDModeText
};

@implementation JHCToastHud

//单例实现
static JHCToastHud *_sharedInstance = nil;
+ (instancetype)sharedInstance
{
    if(_sharedInstance == nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [[JHCToastHud alloc] init];
        });
    }
    return _sharedInstance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    if(_sharedInstance == nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [super allocWithZone:zone];
        });
    }
    return _sharedInstance;
}

+ (void)showLoadingWithMsg:(NSString *)msg inView:(UIView *)view
{
    [self showToastLoadingWithMsg:msg mode:JHCToastHUDModeIndeterminate inView:view completeBlock:nil];
}

+ (void)showLoadingProgressWihtMsg:(NSString *)msg inView:(UIView *)view
{
    [self showToastLoadingWithMsg:msg mode:JHCToastHUDModeAnnularDeterminate inView:view completeBlock:nil];
}

+ (void)showTipWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock
{
    
    [self showToastLoadingWithMsg:msg mode:JHCToastHUDModeText inView:view completeBlock:completeBlock];
    
}

+ (void)showSuccessWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock
{
    [self showToastLoadingWithMsg:msg mode:JHCToastHUDModeSuccess inView:view completeBlock:completeBlock];
}

+ (void)showFailWithMsg:(NSString *)msg inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock
{
    
    [self showToastLoadingWithMsg:msg mode:JHCToastHUDModeFail inView:view completeBlock:completeBlock];
}

+ (void)showToastLoadingWithMsg:(NSString *)msg mode:(JHCToastHUDMode)mode inView:(UIView *)view completeBlock:(CompleteBlock)completeBlock
{
    
    __block UIView *blockView = view;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //如果已有弹框，先消失
        if ([JHCToastHud sharedInstance].hud != nil) {
            [JHCToastHud sharedInstance].hud.completionBlock = nil;
            [[JHCToastHud sharedInstance].hud hideAnimated:YES];
            [JHCToastHud sharedInstance].hud = nil;
        }
        
        //4\4s屏幕避免键盘存在时遮挡
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            [view endEditing:YES];
        }
        
        if(blockView == nil){
            blockView = [UIApplication sharedApplication].delegate.window;
//            blockView = [JHCCommonUtil getCurrentTopViewController].view;
        }
        
        [JHCToastHud sharedInstance].hud = [JHCProgressHUD showHUDAddedTo:blockView animated:YES];
        [JHCToastHud sharedInstance].hud.label.text = msg ? msg : (mode != JHCToastHUDModeIndeterminate && mode != JHCToastHUDModeAnnularDeterminate) ?  @"加载中..." : @"";
        [JHCToastHud sharedInstance].hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [JHCToastHud sharedInstance].hud.contentColor = [UIColor whiteColor];
        [JHCToastHud sharedInstance].hud.label.font = [UIFont systemFontOfSize:13];
        [JHCToastHud sharedInstance].hud.label.numberOfLines = 2;
        [JHCToastHud sharedInstance].hud.margin = 15;
        [JHCToastHud sharedInstance].hud.offset = CGPointMake(0, -44);
        [JHCToastHud sharedInstance].hud.completionBlock = completeBlock;
        
        switch (mode) {
            case JHCToastHUDModeIndeterminate:{ //菊花加载提示样式
                [JHCToastHud sharedInstance].hud.mode = JHCProgressHUDModeIndeterminate;
                [JHCToastHud sharedInstance].hud.square = msg && msg.length > 4 ? NO : YES;
            }
                break;
            case JHCToastHUDModeAnnularDeterminate:{ //进度加载提示样式
                [JHCToastHud sharedInstance].hud.mode = JHCProgressHUDModeAnnularDeterminate;
                [JHCToastHud sharedInstance].hud.square = YES;
            }
                break;
            case JHCToastHUDModeSuccess:{ //成功加载提示样式
                [JHCToastHud sharedInstance].hud.square = NO;
                [JHCToastHud sharedInstance].hud.mode = JHCProgressHUDModeCustomView;
                [JHCToastHud sharedInstance].hud.customView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                [self hideAnimated:YES afterDelay:kToastHideDuration];
            }
                break;
            case JHCToastHUDModeFail:{ //失败加载提示样式
                [JHCToastHud sharedInstance].hud.square = NO;
                [JHCToastHud sharedInstance].hud.mode = JHCProgressHUDModeCustomView;
                [JHCToastHud sharedInstance].hud.customView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                [self hideAnimated:YES afterDelay:kToastHideDuration];
            }
                break;
            case JHCToastHUDModeText:{ //文字加载提示样式
                [JHCToastHud sharedInstance].hud.square = NO;
                [JHCToastHud sharedInstance].hud.mode = JHCProgressHUDModeText;
                [self hideAnimated:YES afterDelay:kToastHideDuration];
            }
                break;
                
            default:
                break;
        }
        
    });
}


+ (void)hideAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JHCToastHud sharedInstance].hud hideAnimated:animated];
        [JHCToastHud sharedInstance].hud = nil;
    });
    
}

+ (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JHCToastHud sharedInstance].hud hideAnimated:animated afterDelay:delay];
        [JHCToastHud sharedInstance].hud = nil;
    });
}


@end
