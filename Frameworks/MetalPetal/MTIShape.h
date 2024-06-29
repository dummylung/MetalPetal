//
//  MTIShape.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <UIKit/UIKit.h>

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIColor.h>
#else
#import "MTIColor.h"
#import "MTIMask.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

typedef NS_OPTIONS(NSUInteger, MTIShapeFlipOptions) {
    MTIShapeFlipOptionsDonotFlip = 0,
    MTIShapeFlipOptionsFlipVertically = 1 << 0,
    MTIShapeFlipOptionsFlipHorizontally = 1 << 1,
} NS_SWIFT_NAME(MTIShape.FlipOptions);

typedef NS_ENUM(NSUInteger, MTIShapeMagMinFilterOption) {
    MTIShapeMagMinFilterOptionNearest = 0,
    MTIShapeMagMinFilterOptionLinear,
    MTIShapeMagMinFilterOptionBicubic,
} NS_SWIFT_NAME(MTIShape.MagMinFilterOption);

__attribute__((objc_subclassing_restricted))
@interface MTIShape : NSObject <NSCopying>

@property (nonatomic, readonly) MTIColorComponent component;
@property (nonatomic, readonly) MTIMaskMode mode;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) CGFloat countJitter;
@property (nonatomic, readonly) MTIShapeFlipOptions flipOptions;
@property (nonatomic, readonly) MTIShapeMagMinFilterOption magMinFilterOption;

- (instancetype)init;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithComponent:(MTIColorComponent)component
                             mode:(MTIMaskMode)mode
                         rotation:(CGFloat)rotation
                           count:(int)count
                     countJitter:(CGFloat)countJitter
                     flipOptions:(MTIShapeFlipOptions)flipOptions
              magMinFilterOption:(MTIShapeMagMinFilterOption)magMinFilterOption NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
