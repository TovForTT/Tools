//
//  FTImageEditViewController.m
//

#import "FTImageEditViewController.h"
#import "UIView+BL.h"
#import "YYWebImage.h"
#import "BLCycleProgressView.h"
#import "EditOperateView.h"
#import "AlbumShowView.h"
#import "DivideView.h"
#import "ImageEditBaseView.h"
#import <UIBarButtonItem+BlocksKit.h>
#import "FTTemplateManage.h"
#import "EditPhotoOperateView.h"
#import "UIView+Extension.h"
#import "ShareViewController.h"
#import "UIImage+BL.h"
#import "FTImageScrollView.h"
#import "UIImage+YYWebImage.h"
#import "MBProgressHUD+BL.h"
#import "PreviewImageViewController.h"
#import <Social/Social.h>
#import "UIImage+QRCode.h"
#import "NSString+BL.h"
#import "LoginViewController.h"
#import "EditTextOperateView.h"
#import "UIViewController+BackButtonHandler.h"
#import <UIAlertView+BlocksKit.h>
#import <UMMobClick/MobClick.h>
#import "RedEnvelopeViewController.h"
#import "BaseNavigationController.h"
#import <IQKeyboardManager.h>

@interface FTImageEditViewController () <EditOperateViewDelegate, ImageEditBaseViewDelegate, RedEnvelopeViewControllerDelegate>
{
    UIView *bottomShowView;
    NSDictionary *needHideImageDic;
    NSDictionary *nineImageChangeDic;
    NSMutableDictionary *textParmDic;
    NSDictionary *blurImageDic;
    EditOperateView *operateView;
    UIImage *screenshotImage;
    NSString *md5Str;
    
    UIImage *mySelectImage;
    
    NSInteger nowSelectCount;
    
    UIImageView *gui;
    
    NSDictionary *saveImageRectDic;
    
    BOOL isOpenRedEnvelope;
    BOOL isRedEnvelope;
    
    NSArray *hideBtns;
    
    CGRect nowSelectHideRect;
    BOOL isHideImage;
    
    UIImageView *onePhotoHideImageView;
    UIImageView *onePhotoHideRedImageView;
    UIImage *finImage;
    
    NSString *redPacketShareUrl;
    
}
@property (nonatomic, strong) ImageEditBaseView *baseView;
@property (nonatomic, strong) NSMutableArray *clipImageArr;

@property (nonatomic, strong) NSMutableArray *saveRedEnvelopeCountArr;

@property (nonatomic, strong) AlbumShowView *showView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *imageButtonArray;



@end

@implementation FTImageEditViewController

#define UserInfoCache @"userInfoCache"

- (void)viewDidLoad {
    [super viewDidLoad];
    WK(weakSelf)
    
    nowSelectCount = 0;
    if (!self.isChangeType) {
        self.editType = EditTypeNine;
    }
    
    if (self.image) {
        mySelectImage = self.image;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:@"didLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHideBtns:) name:@"hideButtons" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRedEnvelop) name:@"closeRed" object:nil];
    
    self.title = @"编辑";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"完成" style:(UIBarButtonItemStyleDone) handler:^(UIBarButtonItem *sender) {
        
//        sender.title = @"完成";
//        sender.image = nil;

        [weakSelf complete];

    }];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (self.model) {
        [MBProgressHUD showMessage:@"模板加载中..."];
        [FTNetWorking Get:@"http://api.fentuapp.com.cn/Template/templateDetails" parmeters:@{@"id" : self.model.tid} success:^(id responseObject) {
            NSLog(@"%@", responseObject);
            if (![responseObject[@"errcode"] integerValue]) {
                self.model = [TemplateModel yy_modelWithJSON:responseObject[@"data"][0]];
                [weakSelf loadTemplate];
            }
        } failure:nil];
    } else {
        [weakSelf loadTemplate];
    }
    
    
}

