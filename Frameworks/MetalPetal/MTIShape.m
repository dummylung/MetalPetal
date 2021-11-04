//
//  MTIShape.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIShape.h"

@implementation MTIShape

- (instancetype)initWithRotation:(CGFloat)rotation
                           count:(int)count
                     countJitter:(CGFloat)countJitter
                     flipOptions:(MTIShapeFlipOptions)flipOptions {
    if (self = [super init]) {
        _rotation = rotation;
        _count = count;
        _countJitter = countJitter;
        _flipOptions = flipOptions;
    }
    return self;
}

- (instancetype)init {
    return [self initWithRotation:0 count:1 countJitter:0 flipOptions:MTIShapeFlipOptionsDonotFlip];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
