//
//  MTIAlterColorFilter.h
//  Pods
//
//  Created by Yu Ao on 08/01/2018.
//

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIUnaryImageRenderingFilter.h>
#import <MetalPetal/MTIColor.h>
#else
#import "MTIUnaryImageRenderingFilter.h"
#import "MTIColor.h"
#endif

__attribute__((objc_subclassing_restricted))
@interface MTIAlterColorFilter : MTIUnaryImageRenderingFilter

/// Specifies the scale of the operation, i.e. the size for the pixels in the resulting image.
@property (nonatomic) MTIColor color;

@end