- (void)complete {
    WK(weakSelf)
    if (!bottomShowView || bottomShowView.y == kScreen_Height - 64 || bottomShowView.y == kScreen_Height) {
        
        if (weakSelf.model.hideImgs.count > 0) {
            if (![BmobUser currentUser].objectId) {
                LoginViewController *loginVC = [LoginViewController new];
                [weakSelf presentViewController:loginVC animated:YES completion:nil];
                return ;
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showMessage:@"图片生成中..."];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (weakSelf.baseView.imageModules.count == 1) {
                FTImageScrollView *sv = weakSelf.baseView.imageModules.firstObject;
//                switch (weakSelf.editType) {
//                    case EditTypeOne:
//                        [weakSelf clipSingleImage:sv.image];
//                        break;
//                        
//                    default:
//                        [weakSelf clipImage:sv.image];
//                        break;
//                }
                [weakSelf clipImage:sv.image WithType:weakSelf.editType];
            } else {
                [weakSelf getNineImage];
            }
            
        });
        
    } else {
        [MobClick event:@"imageEdit_complate"];
        [bottomShowView performSelector:NSSelectorFromString(@"hide")];
        if (![bottomShowView isKindOfClass:[EditTextOperateView class]]) {
            bottomShowView = nil;
        }
    }

}

- (BOOL)navigationShouldPopOnBackButton{
    WK(weakSelf)
    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"放弃此次操作，你的编辑将丢失" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    [alertView show];
    return NO;
}


- (void)getHideBtns:(NSNotification *)noti {
    hideBtns = noti.object;
}

- (void)closeRedEnvelop {
    isRedEnvelope = NO;
    self.baseView.isRedEnvelope = NO;
}


- (void)loadGuide {
//    BOOL showEditImageGui = NO;
    BOOL showEditImageGui = [[NSUserDefaults standardUserDefaults] boolForKey:@"showEditImageGui"];
    if (!showEditImageGui) {
        gui = [[UIImageView alloc] init];
        gui.userInteractionEnabled = YES;
        gui.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clostGui)];
        [gui addGestureRecognizer:tap];
        gui.image = [UIImage imageNamed:@"edit_guide"];
        [self.view addSubview:gui];
        [[UIApplication sharedApplication].windows.lastObject addSubview:gui];
        [gui mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showEditImageGui"];
    }
}

- (void)clostGui {
    [gui removeFromSuperview];
}

- (void)didLogin {
    WK(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"图片生成中..."];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (weakSelf.baseView.imageModules.count == 1) {
            FTImageScrollView *sv = weakSelf.baseView.imageModules.firstObject;
            [weakSelf clipImage:sv.image WithType:weakSelf.editType];
        } else {
            [weakSelf getNineImage];
        }
        
    });

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [self.baseView showHideBtn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    if (isOpenRedEnvelope) {
        isOpenRedEnvelope = NO;
        return;
    }
    isRedEnvelope = NO;
    self.baseView.isRedEnvelope = NO;
    [bottomShowView removeFromSuperview];
    bottomShowView = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didLogin" object:nil];
}

- (void)gotoShare {
    [self.baseView screenshotImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        ShareViewController *shareVC = [ShareViewController new];
        shareVC.model = self.model;
        shareVC.screenshotImage = screenshotImage;
        shareVC.imageArr = self.clipImageArr;
        shareVC.shareStr = [NSString stringWithFormat:@"%@", self.model.share_text ? self.model.share_text : @""];
        shareVC.md5Str = md5Str;
        if (redPacketShareUrl) {
            shareVC.isRedpacket = YES;
            shareVC.redPacketshareUrl = redPacketShareUrl;
        }
        [self.navigationController pushViewController:shareVC animated:YES];

    });
    
    
}


