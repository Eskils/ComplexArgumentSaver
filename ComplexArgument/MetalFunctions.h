//
//  MetalFunctions.h
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "PrecompiledMetalFunction.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalFunctions : NSObject

typedef void (^CommandEncoderConfigurationBlock)(id<MTLComputeCommandEncoder>);

@property id<MTLDevice> device;

-(PrecompiledMetalFunction*) precompileMetalFunctionWithName: (NSString*)name;

-(void) performCompiledMetalFunction: (PrecompiledMetalFunction*)function numWidth: (NSUInteger)numWidth numHeight: (NSUInteger)numHeight texture: (id<MTLTexture>)texture commandEncoderConfiguration: (CommandEncoderConfigurationBlock)commandEncoderConfiguration;

- (id<MTLTexture>) makeTextureOfSize: (NSUInteger)size;

-(void) modularWithFunction: (PrecompiledMetalFunction*)function texture: (id<MTLTexture>)texture a: (simd_float2)a b: (simd_float2)b power: (float)power sqrtPow: (float)sqrtPow;

@end

NS_ASSUME_NONNULL_END
