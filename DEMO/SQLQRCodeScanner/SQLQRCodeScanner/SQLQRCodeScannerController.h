//
//  QRCodeScannerController.h
//  Iatt
//
//  Created by DOFAR on 2018/3/27.
//  Copyright © 2018年 Friends-Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>  //引用AVFoundation框架
@protocol SQLQRCodeScannerControllerDelegate <NSObject>
@optional
- (void)qrCodeScanner:(NSString *_Nullable)scanStr;
- (void)qrCodeFailed:(NSString *_Nullable)errStr;

@end
typedef void (^ SuccessScanner)(NSString* _Nullable scanStr);
typedef void (^ ErrorScanner)(NSString* _Nullable errStr);
@interface SQLQRCodeScannerController : UIViewController
@property (strong, nonatomic) SuccessScanner _Nullable succScanner;
@property (strong, nonatomic) ErrorScanner _Nullable errScanner;
@property (assign) id <SQLQRCodeScannerControllerDelegate> _Nullable delegate;

@end
