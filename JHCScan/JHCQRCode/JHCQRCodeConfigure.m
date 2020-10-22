//
//  JHCQRCodeConfigure.m
//  JHCScan
//
//  Created by mac on 2020/10/21.
//

#import "JHCQRCodeConfigure.h"


@implementation JHCQRCodeConfigure

+ (instancetype)defaultConfigure
{
    static JHCQRCodeConfigure *_configure = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configure = [[JHCQRCodeConfigure alloc] init];
    });
    return _configure;
}

// 获取会话方式
- (NSString *)sessionPreset
{
    if (!_sessionPreset)
    {
        _sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    return _sessionPreset;
}

// 获取元对象类型
- (NSArray *)metadataObjectTypes
{
    if (!_metadataObjectTypes)
    {
        _metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    return _metadataObjectTypes;
}


@end
