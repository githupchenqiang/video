//
//  ViewController.m
//  Thread
//
//  Created by chenq@kensence.com on 16/8/29.
//  Copyright © 2016年 chenq@kensence.com. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

{
    AVCaptureSession *session; //输入输出的中间桥梁
    BOOL _lastresult;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //创建输入流
    AVCaptureMetadataOutput *ouput = [[AVCaptureMetadataOutput alloc]init];
    
    //设置扫描区域
    ouput.rectOfInterest = CGRectMake(0.5, 0, 0.5, 1);
    //设置代理在主线程里刷新
    [ouput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化连接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:input];
    [session addOutput:ouput];
    //设置扫码支持的编码格式()
    ouput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer above:0];
    [session startRunning];

    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count >0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"%@",metadataObject.stringValue);
        
        
    }else
    {
        
    }
    
     [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:metadataObjects waitUntilDone:NO];
    
}

- (void)stop
{
    [session stopRunning];
    session = nil;
    
}
- (void)reportScanResult:(NSString *)result
{
    [self stop];
    if (!_lastresult) {
        return;
    }
    _lastresult = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"二维码扫描"
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: nil];
    [alert show];
    // 以下处理了结果，继续下次扫描
    _lastresult = YES;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
