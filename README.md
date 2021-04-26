# SQLQRCodeScanner


<img style="float:left" src="https://github.com/beiguo172528/SQLQRCodeScanner/blob/main/images/IMG_0205.PNG" width="30%" height="30%">
<img style="float:left" src="https://github.com/beiguo172528/SQLQRCodeScanner/blob/main/images/IMG_0206.PNG" width="30%" height="30%">

使用方法：

pod 'SQLQRCodeScanner'

1.在info.plist 在添加权限
<key>NSCameraUsageDescription</key>
<string>是否允许使用你的相机？</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>是否允许使用你的相册?</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>是否允许使用你的相册?</string>

2.import
#import "SQLQRCodeScannerController.h"

3.创建
SQLQRCodeScannerController *vc = [[SQLQRCodeScannerController alloc]init];

4.扫描返回
【1】.第一种
vc.succScanner = ^(NSString* _Nullable scanStr){
NSLog(@"scanStr:%@",scanStr);
};
vc.errScanner = ^(NSString* _Nullable errStr){
NSLog(@"errStr:%@",errStr);
};
【2】.第二种 delegate    <SQLQRCodeScannerControllerDelegate>
vc.delegate = self;

- (void)qrCodeScanner:(NSString *)scanStr{
    NSLog(@"delegate scanStr:%@",scanStr);
}

- (void)qrCodeFailed:(NSString *)errStr{
    NSLog(@"delegate errStr:%@",errStr);
}

5.弹出ViewController
【1】.没有navigationController
vc.modalPresentationStyle = UIModalPresentationFullScreen;
[self presentViewController:vc animated:YES completion:nil];
【2】.有navigationController
[self.navigationController pushViewController:vc animated:YES];


连接：
Github:https://github.com/beiguo172528/SQLQRCodeScanner
简书：https://www.jianshu.com/p/b86b405a6c80
