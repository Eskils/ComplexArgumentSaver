//
//  MetalFunctions.m
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import "MetalFunctions.h"

@implementation MetalFunctions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.device = MTLCreateSystemDefaultDevice();
    }
    return self;
}

-(PrecompiledMetalFunction*) precompileMetalFunctionWithName: (NSString*)name
{
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> function = [library newFunctionWithName: name];
    
    NSError * pipelineStateError;
    id<MTLComputePipelineState> pipelineState = [self.device newComputePipelineStateWithFunction: function error: &pipelineStateError];
    if (pipelineStateError != NULL) {
        NSLog(@"%@", pipelineStateError);
        abort();
    }
    
    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    MTLSize max = self.device.maxThreadsPerThreadgroup;
    NSUInteger mx = (NSUInteger)sqrtf((float)max.width);
    
    return [PrecompiledMetalFunction precompiledMetalFunctionWithCommandQueue: commandQueue piplineState: pipelineState andMx: mx];
}

-(void) performCompiledMetalFunction: (PrecompiledMetalFunction*)function numWidth: (NSUInteger)numWidth numHeight: (NSUInteger)numHeight commandEncoderConfiguration: (CommandEncoderConfigurationBlock)commandEncoderConfiguration
{
    id<MTLCommandBuffer> commandBuffer = [function.commandQueue commandBuffer];
    id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
    [commandEncoder setComputePipelineState: function.pipelineState];
    
    if(commandEncoderConfiguration) {
        commandEncoderConfiguration(commandEncoder);
    }
    
    MTLSize threadGroupCount = MTLSizeMake(MIN(function.mx, numWidth), MIN(function.mx, numHeight), 1);
    MTLSize threadGroups = MTLSizeMake(((numWidth - 1) / threadGroupCount.width) + 1, ((numHeight - 1) / threadGroupCount.height) + 1, 1);
    
    [commandEncoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
    [commandEncoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

- (id<MTLTexture>) makeTextureOfSize: (NSUInteger)size
{
    MTLTextureDescriptor *descriptor = [[MTLTextureDescriptor alloc] init];
    [descriptor setWidth: size];
    [descriptor setHeight: size];
    [descriptor setTextureType: MTLTextureType2D];
    [descriptor setPixelFormat: MTLPixelFormatRGBA8Unorm];
    [descriptor setStorageMode: MTLStorageModeShared];
    [descriptor setUsage: MTLTextureUsageShaderWrite];
    return [self.device newTextureWithDescriptor: descriptor];
}

-(void) modularWithFunction: (PrecompiledMetalFunction*)function texture: (id<MTLTexture>)texture a: (simd_float2)a b: (simd_float2)b power: (float)power
{
    
    [self performCompiledMetalFunction: function numWidth: texture.width numHeight: texture.height commandEncoderConfiguration:^(id<MTLComputeCommandEncoder> _Nonnull encoder) {
        [encoder setTexture: texture atIndex: 0];
        
        id<MTLBuffer> aBuffer = [self.device newBufferWithBytes: &a length: sizeof( simd_float2 ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: aBuffer offset: 0 atIndex: 0];
        
        id<MTLBuffer> bBuffer = [self.device newBufferWithBytes: &b length: sizeof( simd_float2 ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: bBuffer offset: 0 atIndex: 1];
        
        id<MTLBuffer> powerBuffer = [self.device newBufferWithBytes: &power length: sizeof( float ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: powerBuffer offset: 0 atIndex: 2];
    }];
}

@end
