//
//  AlbumShowView.h
//

#import "BaseView.h"
@interface AlbumShowView : BaseView

@property (nonatomic, copy) void(^didSelectImage)(UIImage *image, CGRect rect);
@property (nonatomic, copy) dispatch_block_t didSelectCamera;
@end