//#pragma mark --- 切单图 ---
//- (void)clipSingleImage:(UIImage *)image {
//    [self.clipImageArr removeAllObjects];
//    //    CGFloat scale = [UIScreen mainScreen].scale;
//    CGFloat scale = image.scale;
//    if (![image isKindOfClass:NSClassFromString(@"YYImage")]) {
//        scale = 1;
//    }
//    
//    FTImageScrollView *sv = self.baseView.imageModules.firstObject;
//
//    CGRect clipRect = sv.imageRect;
//
//    
//    image = [image clipImageInRect:clipRect];
//    NSDictionary *dic = self.model.imgTemplates.firstObject;
//
//    NSString *imgUrl = dic[@"imgUrl"];
//    
//    UIImage *templateImage = [[YYImageCache sharedCache] getImageForKey:imgUrl];
//    
//    image = [image drawMarkImage:templateImage inRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    image = [self drawTextToImage:image count:0];
//    
//    [self.clipImageArr addObject:image];
//    [self gotoShare];
//}
#pragma mark --- 切图 ---
- (void)clipImage:(UIImage *)image WithType:(EditType)t {
    [self.clipImageArr removeAllObjects];
//    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat scale = image.scale;
    if (![image isKindOfClass:NSClassFromString(@"YYImage")]) {
        scale = 1;
    }
    
    FTImageScrollView *sv = self.baseView.imageModules.firstObject;
    
//    CGSize imageSize = image.size;
//    CGFloat showW = kScreen_Width - 30;
//    CGFloat imageSizeW = sv.imageRect.size.width;
    CGRect clipRect = sv.imageRect;
//    if (imageSize.width > imageSize.height) {
//        imageSizeW = image.size.height * scale;
//        clipRect = CGRectMake((imageSize.width * scale - imageSizeW) / 2, 0, imageSizeW, imageSizeW);
//    } else {
//        imageSizeW = image.size.width * scale;
//        clipRect = CGRectMake(0, (imageSize.height * scale - imageSizeW) / 2, imageSizeW, imageSizeW);
//    }
    
    image = [image clipImageInRect:clipRect];

    CGFloat clipW = image.size.width / 3;
    int count, num = 1;
    switch (t) {
        case EditTypeOne:
            count = 1;
            clipW = image.size.width;
            break;
        case EditTypeFour:
            count = 4;
            num = 2;
            clipW = image.size.width / 2;
            break;
            
        default:
            count = 9;
            num = 3;
            break;
    }

    
    NSDictionary *dic = self.model.imgTemplates.firstObject;
//    CGFloat templateW = [dic[@"width"] floatValue];
//    CGFloat templateH = templateW;
//    CGFloat templateX = [dic[@"pointX"] floatValue];
//    CGFloat templateY = [dic[@"pointY"] floatValue];
    NSString *imgUrl = dic[@"imgUrl"];
    
    UIImage *templateImage = [[YYImageCache sharedCache] getImageForKey:imgUrl];
    
//    CGFloat templateScale = imageSizeW / templateW;
//    templateX = templateScale * templateX;
//    templateY = templateScale * templateY;
    
    image = [image drawMarkImage:templateImage inRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    NSData *data = UIImagePNGRepresentation(image);
//    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", 11011111]];
//    [data writeToFile:file atomically:YES];
    
    
    md5Str = [NSString md5WithString:[NSString stringWithFormat:@"%@%@", self.model.objectId, [NSString timestampWithDate:[NSDate date]]]];
    for (int i = 0; i < count; i ++) {
        int x = i % num;
        int y = i / num;
        
        UIImage *clipImage = [image clipImageInRect:CGRectMake(x * clipW, y * clipW, clipW, clipW) withCount:i withScale:scale withType:self.editType];
        clipImage = [self drawTextToImage:clipImage count:i];
        if (self.model.hideImgs > 0) {
            UIImage *bigImage = [[YYImageCache sharedCache] getImageForKey:self.model.hideImgs[i]];
            
            if (bigImage) {
                UIImage *qrImage = [UIImage qrImageByContent:[NSString stringWithFormat:@"%@?uid=%@", self.model.shareUrl, md5Str]];
                clipImage = [clipImage hideimage:qrImage withOriginImage:clipImage withBigImage:bigImage];
            }
        }
        UIImage *hideImage = needHideImageDic[@(i)];
        if (hideImage) {
            clipImage = [clipImage hideimage:hideImage withOriginImage:clipImage withBigImage:nil];
        }
//        NSData *data = UIImagePNGRepresentation(clipImage);
//        NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", i]];
//        [data writeToFile:file atomically:YES];
        [self.clipImageArr addObject:clipImage];
        
        if (count == 1) {
            if (hideImage) {
                [self.clipImageArr addObject:[UIImage emptyImageWithSize:CGSizeMake(500, 500) backColor:[UIColor clearColor]]];
            }
        }
        
    }
    
    [self gotoShare];
    
        
}

- (UIImage *)drawTextToImage:(UIImage *)image count:(NSInteger)count {
    NSDictionary *dic = textParmDic[@(count)];
    if (!dic) {
        return image;
    }
    
    NSString *text = dic[@"text"];
    CGFloat fontValue = [dic[@"fontValue"] floatValue];
    if (!fontValue) {
        fontValue = 12;
    }
    UIFont *font = [UIFont fontWithName:dic[@"fontName"] size:fontValue];
    UIColor *color = dic[@"color"];
    NSTextAlignment alignment = [dic[@"alignment"] integerValue];
    CGFloat width = [dic[@"labelwidth"] floatValue];
    CGFloat imageW = [dic[@"imageWidth"] floatValue];
    NSInteger i = count % 3;
    NSInteger j = count / 3;
    CGFloat labelX = [dic[@"labelX"] floatValue] - imageW * i;
    CGFloat labelY = [dic[@"labelY"] floatValue] - imageW * j;
    switch (self.editType) {
        case EditTypeOne:
            labelX = [dic[@"labelX"] floatValue];
            labelY = [dic[@"labelY"] floatValue];
            break;
        case EditTypeFour:
            i = count % 2;
            j = count / 2;
            labelX = [dic[@"labelX"] floatValue] - imageW * i;
            labelY = [dic[@"labelY"] floatValue] - imageW * j;
            break;
            
        default:
            break;
    }
    
    CGFloat scale = image.size.width / imageW;
//    CGSize textSize = [text boundingRectWithSize:CGSizeMake(width, imageW) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    CGFloat w = [dic[@"width"] floatValue];
    CGFloat h = [dic[@"height"] floatValue];
    CGFloat textH = h * scale;
    CGFloat textW = w * scale;
    CGFloat flag = [dic[@"flag"] floatValue];
    if (flag) {
        labelY += 2;
    }
    font = [UIFont fontWithName:dic[@"fontName"] size:fontValue * scale];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = alignment;
    
    
    
    
    return [image drawText:text inRect:CGRectMake(labelX * scale, labelY * scale, textW, textH  + 1) attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : paragraphStyle}];
    
    
}

