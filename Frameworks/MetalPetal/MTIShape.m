//
//  MTIShape.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIShape.h"

@implementation MTIShape

- (instancetype)initWithScatter:(CGFloat)scatter
                       rotation:(CGFloat)rotation
                          count:(int)count
                    countJitter:(CGFloat)countJitter
                     randomised:(BOOL)randomised
                        azimuth:(BOOL)azimuth
                    flipOptions:(MTIShapeFlipOptions)flipOptions {
    if (self = [super init]) {
        _scatter = scatter;
        _rotation = rotation;
        _count = count;
        _countJitter = countJitter;
        _randomised = randomised;
        _azimuth = azimuth;
        _flipOptions = flipOptions;
    }
    return self;
}

- (instancetype)init {
    return [self initWithScatter:0 rotation:0 count:1 countJitter:0 randomised:FALSE azimuth:FALSE flipOptions:MTIShapeFlipOptionsDonotFlip];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
