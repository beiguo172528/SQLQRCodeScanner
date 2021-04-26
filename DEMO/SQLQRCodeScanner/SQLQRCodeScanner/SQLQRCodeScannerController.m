//
//  QRCodeScannerController.m
//  Iatt
//
//  Created by DOFAR on 2018/3/27.
//  Copyright © 2018年 Friends-Tech. All rights reserved.
//

#import "SQLQRCodeScannerController.h"
#import "SQLCameraScanView.h"
#import "SQLCustomButton.h"
#import "NSBundle+DFBundle.h"

@interface SQLQRCodeScannerController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> //遵守AVCaptureMetadataOutputObjectsDelegate协议
@property ( strong , nonatomic ) AVCaptureDevice * device; //捕获设备，默认后置摄像头
@property ( strong , nonatomic ) AVCaptureDeviceInput * input; //输入设备
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;//输出设备，需要指定他的输出类型及扫描范围
@property ( strong , nonatomic ) AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类
@property (nonatomic, strong)UIView *scanView;//定位扫描框在哪个位置
@property ( strong , nonatomic ) SQLCustomButton *backBtn;
@end

@implementation SQLQRCodeScannerController

#pragma mark - init

- (AVCaptureDevice *)device
{
    if (_device == nil) {
        // 设置AVCaptureDevice的类型为Video类型
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        //输入设备初始化
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

#pragma mark - output

- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        //初始化输出设备
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.scanView.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        //rectOfInterest属性设置设备的扫描范围
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}

- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        //负责图像渲染出来
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat kScreen_Width = [UIScreen mainScreen].bounds.size.width;
    //定位扫描框在屏幕正中央，并且宽高为200的正方形
    self.scanView = [[UIView alloc]initWithFrame:CGRectMake((kScreen_Width-200)/2, (self.view.frame.size.height-200)/2, 200, 200)];
    [self.view addSubview:self.scanView];
    
    //设置扫描界面（包括扫描界面之外的部分置灰，扫描边框等的设置）,后面设置
    SQLCameraScanView *clearView = [[SQLCameraScanView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:clearView];
    
    [self startScan];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.backBtn removeFromSuperview];
}

- (void)popController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrCodeFailed:)]) {
        [self.delegate qrCodeFailed:@"扫描失败!"];
    }
    if (self.errScanner) {
        self.errScanner(@"扫描失败!");
    }
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)startScan
{
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];
    
    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
    //设置availableMetadataObjectTypes为二维码、条形码等均可扫描，如果想只扫描二维码可设置为
    // [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
    [self addBtns];
}

- (void)addBtns{
    CGFloat kScreen_Width = [UIScreen mainScreen].bounds.size.width;
    NSBundle *bundle = [NSBundle bundleWithBundleName:@"SQLQRCodeScanner" podName:@"SQLQRCodeScanner"];
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(choicePhoto)];
        self.backBtn = [[SQLCustomButton alloc]initWithFrame:(CGRect){0,20,60,44}
                                                  type:SQLCustomButtonLeftImageType
                                             imageSize:CGSizeMake(10, 20) midmargin:5];
        self.backBtn.isShowSelectBackgroudColor = NO;
        self.backBtn.imageView.image = [UIImage imageNamed:@"back" inBundle:bundle compatibleWithTraitCollection:nil];
        self.backBtn.backgroundColor = [UIColor clearColor];
        self.backBtn.titleLabel.text = @"";
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.backBtn touchAction:^(SQLCustomButton * _Nonnull button) {
            [self popController];
        }];
        [self.navigationController.view addSubview:self.backBtn];
        self.navigationItem.hidesBackButton = YES;
    }
    else{
        UIButton *libBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [libBtn setTitle:@"相册" forState:UIControlStateNormal];
        [libBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        libBtn.frame = CGRectMake(kScreen_Width - 70, 30, 60, 44);
        [libBtn addTarget:self action:@selector(choicePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:libBtn];
        

        self.backBtn = [[SQLCustomButton alloc]initWithFrame:(CGRect){10,30,60,44}
                                                  type:SQLCustomButtonLeftImageType
                                             imageSize:CGSizeMake(10, 20) midmargin:5];
        self.backBtn.isShowSelectBackgroudColor = NO;
        self.backBtn.imageView.image = [UIImage imageNamed:@"back" inBundle:bundle compatibleWithTraitCollection:nil];
        self.backBtn.backgroundColor = [UIColor clearColor];
        self.backBtn.titleLabel.text = @"";
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.backBtn touchAction:^(SQLCustomButton * _Nonnull button) {
            [self popController];
        }];
//        [self.navigationController.view addSubview:self.backBtn];
        [self.view addSubview:self.backBtn];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];   //停止扫描
    //我们捕获的对象可能不是AVMetadataMachineReadableCodeObject类，所以要先判断，不然会崩溃
    if (![[metadataObjects lastObject] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        [self.session startRunning];
        return;
    }
    // id 类型不能点语法,所以要先去取出数组中对象
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    if (object.stringValue == nil ){
        [self.session startRunning];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(qrCodeScanner:)]) {
            [self.delegate qrCodeScanner:object.stringValue];
        }
        if (self.succScanner) {
            self.succScanner(object.stringValue);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)choicePhoto{
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    //UIImagePickerControllerSourceTypePhotoLibrary为相册
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //设置代理UIImagePickerControllerDelegate和UINavigationControllerDelegate
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //取出选中的图片
    UIImage *pickImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    //CIDetectorTypeQRCode表示二维码，这里选择CIDetectorAccuracyLow识别速度快
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    
    //取出探测到的数据
    NSString *content = @"";
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;// 这个就是我们想要的值
    }
    if (content != nil) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(qrCodeScanner:)]) {
                [self.delegate qrCodeScanner:content];
            }
            if (self.succScanner) {
                self.succScanner(content);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
//    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