#pragma mark --- 九个小图 --- 
- (void)getNineImage {
    [self.clipImageArr removeAllObjects];
    md5Str = [NSString md5WithString:[NSString stringWithFormat:@"%@%@", self.model.objectId, [NSString timestampWithDate:[NSDate date]]]];
    for (int i = 0; i < 9; i ++) {
        UIImage *image = blurImageDic[@(i)];
        if (!image) {
            image = nineImageChangeDic[@(i)];
        }
        if (!image) {
            image = [[YYImageCache sharedCache] getImageForKey:self.model.bgUrls[i]];
        }
        NSValue *value = saveImageRectDic[@(i)];
        CGRect imageRect = value.CGRectValue;
        if (value) {
            image = [image clipImageInRect:imageRect];
        } else {
            image = [image clipImage:image];
        }
        
        if (self.model.imgTemplates.count > 1) {
            NSDictionary *dic = self.model.imgTemplates[i];
            NSString *imgUrl = dic[@"imgUrl"];
            UIImage *templateImage = [[YYImageCache sharedCache] getImageForKey:imgUrl];
            image = [image drawMarkImage:templateImage inRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        }
        
        image = [self drawTextToImage:image count:i];
        
        UIImage *hideImage = needHideImageDic[@(i)];
        if (hideImage) {
            image = [image hideimage:hideImage withOriginImage:image withBigImage:nil];
        }
        
        UIImage *bigImage = [[YYImageCache sharedCache] getImageForKey:self.model.hideImgs[i]];
        
        if (bigImage) {
            UIImage *qrImage = [UIImage qrImageByContent:[NSString stringWithFormat:@"%@?uid=%@", self.model.shareUrl, md5Str]];
            image = [image hideimage:qrImage withOriginImage:image withBigImage:bigImage];
        }

        

        
//        NSData *data = UIImagePNGRepresentation(image);
//        NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", i]];
//        [data writeToFile:file atomically:YES];
        
        [self.clipImageArr addObject:image];

    }
    
    [self gotoShare];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTemplate{
    WK(weakSelf)
    if (_model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showMessage:@"模板加载中..."];
        });
    }
    FTTemplateManage *templateManage = [FTTemplateManage templateManageWithModel:_model];
    templateManage.loadbBlock = ^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf loadGuide];
            });
            [weakSelf createDisplayView];
            [weakSelf createOpreateView];
        });
    };
    [templateManage loadTemplate];
    
}

