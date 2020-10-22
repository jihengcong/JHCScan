//
//  JHCQRCodeManager.m
//  JHCScan
//
//  Created by mac on 2020/10/21.
//

#import "JHCQRCodeManager.h"
#import "JHCQRCodeConfigure.h"
#import <Photos/Photos.h>


#define kWeakSelf(weakSelf) __weak __typeof(&*self) weakSelf = self;

@interface JHCQRCodeManager () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *controller; // 依赖的控制器
@property (nonatomic, strong) JHCQRCodeConfigure *configure; // 配置
@property (nonatomic, strong) AVCaptureSession *captureSession; // 相机数据流

@property (nonatomic, copy) JHCQRCodeScanResultBlock scanResultBlock; // 扫描结果回调
@property (nonatomic, copy) JHCQRCodeScanBrightnessResultBlock brightnessBlock; // 光亮强度回调
@property (nonatomic, copy) JHCQRCodeScanAlbumResultBlock scanAlbumResultBlock; // 相册扫描结果回调
@property (nonatomic, copy) JHCQRCodeScanAlbumCancelResultBlock scanAlbumCancelBlock; // 相册取消扫描回调
@property (nonatomic, copy) NSString *scanResultString; // 扫描的结果

@end


@implementation JHCQRCodeManager

// 单例创建
static JHCQRCodeManager *_manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedManager
{
    dispatch_once(&onceToken, ^{
        _manager = [[JHCQRCodeManager alloc] init];
    });
    return _manager;
}

- (void)clearAlldata
{
    onceToken = 0;
}

- (void)dealloc
{
    if (_configure.openLog == YES) {
        NSLog(@"JHCScan输出: -- dealloc");
    }
}


#pragma mark -- 生成二维码
// 生成二维码
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize
{
    return [_manager generateQRCodeWithOriginString:originString QRCodesize:QRCodesize QRCodeColor:[UIColor blackColor] QRCodeBackgroundcolor:[UIColor whiteColor]];
}

