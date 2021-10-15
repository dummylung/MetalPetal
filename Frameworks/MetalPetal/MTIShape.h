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
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

typedef NS_OPTIONS(NSUInteger, MTIShapeFlipOptions) {
    MTIShapeFlipOptionsDonotFlip = 0,
    MTIShapeFlipOptionsFlipVertically = 1 << 0,
    MTIShapeFlipOptionsFlipHorizontally = 1 << 1,
} NS_SWIFT_NAME(MTIShape.FlipOptions);

__attribute__((objc_subclassing_restricted))
@interface MTIShape : NSObject <NSCopying>

@property (nonatomic, readonly) CGFloat scatter;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) CGFloat countJitter;
@property (nonatomic, readonly) BOOL randomised;
@property (nonatomic, readonly) BOOL azimuth;
@property (nonatomic, readonly) MTIShapeFlipOptions flipOptions;

- (instancetype)init;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithScatter:(CGFloat)scatter
                       rotation:(CGFloat)rotation
                          count:(int)count
                    countJitter:(CGFloat)countJitter
                     randomised:(BOOL)randomised
                        azimuth:(BOOL)azimuth
                    flipOptions:(MTIShapeFlipOptions)flipOptions NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
