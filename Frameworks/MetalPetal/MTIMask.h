//
//  MTIMask.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <UIKit/UIKit.h>

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIColor.h>
#else
#import "MTIColor.h"
#import "MTIBlendModes.h"
#import "MTILayer.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

typedef NS_ENUM(NSInteger, MTIMaskMode) {
    MTIMaskModeNormal = 0,
    MTIMaskModeOneMinusMaskValue
};

typedef NS_ENUM(NSInteger, MTIMaskType) {
    MTIMaskTypeMoving = 0,
    MTIMaskTypeTexturised
};

//__attribute__((objc_subclassing_restricted))
@interface MTIMask : NSObject <NSCopying>

@property (nonatomic, strong, readonly) MTIImage *content;

@property (nonatomic, readonly) MTIColorComponent component;

@property (nonatomic, readonly) MTIMaskMode mode;
@property (nonatomic, readonly) MTIMaskType type;
@property (nonatomic, readonly) CGFloat movement;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat zoom;
@property (nonatomic, readwrite) CGFloat rotation;
@property (nonatomic, readonly) CGFloat depth;
@property (nonatomic, readonly) CGPoint offsetJitter;
@property (nonatomic, readonly) MTIBlendMode blendMode;

@property (nonatomic, readwrite) CGPoint position;
@property (nonatomic, readwrite) CGSize size;
@property (nonatomic, readwrite) MTILayerFlipOptions contentFlipOptions;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithContent:(MTIImage *)content contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions component:(MTIColorComponent)component mode:(MTIMaskMode)mode type:(MTIMaskType)type movement:(CGFloat)movement scale:(CGFloat)scale zoom:(CGFloat)zoom rotation:(CGFloat)rotation depth:(CGFloat)depth offsetJitter:(CGPoint)offsetJitter blendMode:(MTIBlendMode)blendMode position:(CGPoint)position size:(CGSize)size NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode;

- (instancetype)initWithContent:(MTIImage *)content;



@end

NS_ASSUME_NONNULL_END
