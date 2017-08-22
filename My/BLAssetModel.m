//
//  BLAssetModel.m
//

#import "BLAssetModel.h"
#import "BLAlbumManager.h"
@implementation BLAssetModel
+ (instancetype)modelWithAsset:(id)asset
{
    BLAssetModel *model = [BLAssetModel new];
    model.asset = asset;
    return model;
}
@end

@implementation BLAlbumModel

- (void)setResult:(id)result
{
    _result = result;
    
    [[BLAlbumManager manager] getAssetsFromFetchResult:result completion:^(NSArray<BLAssetModel *> *models) {
        _models = models;
    }];
}

@end
