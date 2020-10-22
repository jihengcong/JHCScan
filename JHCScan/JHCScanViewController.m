//
//  JHCScanViewController.m
//  JHCScanDemo
//
//  Created by mac on 2020/10/21.
//

#import "JHCScanViewController.h"
#import "JHCQRScanCode.h"
#import "JHCToastHud.h"


#define kWeakSelf(weakSelf) __weak __typeof(&*self) weakSelf = self;

@interface JHCScanViewController ()

@property (nonatomic, strong) JHCQRCodeScanView *scanView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;

@end

@implementation JHCScanViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_stop) {
        [[JHCQRCodeManager sharedManager] startScanningWithBreforeBlock:nil completeBlock:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
    [self removeFlashlightBtn];
    [[JHCQRCodeManager sharedManager] clearAlldata];
}

- (void)dealloc {
    NSLog(@"WBQRCodeVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupQRCodeScan];
    [self setupNavigationBar];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
}

- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;

    JHCQRCodeConfigure *configure = [JHCQRCodeConfigure defaultConfigure];
    configure.openLog = YES;
    configure.sampleBufferDelegate = YES;
    configure.rectOfScan = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 这里只是提供了几种作为参考（共：13）；需什么类型添加什么类型即可
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    configure.metadataObjectTypes = arr;
    
    [[JHCQRCodeManager sharedManager] scanQRCodeWithController:self configure:configure scanBrightnessBlock:^(JHCQRCodeManager * _Nonnull manager, CGFloat brightness) {
//        if (brightness < - 1) {
//            [weakSelf.view addSubview:weakSelf.flashlightBtn];
//        } else {
//            if (weakSelf.isSelectedFlashlightBtn == NO) {
//                [weakSelf removeFlashlightBtn];
//            }
//        }
    } scanResultBlock:^(JHCQRCodeManager * _Nonnull manager, NSString * _Nullable result) {
        if (result) {
            [[JHCQRCodeManager sharedManager] stopScanning];
            weakSelf.stop = YES;
            
            NSString *string = [NSString stringWithFormat:@"扫描结果: %@", result];
            [JHCToastHud showTipWithMsg:string inView:nil completeBlock:^{
                [weakSelf goBack];
            }];
        }
    }];
    [[JHCQRCodeManager sharedManager] startScanningWithBreforeBlock:^{
        [JHCToastHud showLoadingWithMsg:nil inView:weakSelf.view];
    } completeBlock:^{
        [JHCToastHud hideAnimated:YES];
    }];
}

- (void)setupNavigationBar
{
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction
{
    __weak typeof(self) weakSelf = self;
    if ([JHCQRCodeManager sharedManager].isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [[JHCQRCodeManager sharedManager] generateAuthorizationQRCodeWithAlbumWithController:nil scanAlbumResultBlock:^(JHCQRCodeManager * _Nonnull manager, NSString * _Nullable result) {
        if (result == nil) {
            [JHCToastHud showTipWithMsg:@"暂未识别出二维码" inView:nil completeBlock:nil];
        } else {
            
            NSString *string = [NSString stringWithFormat:@"扫描结果: %@", result];
            [JHCToastHud showTipWithMsg:string inView:nil completeBlock:^{
                [weakSelf goBack];
            }];
        }
    } cancelAlbumResultBlock:^(JHCQRCodeManager * _Nonnull manager) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
}

- (JHCQRCodeScanView *)scanView
{
    if (!_scanView) {
        _scanView = [[JHCQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        // 静态库加载 bundle 里面的资源使用 SGQRCode.bundle/QRCodeScanLineGrid
        // 动态库加载直接使用 QRCodeScanLineGrid
//        _scanView.scanImageName = @"SGQRCode.bundle/QRCodeScanLineGrid";
        _scanView.scanImageName = @"QRCodeScanLineGrid";
        _scanView.scanAnimationStyle = JHCScanAnimatinStyle_Grid;
        _scanView.cornerLocation = JHCScanCornerLoction_Outside;
        _scanView.cornerColor = [UIColor orangeColor];
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    }
    return _promptLabel;
}

- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _flashlightBtn.backgroundColor = [UIColor whiteColor];
        CGFloat flashlightBtnW = 30;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [[JHCQRCodeManager sharedManager] openFlashLight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn {
    
    kWeakSelf(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[JHCQRCodeManager sharedManager] closeFlashLight];
        weakSelf.isSelectedFlashlightBtn = NO;
        weakSelf.flashlightBtn.selected = NO;
        [weakSelf.flashlightBtn removeFromSuperview];
    });
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self goBack];
}

- (void)goBack
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[JHCQRCodeManager sharedManager] clearAlldata];
        }];
    } else {
        [[JHCQRCodeManager sharedManager] clearAlldata];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
