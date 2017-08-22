//
//  FTImageScrollView.h
//

#import <UIKit/UIKit.h>

@protocol FTImageScrollViewDelegate <NSObject>

- (void)getImageRect:(CGRect)imageRect count:(NSInteger)count;

@end

@interface FTImageScrollView : UIScrollView

@property (nonatomic, assign) BOOL isBlur;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, assign) CGRect imageRect;

@property (nonatomic, assign) NSInteger count;

- (void)refreshSubviews;

+ (instancetype)imageScrollViewWithImgUrl:(NSString *)url;
+ (instancetype)imageScrollViewWithImg:(UIImage *)image;

@property (nonatomic, weak) id<FTImageScrollViewDelegate> FTImageScrollViewDelegate;

@end
