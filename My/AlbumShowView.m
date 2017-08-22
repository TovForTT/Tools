//
//  AlbumShowView.m
//

#import "AlbumShowView.h"
#import "BLAlbumManager.h"
#import "BLAssetModel.h"
#import <BlocksKit/UIControl+BlocksKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIImageView+YYWebImage.h"
#import "RecommendData.h"
#import "BLButton.h"
#import "UIScrollView+refresh.h"
#import "TempManger.h"
#import "NSString+BL.h"
#define kWidth (kScreen_Width-25)/4

@interface BaseImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BLAssetModel *model;
@property (nonatomic, copy) NSString *assetId;
@property (nonatomic, assign) PHImageRequestID imageReqId;
- (void)showLoading;

- (void)hideLoading;
@end

@interface AlbumShowView()<UICollectionViewDelegate,UICollectionViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIButton *_albumNameButton;
    UIImageView *_allowImageView;
    UITableView *_albumListTableView;
    
    BOOL _isShowRecommend;
    NSUInteger _recommendPage;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *webPhotos;
@property (nonatomic, strong) NSArray *albums;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) NSMutableArray *loadingArr;

@property (nonatomic, assign, getter=isAuthrity) BOOL authority;//是否有相册权限
@end

@implementation AlbumShowView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initialization];
        [self initUI];
//        // app启动或者app从后台进入前台都会调用这个方法
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlbumData) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialization];
        [self initUI];
//        // app启动或者app从后台进入前台都会调用这个方法
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlbumData) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)initialization{
    _authority = YES;
    _selectIndex = NSIntegerMax;
    _recommendPage = 1;
    
    _webPhotos = [TempManger unarchiveDataWithName:@"photos_1"];
    if (!_webPhotos.count){
        [RecommendData recommendListWithPage:1 handle:^(NSArray *recommends) {
            _webPhotos = recommends.mutableCopy;
            [self.collectionView reloadData];
        }];
    }
    
    [self reloadAlbumData];
}

- (void)reloadAlbumData{
    [BLAlbumManager requestImagePickerAuthorization:^(BLAuthorizationStatus status) {
        if (status == BLAuthorizationStatusAuthorized){
            _authority = YES;
            [[BLAlbumManager manager] getCameraRollAlbum:^(BLAlbumModel *albumModel) {
                _photos = albumModel.models.mutableCopy;
                [_collectionView reloadData];
                [_collectionView reloadEmptyDataSet];
            }];
            
            [[BLAlbumManager manager] getAllAlbums:^(NSArray<BLAlbumModel *> *modelArray) {
                _albums = modelArray;
                [_albumListTableView reloadData];
            }];
        }else if (status == BLAuthorizationStatusDenied || status == BLAuthorizationStatusRestricted){
            _authority = NO;
            [_collectionView reloadEmptyDataSet];
        }
    } autoExecute:YES];
}

#pragma mark - init/config UI

- (void)initUI{
    UIView *topView = [self configTopView];
    UICollectionView *collectionView = [self configCollectionView];
    
//    [self addSubview:topView];
    [self addSubview:collectionView];
    
//    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(45);
//    }];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

- (UIView *)configTopView{
    UIView *topView = [UIView new];
    topView.backgroundColor = kLightGaryColor;
    
    UIButton *albumNameButton = [UIButton new];
    albumNameButton.enabled = NO;
    albumNameButton.titleLabel.font = kSemiboldFont(17);
    albumNameButton.titleLabel.preferredMaxLayoutWidth = kScreen_Width - 160;
    albumNameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [albumNameButton setTitleColor:kBlackColor forState:(UIControlStateNormal)];
//    [albumNameButton setTitle:@"相机胶卷" forState:(UIControlStateNormal)];
    [albumNameButton bk_addEventHandler:^(UIButton *sender) {
        sender.selected = !sender.isSelected;
        [self configAlbumWithShow:sender.isSelected];
    } forControlEvents:(UIControlEventTouchUpInside)];
    
    UIImageView *allowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"camera_black"] forState:(UIControlStateNormal)];
    [cameraButton bk_addEventHandler:^(id sender) {
        if (_didSelectCamera) _didSelectCamera();
    } forControlEvents:(UIControlEventTouchDown)];
    
    BLButton *recommentButton = [[BLButton alloc] init];
    [recommentButton setTitle:@"觅图" forState:(UIControlStateNormal)];
    [recommentButton setTitleColor:kBlackColor forState:(UIControlStateNormal)];
    recommentButton.titleLabel.font = kSemiboldFont(14);
    recommentButton.hidden = YES;
    recommentButton.userInteractionEnabled = NO;

    [recommentButton bk_addEventHandler:^(BLButton *sender) {
        sender.selected = !sender.isSelected;
        _isShowRecommend = sender.isSelected;
        allowImageView.hidden = sender.isSelected;
        _albumNameButton.enabled = !sender.isSelected;
        
        [self.collectionView setContentOffset:CGPointZero];
        [self.collectionView reloadData];
        [self.collectionView resertNoMoreData];
        
        if (!sender.isSelected){
            NSInteger row = _albumListTableView.indexPathForSelectedRow.row;
            BLAlbumModel *model = _albums[row];
//            [albumNameButton setTitle:model.albumName forState:(UIControlStateNormal)] ;
        }else{
//            [albumNameButton setTitle:@"图片推荐" forState:(UIControlStateNormal)];
        }
        
    } forControlEvents:(UIControlEventTouchUpInside)];
    
    _allowImageView = allowImageView;
