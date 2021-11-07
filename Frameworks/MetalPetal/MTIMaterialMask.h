//
//  MTIMaterialMask.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <UIKit/UIKit.h>

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIColor.h>
#import <MetalPetal/MTIMask.h>
#else
#import "MTIColor.h"
#import "MTIMask.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

__attribute__((objc_subclassing_restricted))
@interface MTIMaterialMask : NSObject <NSCopying>

@property (nonatomic, strong, readonly) MTIImage *content;

@property (nonatomic, readonly) MTIColorComponent component;

@property (nonatomic, readonly) MTIMaskMode mode;

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat depth;
@property (nonatomic, readonly) CGFloat depth1;
@property (nonatomic, readonly) BOOL depth1Inverted;
@property (nonatomic, readonly) MTIMaskBlendMode blendMode1;
@property (nonatomic, readonly) CGFloat depth2;
@property (nonatomic, readonly) BOOL depth2Inverted;
@property (nonatomic, readonly) MTIMaskBlendMode blendMode2;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode scale:(CGFloat)scale depth:(CGFloat)depth depth1:(CGFloat)depth1 depth1Inverted:(BOOL)depth1Inverted blendMode1:(MTIMaskBlendMode)blendMode1 depth2:(CGFloat)depth2 depth2Inverted:(BOOL)depth2Inverted blendMode2:(MTIMaskBlendMode)blendMode2 NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithContent:(MTIImage *)content;

@end

NS_ASSUME_NONNULL_END
