//
//  UIImage+BL.h
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface UIImage (BL)
/**
 *  生成文字图片
 *
 * @return UIImage
 **/
+ (UIImage *)imageWithString:(NSString *)str color:(UIColor *)color size:(CGSize )size;

+ (UIImage *)spliceImages:(NSArray<UIImage *> *)images;

+ (UIImage *)emptyImageWithSize:(CGSize)size backColor:(UIColor *)color;

- (UIImage *)clipImageInRect:(CGRect)rect;

- (UIImage *)scaleImageWithsize:(CGSize)size;

- (UIImage *)blurryImageWithRadius:(CGFloat )radius;

- (UIImage *)drawText:(NSString*)text inRect:(CGRect)rect attributes:(NSDictionary<NSString *,id> *)attributes;

- (UIImage *)drawMarkImage:(UIImage*)image inRect:(CGRect)rect;

- (UIImage *)drawMarkView:(UIView *)view inRect:(CGRect)rect;

- (UIImage *)hideimage:(UIImage *)image withOriginImage:(UIImage *)originImage withBigImage:(UIImage *)bigImage;

//相机拍摄出来的照片含有EXIF信息，图片大于2M时，编辑时会把exif信息删除照成图片会旋转90度
- (UIImage *)fixOrientation;

- (UIImage *)clipImage:(UIImage *)image;

- (UIImage *)clipImageInRect:(CGRect)rect withCount:(int)count withScale:(CGFloat)imageScale withType:(NSInteger)type;

+ (UIImage *)getThumbnail:(UIImage *)image;

@end
