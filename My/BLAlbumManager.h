//
//  BLAlbumManager.h
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import  "BLAssetModel.h"
typedef NS_ENUM(NSUInteger, BLAuthorizationStatus) {
    BLAuthorizationStatusAuthorized = 0,    // 已授权
    BLAuthorizationStatusDenied,            // 拒绝
    BLAuthorizationStatusRestricted,        // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
    BLAuthorizationStatusNotSupport         // 硬件等不支持
};

@interface BLAlbumManager : NSObject
/** 是否有访问权限 */
+ (BOOL)authorizationStatus;
+ (void)requestImagePickerAuthorization:(void(^)(BLAuthorizationStatus status))callback autoExecute:(BOOL)autoExecute;

+ (instancetype)manager;


/**
 *
 *  获取相机胶卷照片
 *
 */
- (void)getCameraRollAlbum:(void (^)(BLAlbumModel *albumModel))completion;

/**
 *
 *  获取所有相册
 *
 */
- (void)getAllAlbums:(void (^)(NSArray<BLAlbumModel *> *modelArray))completion;

/**
 *
 *  获取对应相册的照片
 *
 *
 */
- (void)getAssetsFromFetchResult:(id)result completion:(void (^)(NSArray<BLAssetModel *> *))completion;
- (void)getAssetResult:(id)result idx:(NSInteger)idx completion:(void (^)(BLAssetModel *assetModel))completion;

/**
 *
 *  获得相册最新的一张照片
 *
 */
- (void)getNearestPhotoCompletion:(void(^)(UIImage *))completion;

/**
 *
 *  获取对应照片
 *
 */
- (void)getOriginalPhotoWithAsset:(__kindof PHAsset*)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
/**
 *
 *  获取多张照片的数据
 *
 *
 */
- (void)getSelectedPhotosWithSelectedIdxs:(NSArray *)seletedIdx assets:(NSArray *)assets completion:(void (^)(NSArray *))completion;

// 获取原图Data
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoOrIcloudPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (void)getCoverImageWithAlbumModel:(BLAlbumModel *)albumModel completion:(void (^)(UIImage *))completion;

- (NSString *)getAssetIdentifier:(id)asset;

// 模型转照片
- (void)getPhotoWithModel:(BLAssetModel *)model photoW:(CGFloat)width completion:(void (^)(UIImage *))completion;

@end
