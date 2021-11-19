//
//  MTIShape.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIShape.h"

@implementation MTIShape

- (instancetype)initWithComponent:(MTIColorComponent)component
                             mode:(MTIMaskMode)mode
                         rotation:(CGFloat)rotation
                           count:(int)count
                     countJitter:(CGFloat)countJitter
                     flipOptions:(MTIShapeFlipOptions)flipOptions {
    if (self = [super init]) {
        _component = component;
        _mode = mode;
        _rotation = rotation;
        _count = count;
        _countJitter = countJitter;
        _flipOptions = flipOptions;
    }
    return self;
}

- (instancetype)init {
    return [self initWithComponent:MTIColorComponentRed mode:MTIMaskModeNormal rotation:0 count:1 countJitter:0 flipOptions:MTIShapeFlipOptionsDonotFlip];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
