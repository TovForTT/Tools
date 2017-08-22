//
//  BLAssetModel.h
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface BLAssetModel : NSObject
@property (nonatomic) PHAsset *asset; // PHAsset
+ (instancetype)modelWithAsset:(id)asset;
@end

@interface BLAlbumModel : NSObject
/** PHFetchResult<PHAsset> */
@property (nonatomic, strong) id result;
/** 数量 */
@property (nonatomic, assign) NSInteger count;
/** 名字 */
@property (nonatomic, copy) NSString *albumName;

@property (nonatomic, copy) NSArray<BLAssetModel *>  *models;

@end
