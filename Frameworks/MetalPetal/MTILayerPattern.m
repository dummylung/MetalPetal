//
//  MTILayerPattern.m
//  Atelier
//
//  Created by Lung on 29/1/2026.
//  Copyright © 2026 command b. All rights reserved.
//

#import "MTILayerPattern.h"

@implementation MTILayerPattern

- (instancetype)initWithType:(MTILayerPatternType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

@end
