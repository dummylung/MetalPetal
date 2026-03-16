//
//  MTILayerPattern.h
//  Atelier
//
//  Created by Lung on 29/1/2026.
//  Copyright © 2026 command b. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h> // Required for CGFloat

#import "MTILayer.h"

// 1. Define a struct to hold your return values
typedef struct {
    CGFloat angle; // or float/double/int depending on your needs
    bool flipX;
} MTILayerTransform;

typedef struct {
    NSInteger col;
    NSInteger row;
    NSInteger sub;
    CGPoint mappedPosition;
} MTILayerGridIndex;


typedef MTILayerTransform (^MTILayerPatternTransformHandler)(NSInteger col, NSInteger row, NSInteger sub);
typedef MTILayerGridIndex (^MTILayerPatternGridIndexHandler)(CGPoint position, CGSize tileSize);

@interface MTILayerPattern : NSObject

@property (nonatomic, assign) MTILayerPatternType type;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, copy, nonnull) MTILayerPatternTransformHandler transformHandler;
@property (nonatomic, copy, nonnull) MTILayerPatternGridIndexHandler gridIndexHandler;
@property (nonatomic, copy, nonnull) MTILayerPatternGridIndexHandler positionHandler;

- (instancetype)initWithType:(MTILayerPatternType)type;

@end
