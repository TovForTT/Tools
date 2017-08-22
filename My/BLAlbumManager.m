//
//  BLAlbumManager.m
//

#import "BLAlbumManager.h"
#import "Static.h"
#define horizontalCount 4
#define margin 1

@interface BLAlbumManager ()

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, copy) NSMutableArray *photos;

// 模型转照片用
@property (nonatomic, strong) NSString *assetId;
@property (nonatomic, assign) PHImageRequestID imageReqId;
@end

static CGFloat screenS; // 屏幕分辨率比例
static CGFloat screenW;

static BLAlbumManager *manager;

@implementation BLAlbumManager
// 判断是否有访问权限
+ (BOOL)authorizationStatus {
    /*
    AuthorizationStatusNotDetermined      // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
    AuthorizationStatusAuthorized = 0,    // 用户已授权，允许访问
    AuthorizationStatusDenied,            // 用户拒绝访问
    AuthorizationStatusRestricted,        // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
    */
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) return YES;
    return NO;
}

+ (void)requestImagePickerAuthorization:(void(^)(BLAuthorizationStatus status))callback autoExecute:(BOOL)autoExecute{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
               
                [self executeCallback:callback status:BLAuthorizationStatusAuthorized];
            } else if (status == PHAuthorizationStatusDenied) {//拒绝

                [self executeCallback:callback status:BLAuthorizationStatusDenied];
            } else if (status == PHAuthorizationStatusRestricted) {//没有授权
                if (autoExecute) {
                    [self requestImagePickerAuthorization:callback autoExecute:YES];
                }else{
                    [self executeCallback:callback status:BLAuthorizationStatusRestricted];
                }
            }
        }];
    } else {
        [self executeCallback:callback status:BLAuthorizationStatusNotSupport];
    }
}

#pragma mark - callback
+ (void)executeCallback:(void (^)(BLAuthorizationStatus))callback status:(BLAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) {
            callback(status);
        }
    });
}

+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BLAlbumManager alloc] init];
        screenW = [UIScreen mainScreen].bounds.size.width;
        screenS = 4;
        if (screenW > 400) {
            screenS = 4.f;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            manager.cachingImageManager = [[PHCachingImageManager alloc] init];
            // manager.cachingImageManager.allowsCachingHighQualityImages = YES;
        }
    });
    return manager;
}

#pragma mark - Get Album
// 获取相机胶卷
- (void)getCameraRollAlbum:(void (^)(BLAlbumModel *albumModel))completion {
    // 获取资源参数，可为空
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    
    //资源类型为照片
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 资源类型为视频
    // option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    
    // 按创建时间排序
    // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    
    /**
     enum PHAssetCollectionType : Int {
     case Album //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
     case SmartAlbum //经由相机得来的相册
     case Moment //Photos 为我们自动生成的时间分组的相册
     }
     
     enum PHAssetCollectionSubtype : Int {
     case AlbumRegular //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
     case AlbumSyncedEvent //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
     case AlbumSyncedFaces //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
     case AlbumSyncedAlbum //做了 AlbumSyncedEvent 应该做的事
     case AlbumImported //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
     case AlbumMyPhotoStream //用户的 iCloud 照片流
     case AlbumCloudShared //用户使用 iCloud 共享的相册
     case SmartAlbumGeneric //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
     case SmartAlbumPanoramas //相机拍摄的全景照片
     case SmartAlbumVideos //相机拍摄的视频
     case SmartAlbumFavorites //收藏文件夹
     case SmartAlbumTimelapses //延时视频文件夹，同时也会出现在视频文件夹中
     case SmartAlbumAllHidden //包含隐藏照片或视频的文件夹
     case SmartAlbumRecentlyAdded //相机近期拍摄的照片或视频
     case SmartAlbumBursts //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
     case SmartAlbumSlomoVideos //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。不过我的 iPad mini 不支持，没法验证。
     case SmartAlbumUserLibrary //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
     case Any //包含所有类型
     }
     
     */
    // 获取智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    __block BLAlbumModel *albumModel;
    for (PHAssetCollection *collection in smartAlbums) {
        // 过滤list对象
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        // 根据名字判断相册
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            albumModel = [self modelWithResult:fetchResult name:collection.localizedTitle];
            if (completion) completion(albumModel);
            break;
        }
    }
}


