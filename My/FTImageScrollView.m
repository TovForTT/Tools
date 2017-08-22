//
//  FTImageScrollView.m
//

#import "FTImageScrollView.h"
#import "UIView+frame.h"
#import "Static.h"
#import "YYWebImage.h"
@interface FTImageScrollView()<UIScrollViewDelegate>
{
    BOOL flag;
    CGFloat saveX;
    CGFloat saveY;
}
@property (nonatomic, strong) UIImageView *displayImageview;
@property (nonatomic, strong) UIImage *eidtImage;
@end

@implementation FTImageScrollView
+ (instancetype)imageScrollViewWithImgUrl:(NSString *)url{
    FTImageScrollView *scrollView = [[FTImageScrollView alloc] init];
    scrollView.imageUrl = url;
    return scrollView;
}

+ (instancetype)imageScrollViewWithImg:(UIImage *)image{
    FTImageScrollView *scrollView = [[FTImageScrollView alloc] init];
    scrollView.image = image;
    return scrollView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    [self defaultImageRect];
}

- (void)addSubview:(UIView *)view {
    if ([view isKindOfClass:[UIButton class]]) {
        saveX = view.frame.origin.x;
        saveY = view.frame.origin.y;
    }
    [super addSubview:view];
    
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    [self defaultImageRect];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        saveX = 0;
        saveY = 0;
        self.panGestureRecognizer.delaysTouchesBegan = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.delegate = self;
        self.maximumZoomScale = 2;
        self.minimumZoomScale = 1;
        self.zoomScale = 1.0;
        
        UIImageView *displayImageview = [[UIImageView alloc] init];
        displayImageview.contentMode = UIViewContentModeScaleAspectFill;
//        displayImageview.userInteractionEnabled = YES;
        _displayImageview = displayImageview;
        [self addSubview:displayImageview];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    _displayImageview.image = image;
    [self defaultImageRect];
}

- (void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    _image = [[YYImageCache sharedCache] getImageForKey:imageUrl];
    _displayImageview.image = _image;
    [self defaultImageRect];
}

- (void)refreshSubviews {
    [self defaultImageRect];
}

- (void)defaultImageRect{
    if (self.isBlur) {
        self.isBlur = NO;
        return;
    }
    self.zoomScale = 1.0;
    CGFloat width = self.width;
    self.contentOffset = CGPointMake(0, 0);
    if (_image.size.height > _image.size.width){
        CGFloat scale = _image.size.height / _image.size.width;
        self.displayImageview.x = 0;
        self.displayImageview.width = width;
        self.displayImageview.height = width * scale;
        self.contentSize = self.displayImageview.frame.size;
        self.contentOffset = CGPointMake(0, (self.displayImageview.height-width)/2);
    }else{//横图
        CGFloat scale = _image.size.width / _image.size.height;
        self.displayImageview.y = 0;
        self.displayImageview.width = self.height *scale;
        self.displayImageview.height = self.height;
        self.contentSize = self.displayImageview.frame.size;
        if (self.height != self.width) {
            if (self.displayImageview.width < self.width) {
                CGFloat twiceScale = self.width / self.displayImageview.width;
                self.maximumZoomScale = twiceScale + 2;
                self.minimumZoomScale = twiceScale;
                self.zoomScale = twiceScale;
            }
        }
        self.contentOffset = CGPointMake((self.displayImageview.width - width)/2, 0);
    }
    CGFloat imageWidth = _image.size.height > _image.size.width? _image.size.width*_image.scale:_image.size.height*_image.scale;
    
    self.imageRect = CGRectMake(_image.size.width*(self.contentOffset.x/self.contentSize.width), _image.size.height*(self.contentOffset.y/self.contentSize.height), imageWidth, imageWidth);
    

    [self setupImageRect];
}