- (void)createDisplayView{
    WK(weakSelf)
    if (_image) {
        self.baseView = [ImageEditBaseView baseVeiwWithImage:_image];
    }else{
        self.baseView = [ImageEditBaseView baseVeiwWithModel:_model];
    }
    self.baseView.editType = self.editType;
    self.baseView.delegate = self;
    self.baseView.getSelectCount = ^(NSInteger count) {
        [weakSelf sendTextParmToTextOperationView:count];
        
    };
    self.baseView.getTextParm = ^(NSDictionary *dic) {
        [weakSelf getTextParm:dic];
    };
    self.baseView.frame = CGRectMake(15, 15, kScreen_Width - 30, kScreen_Width - 30);
    
    [self.view addSubview:self.baseView];
}

- (void)sendTextParmToTextOperationView:(NSInteger)count {
    nowSelectCount = count;
    [operateView nowSelectItemTextDic:textParmDic[@(nowSelectCount)]];
    
    if (isRedEnvelope) {
        [self flyRedEnvelope];
        [self.saveRedEnvelopeCountArr addObject:@(nowSelectCount)];
    }
}

- (void)getTextParm:(NSDictionary *)dic {
    textParmDic = [NSMutableDictionary dictionaryWithDictionary:[dic copy]];
}

- (void)sendTextDicToTextOperationView {
    [self sendTextParmToTextOperationView:nowSelectCount];
}

#pragma mark --- ImageEditBaseViewDelegate ---
- (void)showTip {
    [MBProgressHUD showText:@"请选择一个照片"];
}

- (void)showHideView:(UIImage *)image {
    isOpenRedEnvelope = YES;
    PreviewImageViewController *preVC = [[PreviewImageViewController alloc] initWithImage:image];
    [self presentViewController:preVC animated:YES completion:nil];
}

- (void)getNeedHideImageDic:(NSDictionary *)dic {
    needHideImageDic = dic;
}

- (void)getNineImageChangeDic:(NSDictionary *)dic {
    nineImageChangeDic = dic;
}

- (void)getBlurImageDic:(NSDictionary *)dic {
    blurImageDic = dic;
}

- (void)getScreenshotImage:(UIImage *)image {
    screenshotImage = image;
}

- (void)clearTextDic:(NSInteger)count {
    [textParmDic removeObjectForKey:@(count)];
}

- (void)getImageRectParms:(NSDictionary *)dic {
    saveImageRectDic = [dic copy];
}