// 获取所有相册
- (void)getAllAlbums:(void (^)(NSArray<BLAlbumModel *> *modelArray))completion {
    NSMutableArray *albumArr = @[].mutableCopy;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 用户创建相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    // 遍历只能相册
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) continue;
        if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
        } else {
//            [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
//    // 便利用户创建相册
//    for (PHAssetCollection *collection in topLevelUserCollections) {
//        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
//        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
//        if (fetchResult.count < 1) continue;
//        [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
//    }
    if (completion && albumArr.count > 0) completion(albumArr);
}

/**
 *
 *  获得相册最新的一张照片
 *
 */
- (void)getNearestPhotoCompletion:(void(^)(UIImage *))completion
{
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = [assetsFetchResults firstObject];
    
    [self getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
        if(completion) completion(photo);
    }];
    
}

#pragma mark - get Assets
- (void)getAssetsFromFetchResult:(id)result completion:(void (^)(NSArray<BLAssetModel *> *))completion {
    
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            [photoArr insertObject:[BLAssetModel modelWithAsset:asset] atIndex:0];
        }];
        if (completion) completion(photoArr);
    }
}


// 通过下标获取某张照片
- (void)getAssetResult:(id)result idx:(NSInteger)idx completion:(void (^)(BLAssetModel *assetModel))completion {
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        PHAsset *asset;
        @try {
            asset = fetchResult[idx];
        } @catch (NSException *exception) {
            if (completion) completion(nil);
            return;
        }
        // 资源类型为图片
        BLAssetModel *assetModel;
        if (asset.mediaType == PHAssetMediaTypeImage) {
            assetModel = [BLAssetModel modelWithAsset:asset];
        }
        if (completion) completion(assetModel );
    }
}

#pragma mark - Photo
// 获取原图
- (void)getOriginalPhotoWithAsset:(__kindof PHAsset*)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion {
    if (!asset) {
        completion(nil,nil);
        return;
    }
    NSAssert([asset isKindOfClass:[PHAsset class]], @"类型不匹配，不是 PHAsset");
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result, info);
        }
    }];
}

- (UIImage *)getOriginalPhotoWithAsset:(id)asset {
    __block UIImage *image;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                image = [self fixOrientation:result];
            }
        }];
    }
    return image;
}

// 获取选中的所有图片
- (void)getSelectedPhotosWithSelectedIdxs:(NSArray *)seletedIdx assets:(NSArray *)assets completion:(void (^)(NSArray *))completion {
    _photos = @[].mutableCopy;
    [seletedIdx enumerateObjectsUsingBlock:^(NSNumber *chectedIdx, NSUInteger idx, BOOL * _Nonnull stop) {
        BLAssetModel *modle = assets[[chectedIdx integerValue]];
        [self getOriginalPhotoWithAsset:modle.asset completion:^(UIImage *photo, NSDictionary *info) {
            if (photo) {
                [_photos addObject:photo];
                if (_photos.count == seletedIdx.count) {
                    completion(_photos);
//                    BLOCK_EXEC(completion, _photos.copy);
                }
            }
        }];
    }];
}

// 获取原图Data
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData) {
                if (completion) completion(imageData,info);
            }
        }];
    }
}

// 获得照片原图本身id
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:screenW completion:completion];
}

// 通过尺寸获取图片id
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (photoWidth < screenW) {
            CGFloat itemWH = (screenW - horizontalCount * margin) / 2;
            imageSize = CGSizeMake(itemWH, itemWH);
        } else {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * screenS;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        
        // 获取图片
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast; // 更高的请求效率
        PHImageRequestID imageReqId = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            // 获取照片是否成功
            BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![[info objectForKey:PHImageErrorKey] boolValue]);
            if (succeed && result) {
                result = [self fixOrientation:result];
                if (completion) completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
//            // 从iCloud下载
//            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
//                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
//                option.networkAccessAllowed = YES;
//                option.resizeMode = PHImageRequestOptionsResizeModeFast;
//                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                    resultImage = [self scaleImage:resultImage toSize:imageSize];
//                    if (resultImage) {
//                        resultImage = [self fixOrientation:resultImage];
//                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
//                    }
//                }];
//            }
        }];
        return imageReqId;
    }
    return 0;
}