//    _albumNameButton = albumNameButton;
    
    [topView addSubview:allowImageView];
    [topView addSubview:albumNameButton];
    [topView addSubview:cameraButton];
    [topView addSubview:recommentButton];

    [albumNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView);
        make.top.bottom.mas_equalTo(0);
//        make.width.mas_equalTo(100);
    }];
    [allowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(topView);
        make.left.mas_equalTo(albumNameButton.mas_right).mas_offset(10);
    }];
    [cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-12);
        make.width.mas_equalTo(45);
    }];
    [recommentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(45);
    }];
    return topView;
}

- (UICollectionView *)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kWidth, kWidth);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = kWhiteColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.emptyDataSetSource = self;
    collectionView.emptyDataSetDelegate = self;
    [collectionView registerClass:[BaseImageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [collectionView addFooterRefreshAndHandle:^(__kindof UIScrollView *superView) {
        if (_isShowRecommend) {
            _recommendPage++;
            NSArray *array = [TempManger unarchiveDataWithName:[NSString stringWithFormat:@"photos_%ld",_recommendPage]];
            if (!array.count) {
                [RecommendData recommendListWithPage:_recommendPage handle:^(NSArray *list) {
                    if (list.count) [_webPhotos addObjectsFromArray:list];
                    [_collectionView reloadData];
                    [superView endFooterRefresh];
                }];
            }else{
                [_webPhotos addObjectsFromArray:array];
                [_collectionView reloadData];
                [superView endFooterRefresh];
            }
        }else{
            [superView noMoreDataWithTip:@"- end -"];
        }
    }];
    
    _collectionView = collectionView;
    return collectionView;
}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGPoint p = scrollView.contentOffset;
//    p.y = 0;
//    scrollView.contentOffset = p;
//}

- (void)configAlbumWithShow:(BOOL)isShow
{
    if (!_albumListTableView) {
        UITableView *tableView = [UITableView new];
        tableView.backgroundView = nil;
        tableView.backgroundColor = kWhiteColor;
        tableView.frame = CGRectMake(0, 45, self.width, 0);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.scrollsToTop = NO;
        tableView.separatorColor = kDarkGaryColor;
        _albumListTableView = tableView;
        [self addSubview:tableView];
        tableView.tableFooterView = [UIView new];
    }
    if (isShow) {
        [UIView animateWithDuration:0.3 animations:^{
            _albumListTableView.height = self.height-45;
            _allowImageView.transform = CGAffineTransformRotate(_albumNameButton.transform, M_PI);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _albumListTableView.height = 0;
            _allowImageView.transform = CGAffineTransformRotate(_albumNameButton.transform, 0);
        }];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = kBlackColor;
        cell.backgroundColor = kLightGaryColor;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    }
    BLAlbumModel *model = _albums[indexPath.row];
    cell.textLabel.text = model.albumName;
    return cell;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLAlbumModel *model = _albums[indexPath.row];
    [_albumNameButton setTitle:model.albumName forState:(UIControlStateNormal)];
    _albumNameButton.selected = NO;
    [self configAlbumWithShow:NO];
    [[BLAlbumManager manager] getAssetsFromFetchResult:model.result completion:^(NSArray<BLAssetModel *> *array) {
        _photos = array.mutableCopy;
        [_collectionView reloadData];
    }];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *str;
    if (_isShowRecommend) str = @"图片正在努力加载中";
    else str = _authority?@"相册里没有发现照片":@"分图没有权限访问相册";
    return [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:kBlackColor}];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (!_authority){
        return [[NSAttributedString alloc] initWithString:@"点击此处设置权限" attributes:@{
                                                                                   NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                                   NSForegroundColorAttributeName:kWhiteColor
                                                                                }];
    }
    return nil;
    
}
#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (!_authority){
        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication] openURL:settingUrl];
        }
    };
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _isShowRecommend?_webPhotos.count:_photos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    BaseImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"edit_content_camera@3x"];
        return cell;
    }
    if (_isShowRecommend) {
        RecommendModel *model = _webPhotos[indexPath.row];
        [cell.imageView yy_setImageWithURL:[NSURL URLWithString:model.url] placeholder:[UIImage imageNamed:@"hold_image"] options:(YYWebImageOptionShowNetworkActivity) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
        }];
    }else{
        cell.model = _photos[indexPath.row - 1];
        if ([self.loadingArr containsObject:@(indexPath.row - 1)]) {
            [cell showLoading];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(BaseImageCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    WK(weakSelf)
    if (indexPath.row == _selectIndex) {
        return;
    }
    
    if (!indexPath.row) {
        if (self.didSelectCamera) self.didSelectCamera();
        return;
    }
    
    BaseImageCollectionViewCell * cell = (BaseImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellRect = [_collectionView convertRect:cell.frame toView:_collectionView];
    CGRect rect = [_collectionView convertRect:cellRect toView:kWindow];
   
    if (_isShowRecommend){
        RecommendModel *model = _webPhotos[indexPath.row];
        [_albumNameButton setTitle:[NSString stringWithFormat:@"%@",model.name] forState:(UIControlStateNormal)];
        if (_didSelectImage) {
            UIImage *image = [[YYImageCache sharedCache] getImageForKey:model.url];
            _didSelectImage(image, rect);
        }
    }else{
        if (self.didSelectImage) {
            BLAssetModel *model = self.photos[indexPath.row - 1];
            NSString *assetId = [[BLAlbumManager manager] getAssetIdentifier:model.asset];
            [[BLAlbumManager manager] getPhotoOrIcloudPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (info[@"type"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BaseImageCollectionViewCell * cell = (id)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                        [cell hideLoading];
                    });
                        if ([weakSelf.loadingArr containsObject:@(indexPath.row - 1)]) {
                        [weakSelf.loadingArr removeObject:@(indexPath.row - 1)];
                    }
                    return;
                }
                if (!photo) {
                    [cell showLoading];
                    [weakSelf.loadingArr addObject:@(indexPath.row - 1)];
                    return;
                }
                if (!isDegraded) {
                    [cell hideLoading];
                    if ([weakSelf.loadingArr containsObject:@(indexPath.row - 1)]) {
                        [weakSelf.loadingArr removeObject:@(indexPath.row - 1)];
                    }
                    if ([assetId isEqualToString:[[BLAlbumManager manager] getAssetIdentifier:model.asset]]) {
                        _selectIndex = indexPath.row;
                        _didSelectImage(photo, rect);
                    }
                }
            }];
        }
//        BLAssetModel *model = _photos[indexPath.row];
//        [cell showLoading];
//        [[BLAlbumManager manager] getOriginalPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
//            [cell hideLoading];
//            if (_didSelectImage) _didSelectImage(photo, rect);
//        }];
    }
 
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (NSMutableArray *)loadingArr {
    if (!_loadingArr) {
        _loadingArr = [NSMutableArray new];
    }
    return _loadingArr;
}
@end


@implementation BaseImageCollectionViewCell{
    UIImageView *loadingImage;
}
- (instancetype)init {
    if (self = [super init]) {
        [self setUpCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setUpCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        [self setUpCell];
    }
    return self;
}

- (void)setUpCell {
    if (!_imageView) {
        self.clipsToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [imageView class];
        });
        
        loadingImage = [[UIImageView alloc] init];
        loadingImage.alpha = 0.9;
        loadingImage.contentMode = UIViewContentModeScaleAspectFit;
        loadingImage.image = [UIImage imageNamed:@"Loding..."];
        [self addSubview:loadingImage];
        [loadingImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        loadingImage.hidden = YES;
    }
    
    
}


- (void)setModel:(BLAssetModel *)model {
    _model = model;
    [self hideLoading];
    self.assetId = [[BLAlbumManager manager] getAssetIdentifier:model.asset];
    PHImageRequestID imageReqId = [[BLAlbumManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.assetId isEqualToString:[[BLAlbumManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
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
    self.imageReqId = imageReqId;
}

- (void)showLoading {
    loadingImage.hidden = NO;
}

- (void)hideLoading {
    loadingImage.hidden = YES;
}

@end
