//
//  FTTemplateManage.m
//

#import "FTTemplateManage.h"
#import "YYWebImage.h"
#import "UIImage+BL.h"
#import "Static.h"
#import "NSString+BL.h"
#import "UIImage+QRCode.h"

@implementation FTTemplateManage{
    TemplateModel *_model;
}
+ (instancetype)templateManageWithModel:(TemplateModel *)model{
    FTTemplateManage *manage = [[FTTemplateManage alloc] init];
    manage->_model = model;
    return manage;
}

- (void)loadTemplate{
    static int i = 0;
    static int j = 0;
    static int t = 0;
    
    if (_model.bgUrls && _model.bgUrls.count > i) {
        if ([[YYImageCache sharedCache] getImageForKey:_model.bgUrls[i]] || !_model.bgUrls[i].length) {
            i++;
            [self loadTemplate];
        }else{
            [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:_model.bgUrls[i]]
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                              
                                                          }
                                                         transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                             return image;
                                                         }
                                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//                                                            if (image) {
                                                                i++;
                                                                [self loadTemplate];
//                                                            }
                                                        }];

        }
    }else if (_model.hideImgs && _model.hideImgs.count > j){
        if ([[YYImageCache sharedCache] getImageForKey:_model.hideImgs[j]] || !_model.hideImgs[j].length) {
            j++;
            [self loadTemplate];
        }else{
            [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:_model.hideImgs[j]]
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                              
                                                          }
                                                         transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                             return image;
                                                         }
                                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                            if (image) {
                                                                j++;
                                                                [self loadTemplate];
                                                            }
                                                        }];
        }
    }else if (_model.imgTemplates && _model.imgTemplates.count > t){
        
        NSString *imgUrl = _model.imgTemplates[t][@"imgUrl"];
        
        if ([[YYImageCache sharedCache] getImageForKey:imgUrl] || !imgUrl.length) {
            t++;
            [self loadTemplate];
        }else{
            [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:imgUrl]
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                              
                                                          }
                                                         transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                             return image;
                                                         }
                                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                            if (image) {
                                                                t++;
                                                                [self loadTemplate ];
                                                            }
                                                        }];
        }
    }else{
        i = 0;
        j = 0;
        t = 0;
        if (_loadbBlock) {
            _loadbBlock(YES);
        }
    }
}

- (NSArray<UIImage *> *)formatTemplateImages{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:9];
    UIImage *bgimage = nil;
    if (_model.bgUrls.count == 1) {
        bgimage = [[YYImageCache sharedCache] getImageForKey:_model.bgUrls.firstObject];
        bgimage = [bgimage scaleImageWithsize:CGSizeMake(_model.templateWidth, _model.templateHeight)];
    }else{
        bgimage = [UIImage emptyImageWithSize:CGSizeMake(_model.templateWidth, _model.templateHeight) backColor:[UIColor whiteColor]];
        bgimage = [bgimage scaleImageWithsize:CGSizeMake(_model.templateWidth, _model.templateHeight)];
        
        CGFloat imageWidth = (_model.templateWidth - 6)/3;
        CGFloat X = 0;
        CGFloat Y = 0;
        
        for (int i = 0; i< _model.bgUrls.count; i++) {
            if (_model.bgUrls[i] || _model.bgUrls[i].length) {
                Y = (int)(i/3) * imageWidth;
                X = (i%3) *imageWidth;
                
                UIImage *image = [[YYImageCache sharedCache] getImageForKey:_model.bgUrls[i]];
                [bgimage drawMarkImage:image inRect:CGRectMake(X, Y, imageWidth-2, imageWidth-2)];
            }
        }
    }
    
    for (NSDictionary *dict in _model.imgTemplates) {
        UIImage *markImage = [[YYImageCache sharedCache] getImageForKey:dict[@"imgUrl"]];
        bgimage = [bgimage drawMarkImage:markImage inRect:CGRectMake([dict[@"pointX"] floatValue], [dict[@"pointY"] floatValue], [dict[@"width"] floatValue], [dict[@"height"] floatValue])];
    }
//    for (NSDictionary *dict in _model.textTemplates) {
//        bgimage = [bgimage drawText:dict[@"text"] inRect:CGRectMake([dict[@"pointX"] floatValue], [dict[@"pointY"] floatValue], [dict[@"width"] floatValue], [dict[@"height"] floatValue]) attributes:@{NSFontAttributeName:[UIFont fontWithName:dict[@"font"] size:[dict[@"size"] floatValue]],NSForegroundColorAttributeName:[UIColor colorWithHexString:dict[@"color"]]}];
//    }
    
    CGFloat imageWidth = _model.templateWidth/3;
    CGFloat X = 0;
    CGFloat Y = 0;
    for (int i = 0; i < 9; i++) {
        Y = (int)(i/3) * imageWidth;
        X = (i%3) *imageWidth;
        
        UIImage *image = [bgimage clipImageInRect:CGRectMake(X, Y, imageWidth-2, imageWidth-2)];
    
        UIImage *bigImage = [[YYImageCache sharedCache] getImageForKey:_model.hideImgs[i]];
        if (bigImage) {
            UIImage *qrImage = [UIImage qrImageByContent:self.shareUrl?self.shareUrl:_model.shareUrl];
            image = [image hideimage:qrImage withOriginImage:image withBigImage:bigImage];

        }
        if (_model.textTemplates.count) {
            NSDictionary *dict = _model.textTemplates[i];
            UIFont *font = [UIFont fontWithName:dict[@"fontName"] size:[dict[@"fontValue"] floatValue]];
            if (!font) {
                font = [UIFont systemFontOfSize:[dict[@"fontValue"] floatValue]];
            }
            image = [image drawText:dict[@"text"] inRect:CGRectMake([dict[@"pointX"] floatValue], [dict[@"pointY"] floatValue], [dict[@"width"] floatValue], [dict[@"height"] floatValue]) attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor colorWithHexString:dict[@"color"]]}];
        }
        
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        
        [array addObject:[UIImage imageWithData:data]];
    }
    return array;
}
@end