- (PHImageRequestID)getPhotoOrIcloudPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (photoWidth < screenW) {
            CGFloat itemWH = (screenW - horizontalCount * margin) / 2;
            imageSize = CGSizeMake(itemWH, itemWH);
        } else {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * screenS;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        
        // 获取图片
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast; // 更高的请求效率
        PHImageRequestID imageReqId = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            // 获取照片是否成功
            BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![[info objectForKey:PHImageErrorKey] boolValue]);
            if (succeed && result) {
                result = [self fixOrientation:result];
                if (completion) completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            } else {
                if (completion) {
                    completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }
            // 从iCloud下载
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (resultImage) {
                        resultImage = [self fixOrientation:resultImage];
                        info = @{@"type" : @"1"};
                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
                }];
            }
        }];
        return imageReqId;
    }
    return 0;

}

// 获取封面图
- (void)getCoverImageWithAlbumModel:(BLAlbumModel *)albumModel completion:(void (^)(UIImage *))completion {
    id asset = [albumModel.result lastObject];
    // 显示最新照片
    asset = [albumModel.result firstObject];
    [manager getPhotoWithAsset:asset photoWidth:kScreen_Width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(photo);
    }];
}

// 转为照片
- (void)getPhotoWithModel:(BLAssetModel *)model photoW:(CGFloat)width completion:(void (^)(UIImage *))completion {
    self.assetId = [manager getAssetIdentifier:model.asset];
    
    PHImageRequestID imageReqId = [manager getPhotoWithAsset:model.asset photoWidth:width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.assetId isEqualToString:[manager getAssetIdentifier:model.asset]]) {
            //                self.imageView.image = photo;
            if (completion) completion(photo);
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageReqId];
        }
        if (!isDegraded) {
            self.imageReqId = 0;
        }
    }];
    if (imageReqId && self.imageReqId && imageReqId != self.imageReqId) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageReqId];
    }
    self.imageReqId = imageReqId;}

#pragma mark - Private Method
// 判断是否为相机胶卷
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
}


// asset 转 mdoel
- (BLAlbumModel *)modelWithResult:(id)result name:(NSString *)name {
    BLAlbumModel *model = [[BLAlbumModel alloc] init];
    model.result = result;
    model.albumName = [self getNewAlbumName:name];
    
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    }
    return model;
}


- (NSString *)getAssetIdentifier:(id)asset {
    PHAsset *phAsset = (PHAsset *)asset;
    return phAsset.localIdentifier;
    
}

// 大小缩放
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

// 英文名字转换
- (NSString *)getNewAlbumName:(NSString *)name {
    NSString *newName;
    if ([name rangeOfString:@"Roll"].location != NSNotFound)
        newName = @"相机胶卷";
    else if ([name rangeOfString:@"Stream"].location != NSNotFound)
        newName = @"我的照片流";
    else if ([name rangeOfString:@"Added"].location != NSNotFound)
        newName = @"最近添加";
    else if ([name rangeOfString:@"Selfies"].location != NSNotFound)
        newName = @"自拍";
    else if ([name rangeOfString:@"shots"].location != NSNotFound)
        newName = @"截屏";
    else if ([name rangeOfString:@"Panoramas"].location != NSNotFound)
        newName = @"全景照片";
    else if ([name rangeOfString:@"Favorites"].location != NSNotFound)
        newName = @"个人收藏";
    else if ([name rangeOfString:@"Hidden"].location != NSNotFound)
        newName = @"隐藏的照片";
    else if ([name rangeOfString:@"Bursts"].location != NSNotFound)
        newName = @"连拍";
    else newName = name;
    return newName;
    
}

// 旋转和等比缩放
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