// 生成二维码(自定义颜色)
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize QRCodeColor:(UIColor *)QRCodeColor QRCodeBackgroundcolor:(UIColor *)QRCodeBackgroundcolor
{
    NSData *stringData = [originString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 1.二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"]; // 照片级别
    
    // 2、颜色滤镜
    CIImage *ciImage = filter.outputImage;
    CIFilter *color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    [color_filter setValue:ciImage forKey:@"inputImage"];
    [color_filter setValue:[CIColor colorWithCGColor:QRCodeColor.CGColor] forKey:@"inputColor0"];
    [color_filter setValue:[CIColor colorWithCGColor:QRCodeBackgroundcolor.CGColor] forKey:@"inputColor1"];
    
    // 3、生成处理
    CIImage *outImage = color_filter.outputImage;
    CGFloat scale = QRCodesize / outImage.extent.size.width;
    outImage = [outImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
    return [UIImage imageWithCIImage:outImage];
}

// 生成带logo的二维码
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize logoImage:(UIImage *)logoImage logoRatio:(CGFloat)logoRatio
{
    return [_manager generateQRCodeWithOriginString:originString QRCodesize:QRCodesize logoImage:logoImage logoRatio:logoRatio logoImageCornerRadius:3 logoImageBorderWidth:3 logoImageBorderColor:[UIColor whiteColor]];
}

// 生成带logo的二维码(扩展)
- (UIImage *)generateQRCodeWithOriginString:(NSString *)originString QRCodesize:(CGFloat)QRCodesize logoImage:(UIImage *)logoImage logoRatio:(CGFloat)logoRatio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor
{
    UIImage *image = [_manager generateQRCodeWithOriginString:originString QRCodesize:QRCodesize QRCodeColor:[UIColor blackColor] QRCodeBackgroundcolor:[UIColor whiteColor]];
    
    if (logoImage == nil) return image;
    
    // 设置logo的极限比例
    if (logoRatio < 0.0 || logoRatio > 0.5) {
        logoRatio = 0.25;
    }
    CGFloat logoImageW = logoRatio * QRCodesize;
    CGFloat logoImageH = logoImageW;
    CGFloat logoImageX = 0.5 * (image.size.width - logoImageW);
    CGFloat logoImageY = 0.5 * (image.size.height - logoImageH);
    CGRect logoImageRect = CGRectMake(logoImageX, logoImageY, logoImageW, logoImageH);
    
    // 绘制logo
    UIGraphicsBeginImageContextWithOptions(image.size, false, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (logoImageCornerRadius < 0.0 || logoImageCornerRadius > 10) {
        logoImageCornerRadius = 5;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:logoImageRect cornerRadius:logoImageCornerRadius];
    if (logoImageBorderWidth < 0.0 || logoImageBorderWidth > 10) {
        logoImageBorderWidth = 5;
    }
    path.lineWidth = logoImageBorderWidth;
    [logoImageBorderColor setStroke];
    [path stroke];
    [path addClip];
    [logoImage drawInRect:logoImageRect];
    UIImage *QRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return QRCodeImage;
}



#pragma mark -- 扫描二维码
// 扫描二维码的方法
- (void)scanQRCodeWithController:(UIViewController *)controller configure:(JHCQRCodeConfigure *)configure scanBrightnessBlock:(JHCQRCodeScanBrightnessResultBlock)brightnessBlock scanResultBlock:(JHCQRCodeScanResultBlock)scanResultBlock
{
    if (controller == nil) {
        NSLog(@"JHCScan输出: -- JHCQRCodeManager 中 scanQRCodeWithController:configure:scanBrightnessBlock:scanResultBlock: 方法的 controller 不能为空");
        return;
    }
    if (configure == nil) {
        NSLog(@"JHCScan输出: -- JHCQRCodeManager 中 scanQRCodeWithController:configure:scanBrightnessBlock:scanResultBlock: 方法的 configure 不能为空");
        return;
    }
    _controller = controller;
    _configure = configure;
    
    if (brightnessBlock) _brightnessBlock = brightnessBlock;
    if (scanResultBlock) _scanResultBlock = scanResultBlock;
    
    // 获取设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 1.捕获设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (deviceInput == nil) {
        NSLog(@"JHCScan输出: -- JHCQRCodeManager 中 scanQRCodeWithController:configure:scanBrightnessBlock:scanResultBlock: 方法方法中捕获设备输入流失败");
        return;
    }
    // 2.捕获元数据输出流
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 3.设置扫描范围（每一个取值 0 ～ 1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    if (configure.rectOfScan.origin.x == 0 && configure.rectOfScan.origin.y == 0 && configure.rectOfScan.size.width == 0 && configure.rectOfScan.size.height == 0) {
    } else {
        metadataOutput.rectOfInterest = configure.rectOfScan;
    }
    
    // 4.设置会话采样率
    self.captureSession.sessionPreset = configure.sessionPreset;
    
    // 5.添加捕获元数据输出流到会话对象, 构成识别光线强弱
    [_captureSession addOutput:metadataOutput];
    if (configure.sampleBufferDelegate == YES) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        [_captureSession addOutput:videoDataOutput];
    }
    // 添加捕获设备输入流到会话对象
    [_captureSession addInput:deviceInput];
    
    // 6.设置数据输出类型，需要将数据输出添加到会话后，才能制定元数据类型，否则会报错
    metadataOutput.metadataObjectTypes = configure.metadataObjectTypes;
    
    // 7.预览图层
    AVCaptureVideoPreviewLayer *videoPreLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    // 保持纵横比, 填充层边界
    videoPreLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreLayer.frame = controller.view.frame;
    [controller.view.layer insertSublayer:videoPreLayer atIndex:0];
}

// 开启扫描
- (void)startScanningWithBreforeBlock:(VoidBlock _Nullable)breforeBlock completeBlock:(VoidBlock _Nullable)completeBlock
{
    if (breforeBlock) breforeBlock();
    
    kWeakSelf(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) completeBlock();
        });
    });
}

// 停止扫描
- (void)stopScanning
{
    if (_captureSession.isRunning) [_captureSession stopRunning];
}

// 播放音效文件
- (void)playSoundName:(NSString *)soundName
{
    // 获取静态库path
    NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:nil];
    if (!path) {
        // 动态库path获取
        path = [[NSBundle bundleForClass:[self class]] pathForResource:soundName ofType:nil];
    }
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(fileURL), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallBack, NULL);
    AudioServicesPlaySystemSound(soundID);
}
void soundCompleteCallBack(SystemSoundID soundID, void *clientData) {
    
}



