//
//  QRView.m
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import "QRView.h"
#import <AVFoundation/AVFoundation.h>
#import "Static.h"

@interface QRView ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation QRView

{
    AVCaptureSession *_session;
    UIImageView *_scanView;
    UIImageView *_lineView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIImage *scanImage = [UIImage imageNamed:@"角"];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat scanWH = kScreen_Width - 100;
    CGRect scanFrame = CGRectMake(width/2 - scanWH/2, height/2 - scanWH/2 - 40, scanWH, scanWH);
    self.scanViewFrame = scanFrame;
    
    _scanView = [[UIImageView alloc] initWithImage:scanImage];
    _scanView.backgroundColor = [UIColor clearColor];
    _scanView.frame = scanFrame;
    [self addSubview:_scanView];
    
    WK(weakSelf)
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf setupSession];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            [self setupSession];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            if ([self.delegate respondsToSelector:@selector(showAlert)]) {
                [self.delegate showAlert];
            }
            break;
        default:
            break;
    }
    
    
    
}



- (void)setupSession {
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //创建输出流
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    
    //设置代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    output.rectOfInterest = [self rectOfInterestByScanViewRect:_scanView.frame];
    
    //初始化连接对象
    _session = [[AVCaptureSession alloc] init];
    
    //采集率
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (input) {
        [_session addInput:input];
    }
    
    if (output) {
        [_session addOutput:output];
        
        //设置扫码支持的编码格式
        
        NSMutableArray *array = [NSMutableArray new];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [array addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [array addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [array addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [array addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = array;
    }
    
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.bounds;
    [self.layer insertSublayer:previewLayer above:0];
    [self bringSubviewToFront:_scanView];
    [self setOverView];
    [_session startRunning];
    [self loopDrawLine];
    
    
}

//设置扫描区域
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    //output的rectOfInterest属性与普通的rect不同他的x与y交换,w与h交换,而且是比例关系
    CGFloat x = (height - CGRectGetHeight(rect))/2/height;
    CGFloat y = (width - CGRectGetWidth(rect))/2/width;
    
    CGFloat w = CGRectGetHeight(rect)/height;
    CGFloat h = CGRectGetWidth(rect)/width;
    
    return CGRectMake(x, y, w, h);
}

- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y) andTag:1001];
    [self creatView:CGRectMake(0, y + h, width, height - y) andTag:1002];
    [self creatView:CGRectMake(0, y, x, h) andTag:1003];
    [self creatView:CGRectMake(x + w, y, x, h) andTag:1004];
    
    
}

- (void)creatView:(CGRect)rect andTag:(int)tag{
    CGFloat alpha = 0.5;
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.tag = tag;
    view.backgroundColor = [UIColor grayColor];
    view.alpha = alpha;
    [self addSubview:view];
}

- (void)changeViewColor:(UIColor *)color andAlpha:(CGFloat)alpha{
    for (int i = 1001; i <=1004; i++) {
        UIView *view = [self viewWithTag:i];
        view.alpha = alpha;
        view.backgroundColor = color;
    }
}

- (void)loopDrawLine {
    UIImage *lineImage = [UIImage imageNamed:@"线"];
    
    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    
    CGRect start = CGRectMake(x, y, w, 2);
    CGRect end = CGRectMake(x, y + h - 2, w, 2);
    
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:lineImage];
        _lineView.frame = start;
        [self addSubview:_lineView];
    }
    
    _lineView.frame = start;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:2 animations:^{
        _lineView.frame = end;
    } completion:^(BOOL finished) {
        [weakSelf loopDrawLine];
    }];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        if ([_delegate respondsToSelector:@selector(qrView:ScanResult:)]) {
            [_delegate qrView:self ScanResult:metadataObject.stringValue];
        }
    }
}

- (void)startScan {
    _lineView.hidden = NO;
    [_session startRunning];
}

- (void)stopScan {
    _lineView.hidden = YES;
    [_session stopRunning];
}

@end
