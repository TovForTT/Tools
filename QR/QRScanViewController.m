//
//  QRScanViewController.m
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import "QRScanViewController.h"
#import "QRView.h"
#import "MBProgressHUD+BL.h"
#import "UIImage+BL.h"

@interface QRScanViewController () <QRViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    QRView *qrView;
}

@end

@implementation QRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavi];
    [self setupView];
    
}

- (void)setupNavi {
    self.title = @"藏红包";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openPhoto)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)openPhoto {
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.allowsEditing = YES;
    pickerC.delegate = self;
    [self presentViewController:pickerC animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    image = [image fixOrientation];
    
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    [image drawInRect:CGRectMake(0, 0, 300, 300)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    NSArray *arr = [detector featuresInImage:ciImage];
    if (arr.count) {
        CIQRCodeFeature *feature = arr.firstObject;
        if ([self.delegate respondsToSelector:@selector(scanResult:)]) {
            [self.delegate scanResult:feature.messageString];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [MBProgressHUD showText:@"未扫描到二维码"];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    qrView = [[QRView alloc] initWithFrame:self.view.frame];
    qrView.delegate = self;
    [self.view addSubview:qrView];
    
}


- (void)qrView:(QRView *)view ScanResult:(NSString *)result {
    [qrView stopScan];
    if (result) {
        if ([self.delegate respondsToSelector:@selector(scanResult:)]) {
            [self.delegate scanResult:result];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [MBProgressHUD showText:@"未扫描到二维码"];
        [qrView startScan];
    }
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