- (void)createOpreateView{
    operateView = [[EditOperateView alloc] init];
    operateView.editType = self.editType;
    if (self.model.hideImgs.count) {
        operateView.isEaster = YES;
    }
    if (self.model.bgUrls.count == 1 || self.image) {
        operateView.isOne = YES;
    }
    operateView.delegate = self;
    operateView.model = self.model;
    
    [self.view addSubview:operateView];
    [operateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
}


#pragma mark --- EditOperateViewDelegate ---

- (void)editView:(EditOperateView *)editView didSelectOperateItem:(EditOperateName)operateName
{
    self.navigationItem.rightBarButtonItem.title = nil;
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit_title_complete"];
    WK(weakSelf)
    switch (operateName) {
        case EditOperatePhoto:
        {
            [self.showView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
            [UIView animateWithDuration:0.15 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)editView:(EditOperateView *)editView didEditOperate:(EditOperateName)operateName operateParameter:(NSDictionary *)operateDict
{
    [self.baseView editImageWithParameter:operateDict];
}

- (void)selectPhoto:(UIImage *)photo {
    if (self.model.bgUrls.count != 1) {
        [self.baseView changePhoto:photo count:-1];
    } else {
        [self.baseView changePhoto:photo count:0];
    }
}

- (void)selectPhotoToHide:(UIImage *)photo {
    UIButton *btn = hideBtns[nowSelectCount];
    CGRect frame = [btn.superview.superview convertRect:btn.superview.frame toView:[UIApplication sharedApplication].keyWindow];
    if (self.editType == EditTypeOne) {
        frame = [self.view convertRect:self.baseView.frame toView:[UIApplication sharedApplication].keyWindow];
        
        if (!onePhotoHideImageView) {
            onePhotoHideImageView = [UIImageView new];
            onePhotoHideImageView.hidden = YES;
            [self.baseView addSubview:onePhotoHideImageView];
            onePhotoHideImageView.image = [UIImage imageNamed:@"edit_tibetan"];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPreImageView)];
            [onePhotoHideImageView addGestureRecognizer:tap];
            onePhotoHideImageView.userInteractionEnabled = YES;
            [onePhotoHideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.top.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
        }
    }
    
    if (photo.size.width / photo.size.height <= 2 && photo.size.height / photo.size.width <= 3) {
        finImage = nil;
        onePhotoHideRedImageView.hidden = YES;
        UIImageView *flyImageView = [[UIImageView alloc] initWithFrame:nowSelectHideRect];
        [[UIApplication sharedApplication].keyWindow addSubview:flyImageView];
        flyImageView.image = photo;
        flyImageView.contentMode = UIViewContentModeScaleAspectFill;
        flyImageView.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.4 animations:^{
            flyImageView.frame = frame;
            flyImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [flyImageView removeFromSuperview];
            onePhotoHideImageView.hidden = NO;
        }];

    }


    [self.baseView hidePhoto:photo count:-1];
    
    if (!isRedEnvelope) {
        [self.saveRedEnvelopeCountArr removeObject:@(nowSelectCount)];
        UIButton *btn = hideBtns[nowSelectCount];
        [btn setImage:[UIImage imageNamed:@"edit_tibetan"] forState:UIControlStateNormal];
    }
}

- (void)showPreImageView {
    
    [self showHideView:[self.baseView getPreImage:finImage]];
}

- (void)selectPhotoToHideRect:(CGRect)rect {
    nowSelectHideRect = rect;
}


- (void)addBottomView:(UIView *)v {
    bottomShowView = (id)v;
    [self.view addSubview:v];
    [self.baseView activateBtn:YES];
    
}

- (void)getImageBlur:(CGFloat)value {
    [self.baseView changeImageBlurWithValue:value selectImage:mySelectImage];
}

- (void)getNowSelectPhoto:(UIImage *)image {
    if (mySelectImage) {
        mySelectImage = image;
    }
}

- (void)changeTemplateModel:(TemplateModel *)model {
    WK(weakSelf)
    if (self.model == model) {
        return;
    }
    self.model = model;
    self.baseView.model = model;
    operateView.model = model;
    [textParmDic removeAllObjects];
    [MBProgressHUD showMessage:@"模板切换中..." dimBackground:NO];
    
    [FTNetWorking Get:@"http://api.fentuapp.com.cn/Template/templateDetails" parmeters:@{@"id" : self.model.tid} success:^(id responseObject) {
        NSLog(@"%@", responseObject);
        if (![responseObject[@"errcode"] integerValue]) {
            weakSelf.model = [TemplateModel yy_modelWithJSON:responseObject[@"data"][0]];
            FTTemplateManage *manager = [FTTemplateManage templateManageWithModel:_model];
            manager.loadbBlock = ^(BOOL isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    
                    [weakSelf.baseView changeTemplateModel:_model];
                });
            };
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showMessage:@"模板切换中..." dimBackground:NO];
            });
            [manager loadTemplate];
        }
    } failure:nil];
    
}

- (void)changeEditType:(EditType)t {
    if (self.editType != t) {
        self.editType = t;
        nowSelectCount = 0;
        [textParmDic removeAllObjects];
        needHideImageDic = nil;
        onePhotoHideImageView.hidden = YES;
        onePhotoHideRedImageView.hidden = YES;
        finImage = nil;
        [self.baseView changeEditType:t];
    }
    
    
}

- (void)openRedEnvelopeView {
    //TODO  用户判断
    if (!T_Token) {
        LoginViewController *loginViewController = [LoginViewController new];
        BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:loginViewController];
        [self presentViewController:navi animated:YES completion:nil];
        return;
    }
    
    isOpenRedEnvelope = YES;
    RedEnvelopeViewController *redVC = [RedEnvelopeViewController new];
    redVC.isVip = YES;
    redVC.delegate = self;
    BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:redVC];
    [self presentViewController:navi animated:YES completion:nil];
    
}

#pragma mark --- RedEnvelopeViewControllerDelegate ---
- (void)RedEnvelopeViewControllerDidComplete {
    isRedEnvelope = YES;
    self.baseView.isRedEnvelope = YES;
}

