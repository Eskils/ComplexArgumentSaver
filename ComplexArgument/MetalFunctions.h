//
//  MetalFunctions.h
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

struct PrecompiledMetalFunction {
    id<MTLCommandQueue> commandQueue;
    id<MTLComputePipelineState> pipelineState;
    NSUInteger mx;
} precompiledMetalFunction;
typedef struct PrecompiledMetalFunction PrecompiledMetalFunction;

@interface MetalFunctions : NSObject

typedef void (^CommandEncoderConfigurationBlock)(id<MTLComputeCommandEncoder>);

@property(retain) id<MTLDevice> device;

-(PrecompiledMetalFunction) precompileMetalFunctionWithName: (NSString*)name;

-(void) performCompiledMetalFunction: (PrecompiledMetalFunction)function numWidth: (NSUInteger)numWidth numHeight: (NSUInteger)numHeight commandEncoderConfiguration: (CommandEncoderConfigurationBlock)commandEncoderConfiguration;

- (id<MTLTexture>) makeTextureOfSize: (NSUInteger)size;

-(void) modularWithFunction: (PrecompiledMetalFunction)function texture: (id<MTLTexture>)texture a: (simd_float2)a b: (simd_float2)b power: (float)power;

@end

NS_ASSUME_NONNULL_END
