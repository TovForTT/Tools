//
//  UIImage+BL.m
//

#import "UIImage+BL.h"
#import "Static.h"
#import "UIImage+QRCode.h"
@implementation UIImage (BL)
+ (UIImage *)imageWithString:(NSString *)str color:(UIColor *)color size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.alignment = NSTextAlignmentCenter;
    [str drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:@{
                                                                               NSFontAttributeName:[UIFont systemFontOfSize:size.width/2],
                                                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                               NSParagraphStyleAttributeName:paragraph
                                          }];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)spliceImages:(NSArray<UIImage *> *)images{
    if (!images) {
        return nil;
    }
    CGFloat height = 0;
    CGFloat width = 0;
    
    for (UIImage *image in images) {
        height += image.size.height;
        width = image.size.width;
    }
    UIImage *spliceImage = [[UIImage alloc] init];
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [spliceImage drawInRect:CGRectMake(0, 0, width, height)];
    
    CGFloat currentHeight = 0;
    for (int i = 0; i<images.count; i++) {
        UIImage *image = images[i];
        [image drawInRect:CGRectMake(0, currentHeight, width, image.size.height)];
        currentHeight += image.size.height;
    }
    spliceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return spliceImage;
}

+ (UIImage *)emptyImageWithSize:(CGSize)size backColor:(UIColor *)color{
    UIGraphicsBeginImageContext(size);
    
    [color setFill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)clipImageInRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
//    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

- (UIImage *)clipImageInRect:(CGRect)rect withCount:(int)count withScale:(CGFloat)imageScale withType:(NSInteger)type {
    CGFloat scale = 2.8 * imageScale;
    switch (count) {
        case 0:
        {
            switch (type) {
                case 1:
                case 2:
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 2 * scale;
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 1:
        {
            switch (type) {
                case 2:
                    rect.origin.x += 2 * scale;
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 2 * scale;
                    break;
                default:
                    rect.origin.x += 2 * scale;
                    rect.size.width -= 4 * scale;
                    rect.size.height -= 2 * scale;
                    break;
            }
            
        }
            break;
        case 2:
        {
            switch (type) {
                case 2:
                    rect.origin.y += 2 * scale;
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 2 * scale;
                    break;
                default:
                    rect.origin.x += 2 * scale;
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 2 * scale;
                    break;
            }
            
        }
            break;
        case 3:
        {
            switch (type) {
                case 2:
                    rect.origin.x += 2 * scale;
                    rect.origin.y += 2 * scale;
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 2 * scale;
                    break;
                    
                default:
                    rect.origin.y += 2 * scale;
                    rect.size.width -= 2 * scale;
                    rect.size.height -= 4 * scale;
                    break;
            }
            
        }
            break;
        case 4:
        {
            rect.origin.x += 2 * scale;
            rect.origin.y += 2 * scale;
            rect.size.width -= 4 * scale;
            rect.size.height -= 4 * scale;
        }
            break;
        case 5:
        {
            rect.origin.x += 2 * scale;
            rect.origin.y += 2 * scale;
            rect.size.width -= 2 * scale;
            rect.size.height -= 4 * scale;
        }
            break;
        case 6:
        {
            rect.origin.y += 2 * scale;
            rect.size.width -= 2 * scale;
            rect.size.height -= 2 * scale;
        }
            break;
        case 7:
        {
            rect.origin.x += 2 * scale;
            rect.origin.y += 2 * scale;
            rect.size.width -= 4 * scale;
            rect.size.height -= 2 * scale;
        }
            break;
            
        default:
        {
            rect.origin.x += 2 * scale;
            rect.origin.y += 2 * scale;
            rect.size.width -= 2 * scale;
            rect.size.height -= 2 * scale;
        }
            break;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    //    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

- (UIImage *)scaleImageWithsize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
//    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    
    [self  drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)blurryImageWithRadius:(CGFloat )radius
{
    if (radius <= 0) return self;
    [self fixOrientation];
    
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(radius), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *returnImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return returnImage;
}

- (UIImage *)drawText:(NSString*)text inRect:(CGRect)rect attributes:(NSDictionary<NSString *,id> *)attributes{
    CGSize scaleSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    UIGraphicsBeginImageContext(scaleSize);
    [self drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    [text drawInRect:rect withAttributes:attributes];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}

- (UIImage *)drawMarkImage:(UIImage*)image inRect:(CGRect)rect{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [image drawInRect:rect];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}

- (UIImage *)drawMarkView:(UIView *)view inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [view drawRect:rect];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}

- (UIImage *)fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)hideimage:(UIImage *)image withOriginImage:(UIImage *)originImage withBigImage:(UIImage *)bigImage {

    // 宽写死750的
    if (bigImage) {
        CGFloat scale = [UIScreen mainScreen].scale;
        if (![bigImage isKindOfClass:NSClassFromString(@"YYImage")]) {
            scale = 1;
        }
        CGSize bigImgSize = bigImage.size;
        CGSize bigImageSizeScale = CGSizeMake(bigImgSize.width * scale, bigImgSize.height * scale);
        
        CGFloat X = 0;
        CGFloat Y = (bigImageSizeScale.height - 750) / 2;
        
        UIGraphicsBeginImageContext(bigImageSizeScale);
        [bigImage drawInRect:CGRectMake(0, 0, bigImageSizeScale.width, bigImageSizeScale.height)];
        [originImage drawInRect:CGRectMake(X, Y - 1, 750, 750 + 1)];
        
        [image drawInRect:CGRectMake(750 - 46 - 143, bigImageSizeScale.height - 32 - 143, 143, 143)];
        
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
        
        
    } else {
        CGFloat w = 750;
        CGFloat h = w / 2;
        CGSize size = image.size;
        CGFloat scaleH = size.height / size.width * w;
        CGSize contextSize = CGSizeMake(w, w + (2 * scaleH) + 22);
        UIGraphicsBeginImageContext(contextSize);
        
        [image drawInRect:CGRectMake(0, 0, w, scaleH)];
        [originImage drawInRect:CGRectMake(0, scaleH, w, w + 8)];
        UIImage *i = [UIImage emptyImageWithSize:CGSizeMake(1, 1) backColor:[UIColor whiteColor]];
    
        [i drawInRect:CGRectMake(0, scaleH + w + 14, w, scaleH)];
        
        UIImage *adImage = [UIImage imageNamed:@"fentu_advertising"];
        if (scaleH - h > 100) {
            [adImage drawInRect:CGRectMake(0, scaleH + w + 100, w, h)];
        } else {
            [adImage drawInRect:CGRectMake(0, scaleH + w + (scaleH - 375) / 2, w, h)];
        }
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
}

- (UIImage *)clipImage:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (![image isKindOfClass:NSClassFromString(@"YYImage")]) {
        scale = 1;
    }
    
    CGSize imageSize = image.size;
    CGFloat imageSizeW;
    CGRect clipRect = CGRectZero;
    if (imageSize.width > imageSize.height) {
        imageSizeW = image.size.height * scale;
        clipRect = CGRectMake((imageSize.width * scale - imageSizeW) / 2, 0, imageSizeW, imageSizeW);
    } else {
        imageSizeW = image.size.width * scale;
        clipRect = CGRectMake(0, (imageSize.height * scale - imageSizeW) / 2, imageSizeW, imageSizeW);
    }
    
    image = [image clipImageInRect:clipRect];
    
    UIGraphicsBeginImageContext(CGSizeMake(750, 750));
    [image drawInRect:CGRectMake(0, 0, 750, 750)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    NSData *data = UIImagePNGRepresentation(image);
//    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", 520]];
//    [data writeToFile:file atomically:YES];
    
    return image;
    
}


+ (UIImage *)getThumbnail:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(150, 150), NO, 1);
    [image drawInRect:CGRectMake(0, 0, 150, 150)];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}
@end