- (void)createQRCode:(NSString *)text shareUrl:(NSString *)shareUrl {
    redPacketShareUrl = shareUrl;
    UIImage *redQRCode = [UIImage qrImageWithContent:shareUrl size:269 red:0 green:0 blue:0];
//    UIImage *redQRCode = [UIImage qrImageByContent:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1179260950"];
    UIImage *bgImage = [UIImage imageNamed:@"redEnvelope"];
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:UserInfoCache];
    UIImage *avatar = [[YYImageCache sharedCache] getImageForKey:dic[@"avatar"]];
    UIGraphicsBeginImageContext(avatar.size);
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, avatar.size.width, avatar.size.height);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [avatar drawInRect:rect];
    avatar = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:40], NSForegroundColorAttributeName : [UIColor colorWithHexString:@"f6bb47"], NSParagraphStyleAttributeName : paragraphStyle};
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(700, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    [avatar drawInRect:CGRectMake(301, 91, 148, 148)];
    [redQRCode drawInRect:CGRectMake(241, bgImage.size.height - 312 - 269, 269, 269)];
    [text drawInRect:CGRectMake((750 - textSize.width) / 2, 90 + 150 + 28 + 25, textSize.width, textSize.height) withAttributes:attributes];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.baseView.redEnvelopeImage = finalImage;
    finImage = finalImage;
    
    if (self.editType == EditTypeOne) {
        needHideImageDic = @{@(0) : finalImage};
        
        if (!onePhotoHideRedImageView) {
            onePhotoHideRedImageView = [UIImageView new];
            [self.baseView addSubview:onePhotoHideRedImageView];
            onePhotoHideRedImageView.image = [UIImage imageNamed:@"edit_red"];
            onePhotoHideRedImageView.contentMode = UIViewContentModeScaleAspectFit;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPreImageView)];
            [onePhotoHideRedImageView addGestureRecognizer:tap];
            onePhotoHideRedImageView.userInteractionEnabled = YES;
            [onePhotoHideRedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.top.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
        }
        onePhotoHideRedImageView.hidden = NO;
        onePhotoHideImageView.hidden = YES;
        [bottomShowView performSelector:NSSelectorFromString(@"hide")];
        
    }
    
    
}

- (void)flyRedEnvelope {
    if ([self.saveRedEnvelopeCountArr containsObject:@(nowSelectCount)]) {
        return;
    }
    UIButton *btn = hideBtns[nowSelectCount];
    CGRect frame = [btn.superview convertRect:btn.frame toView:self.view];
//    NSLog(@"%@", NSStringFromCGRect(frame));
    
    CGFloat scale = [UIScreen mainScreen].bounds.size.height / 667;
    UIImageView *redEnvelope = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400 * scale, 35, 35)];
    redEnvelope.centerX = self.view.centerX;
    redEnvelope.image = [UIImage imageNamed:@"edit_red"];
    redEnvelope.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:redEnvelope];
    
    [UIView animateWithDuration:0.3 animations:^{
        redEnvelope.frame = frame;
    } completion:^(BOOL finished) {
        [redEnvelope removeFromSuperview];
        [btn setImage:[UIImage imageNamed:@"edit_red"] forState:UIControlStateNormal];
        btn.hidden = NO;
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    WK(weakSelf)
    [self.showView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(200);
    }];
    [UIView animateWithDuration:0.15 animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];

}

- (void)openCamera:(UIImagePickerController *)picker {
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showHudWithText:(NSString *)text {
    [MBProgressHUD showText:text];
}

#pragma mark --- Lazy load ---
- (AlbumShowView *)showView {
    if (!_showView) {
        _showView = [AlbumShowView new];
        [self.view addSubview:_showView];
        [_showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(200);
            make.height.mas_equalTo(200);
        }];
        [self.view layoutIfNeeded];

    }
    return _showView;
}

- (NSMutableArray *)clipImageArr {
    if (!_clipImageArr) {
        _clipImageArr = [NSMutableArray new];
    }
    
    return _clipImageArr;
}

- (NSMutableArray *)saveRedEnvelopeCountArr {
    if (!_saveRedEnvelopeCountArr) {
        _saveRedEnvelopeCountArr = [NSMutableArray new];
    }
    
    return _saveRedEnvelopeCountArr;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
