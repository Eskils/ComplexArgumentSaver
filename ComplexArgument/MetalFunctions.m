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
    NSError * error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    id<MTLLibrary> library = [self.device newDefaultLibraryWithBundle: bundle error: &error];
    if (error != NULL) {
        NSLog(@"Metal library is nil. Aborting with error %@", error);
        abort();
    }
    
    id<MTLFunction> function = [library newFunctionWithName: name];
    
    if (function == NULL) {
        NSLog(@"Metal function is nil. Aborting");
        abort();
    }
    
    id<MTLComputePipelineState> pipelineState = [self.device newComputePipelineStateWithFunction: function error: &error];
    if (error != NULL) {
        NSLog(@"Aborting with pipelineStateError: %@", error);
        abort();
    }
    
    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    MTLSize max = self.device.maxThreadsPerThreadgroup;
    NSUInteger mx = (NSUInteger)sqrtf((float)max.width);
    
    return [PrecompiledMetalFunction precompiledMetalFunctionWithCommandQueue: commandQueue piplineState: pipelineState andMx: mx];
}

-(void) performCompiledMetalFunction: (PrecompiledMetalFunction*)function numWidth: (NSUInteger)numWidth numHeight: (NSUInteger)numHeight texture: (id<MTLTexture>)texture commandEncoderConfiguration: (CommandEncoderConfigurationBlock)commandEncoderConfiguration
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
    
    if (texture) {
        id<MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
        [blitEncoder synchronizeTexture: texture slice: 0 level: 0];
        [blitEncoder endEncoding];
    }
    
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
    [descriptor setStorageMode: MTLStorageModeManaged];
    [descriptor setUsage: MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite];
    return [self.device newTextureWithDescriptor: descriptor];
}

-(void) modularWithFunction: (PrecompiledMetalFunction*)function texture: (id<MTLTexture>)texture a: (simd_float2)a b: (simd_float2)b power: (float)power sqrtPow: (float)sqrtPow
{
    
    [self performCompiledMetalFunction: function numWidth: texture.width numHeight: texture.height texture: texture commandEncoderConfiguration:^(id<MTLComputeCommandEncoder> _Nonnull encoder) {
        [encoder setTexture: texture atIndex: 0];
        
        id<MTLBuffer> aBuffer = [self.device newBufferWithBytes: &a length: sizeof( simd_float2 ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: aBuffer offset: 0 atIndex: 0];
        
        id<MTLBuffer> bBuffer = [self.device newBufferWithBytes: &b length: sizeof( simd_float2 ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: bBuffer offset: 0 atIndex: 1];
        
        id<MTLBuffer> powerBuffer = [self.device newBufferWithBytes: &power length: sizeof( float ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: powerBuffer offset: 0 atIndex: 2];
        
        id<MTLBuffer> sqrtPowBuffer = [self.device newBufferWithBytes: &sqrtPow length: sizeof( float ) options: MTLResourceStorageModeShared];
        [encoder setBuffer: sqrtPowBuffer offset: 0 atIndex: 3];
    }];
}

@end
