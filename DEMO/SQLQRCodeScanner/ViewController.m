//
//  ViewController.m
//  SQLQRCodeScanner
//
//  Created by DOFAR on 2021/4/25.
//

#import "ViewController.h"
#import "SQLQRCodeScannerController.h"

@interface ViewController ()<SQLQRCodeScannerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onClickBtn:(id)sender {
    SQLQRCodeScannerController *vc = [[SQLQRCodeScannerController alloc]init];
    vc.succScanner = ^(NSString* _Nullable scanStr){
        NSLog(@"scanStr:%@",scanStr);
    };
    vc.errScanner = ^(NSString* _Nullable errStr){
        NSLog(@"errStr:%@",errStr);
    };
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)qrCodeScanner:(NSString *)scanStr{
    NSLog(@"delegate scanStr:%@",scanStr);
}

- (void)qrCodeFailed:(NSString *)errStr{
    NSLog(@"delegate errStr:%@",errStr);
}

@end
