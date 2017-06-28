//
//  MTIFilterFunctionDescriptor.m
//  Pods
//
//  Created by YuAo on 25/06/2017.
//
//

#import "MTIFilterFunctionDescriptor.h"

@implementation MTIFilterFunctionDescriptor

- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name libraryURL:nil];
}

- (instancetype)initWithName:(NSString *)name libraryURL:( NSURL * _Nullable )URL {
    if (self = [super init]) {
        _name = name;
        _libraryURL = [URL copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[MTIFilterFunctionDescriptor class]]) {
        return NO;
    }
    MTIFilterFunctionDescriptor *descriptor = object;
    if ([descriptor.name isEqualToString:self.name] && [descriptor.libraryURL isEqual:self.libraryURL]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.name.hash & self.libraryURL.hash;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