//- (void)setContentOffset:(CGPoint)contentOffset{
//    super.contentOffset = contentOffset;
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UIView *v in self.subviews) {
        if (self.contentSize.width > self.contentSize.height) {
            if ((v.frame.size.height == self.frame.size.height) && (v.frame.size.width == self.frame.size.width)) {
                if (scrollView.zoomScale != 1) {
                    v.y = scrollView.contentOffset.y;
                } else {
                    v.y = 0;
                }
                v.x = scrollView.contentOffset.x;
            }
        } else {
            if ((v.frame.size.height == self.frame.size.height) && (v.frame.size.width == self.frame.size.width)) {
                if (scrollView.zoomScale != 1) {
                    v.x = scrollView.contentOffset.x;
                } else {
                    v.x = 0;
                }
                v.y = scrollView.contentOffset.y;
            }
        }
        
        if ([v isKindOfClass:[UIButton class]]) {
            v.x = scrollView.contentOffset.x + saveX;
            v.y = scrollView.contentOffset.y + saveY;
        }
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.displayImageview;
}

- (void)setupImageRect {
    CGPoint point = self.contentOffset;
//    CGFloat scale = self.zoomScale;
    CGFloat imageWidth = (_image.size.width *_image.scale)/self.zoomScale;
    CGFloat imageHeight = (_image.size.height *_image.scale)/self.zoomScale;
    CGFloat ratio;
    if (_image.size.height>_image.size.width){//竖图
        ratio = _image.size.width / _displayImageview.width;
    }else{//横图
        ratio = _image.size.height / _displayImageview.height;
    }
    CGFloat wh = MIN(imageWidth, imageHeight);
    _imageRect = CGRectMake(point.x * ratio * _image.scale, point.y * ratio * _image.scale, wh, wh);
    
    if (self.height != self.width) {
        self.imageRect = CGRectMake(_image.size.width*(self.contentOffset.x/self.contentSize.width), _image.size.height*(self.contentOffset.y/self.contentSize.height), self.width * ratio, self.height * ratio);
    }
    if ([self.FTImageScrollViewDelegate respondsToSelector:@selector(getImageRect:count:)]) {
        [self.FTImageScrollViewDelegate getImageRect:_imageRect count:self.count];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    [self setupImageRect];
//    CGPoint point = scrollView.contentOffset;
//    CGFloat imageWidth = (_image.size.width *_image.scale)/scrollView.zoomScale;
//    CGFloat imageHeight = (_image.size.height *_image.scale)/scrollView.zoomScale;
//    CGFloat ratio;
//    if (_image.size.height>_image.size.width){//竖图
//        ratio = _image.size.width / _displayImageview.width;
//    }else{//横图
//        ratio = _image.size.height / _displayImageview.height;
//    }
//    CGFloat wh = MIN(imageWidth, imageHeight);
//    _imageRect = CGRectMake(point.x * scale * ratio, point.y * scale * ratio, wh, wh);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setupImageRect];
//    CGPoint point = scrollView.contentOffset;
//    CGFloat scale = scrollView.zoomScale;
//    CGFloat imageWidth = (_image.size.width *_image.scale)/scale;
//    CGFloat imageHeight = (_image.size.height * _image.scale)/scale;
//    CGFloat ratio = _image.size.width / _displayImageview.width;
//    
//    CGFloat wh = MIN(imageWidth, imageHeight);
//    _imageRect = CGRectMake(point.x * scale * ratio, point.y * scale * ratio, wh, wh);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        return;
    }
    [self setupImageRect];
//    CGPoint point = scrollView.contentOffset;
//    CGFloat scale = scrollView.zoomScale;
//    CGFloat imageWidth = (_image.size.width *_image.scale)/scale;
//    CGFloat imageHeight = (_image.size.height * _image.scale)/scale;
//    CGFloat ratio = _image.size.width / _displayImageview.width;
////    if (_image.size.height>_image.size.width){//竖图
////        _imageRect = CGRectMake(imageWidth*((point.x * scale)/scrollView.contentSize.width), imageHeight*((point.y*scale)/scrollView.contentSize.height), imageWidth, imageWidth);
////    }else{//横图
////        _imageRect = CGRectMake((imageWidth*((point.x * scale)/scrollView.contentSize.width)), (imageHeight*((point.y * scale)/scrollView.contentSize.height)), imageHeight, imageHeight);
////    }
//    CGFloat wh = MIN(imageWidth, imageHeight);
//    _imageRect = CGRectMake(point.x * scale * ratio, point.y * scale * ratio, wh, wh);
}

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur <= 0) return image;
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *returnImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    
    UIGraphicsEndImageContext();
    return returnImage;
}
@end