#pragma mark -- 相册中读取二维码
// 创建相册并获取相册授权
- (void)generateAuthorizationQRCodeWithAlbumWithController:(UIViewController * _Nullable)controller scanAlbumResultBlock:(JHCQRCodeScanAlbumResultBlock)scanAlbumResultBlock  cancelAlbumResultBlock:(JHCQRCodeScanAlbumCancelResultBlock)cancelAlbumResultBlock
{
    if (controller == nil && _controller == nil) {
        @throw [NSException exceptionWithName:@"JHCQRCode" reason:@"JHCQRCodeManager 中 generateAuthorizationQRCodeWithAlbumWithController:scanAlbumResultBlock:cancelAlbumResultBlock: 方法的 controller 不能为空" userInfo:nil];
    }
    
    if (_controller == nil) _controller = controller;
    if (scanAlbumResultBlock) _scanAlbumResultBlock = scanAlbumResultBlock;
    if (cancelAlbumResultBlock) _scanAlbumCancelBlock = cancelAlbumResultBlock;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device)
    {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        // 用户未做选择
        if (status == PHAuthorizationStatusNotDetermined)
        {
            // 弹窗请求用户授权
            kWeakSelf(weakSelf)
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                // 用户第一次同意了访问相册权限
                if (status == PHAuthorizationStatusAuthorized)
                {
                    weakSelf.isPHAuthorization = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        // 开始选择照片
                        [weakSelf P_enterImagePickerController];
                    });
                    if (weakSelf.configure.openLog) {
                        NSLog(@"JHCScan输出: -- 用户第一次同意了访问相册权限");
                    }
                } else {
                    // 用户第一次拒绝了访问相机权限
                    if (weakSelf.configure.openLog) {
                        NSLog(@"JHCScan输出: -- 用户第一次拒绝了访问相册权限");
                    }
                }
            }];
        }
        else if (status == PHAuthorizationStatusAuthorized) // 用户允许当前应用访问相册
        {
            _isPHAuthorization = YES;
            // 开始选择照片
            [self P_enterImagePickerController];
            
            if (_configure.openLog) {
                NSLog(@"JHCScan输出: -- 用户允许访问相册权限");
            }
        }
        else if (status == PHAuthorizationStatusDenied) // 用户拒绝当前应用访问相册
        {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
            if (app_Name == nil) {
                app_Name = [infoDict objectForKey:@"CFBundleName"];
            }
            
            NSString *messageString = [NSString stringWithFormat:@"[前往：设置 - 隐私 - 照片 - %@] 允许应用访问", app_Name];
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [_controller presentViewController:alertC animated:YES completion:nil];
        }
        else if (status == PHAuthorizationStatusRestricted)
        {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [_controller presentViewController:alertC animated:YES completion:nil];
        }
    }
}

// 打开相册选择照片
- (void)P_enterImagePickerController
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [_controller presentViewController:imagePicker animated:YES completion:nil];
}



#pragma mark -- 手电筒
// 打开手电筒
- (void)openFlashLight
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch])
    {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [captureDevice unlockForConfiguration];
        }
    }
}

// 关闭手电筒
- (void)closeFlashLight
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch])
    {
        [captureDevice lockForConfiguration:nil];
        [captureDevice setTorchMode:AVCaptureTorchModeOff];
        [captureDevice unlockForConfiguration];
    }
}



#pragma mark - - AVCaptureMetadataOutputObjectsDelegate 的方法
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(nonnull NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(nonnull AVCaptureConnection *)connection
{
    NSString *resultString = nil;
    if (metadataObjects != nil && metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        resultString = obj.stringValue;
        if (_scanResultBlock) {
            _scanResultBlock(self, resultString);
        }
    }
}


#pragma mark - - AVCaptureVideoDataOutputSampleBufferDelegate 的方法
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    
    NSDictionary *metadata = [NSDictionary dictionaryWithDictionary:(__bridge  NSDictionary *)metadataDict];
    CFRelease(metadataDict);
    
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (_brightnessBlock) {
        _brightnessBlock(self, brightnessValue);
    }
}


#pragma mark - - UIImagePickerControllerDelegate 的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_controller dismissViewControllerAnimated:YES completion:nil];
    if (_scanAlbumCancelBlock) {
        _scanAlbumCancelBlock(self);
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 创建 CIDetector，并设定识别类型：CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // 获取识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count == 0) {
        kWeakSelf(weakSelf)
        [_controller dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.scanAlbumResultBlock) {
                weakSelf.scanAlbumResultBlock(weakSelf, nil);
            }
        }];
    } else {
        for (int index = 0; index < [features count]; index ++)
        {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            if (_configure.openLog == YES) {
                NSLog(@"JHCScan输出: -- 相册中读取二维码数据信息 - - %@", resultStr);
            }
            _scanResultString = resultStr;
        }
        kWeakSelf(weakSelf)
        [_controller dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.scanAlbumResultBlock) {
                weakSelf.scanAlbumResultBlock(weakSelf, weakSelf.scanResultString);
            }
        }];
    }
}



#pragma mark -- 懒加载
- (AVCaptureSession *)captureSession
{
    if (_captureSession) return _captureSession;
    _captureSession = [[AVCaptureSession alloc] init];
    return _captureSession;
}



@end
