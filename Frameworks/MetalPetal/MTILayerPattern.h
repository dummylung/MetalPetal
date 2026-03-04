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

typedef MTILayerTransform (^MTILayerPatternTransformHandler)(int col, int row, int sub);

@interface MTILayerPattern : NSObject

@property (nonatomic, assign) MTILayerPatternType type;
@property (nonatomic, copy, nullable) MTILayerPatternTransformHandler transformHandler;

- (instancetype)initWithType:(MTILayerPatternType)type;

@end
