//
//  PrecompiledMetalFunction.h
//  ComplexArgument
//
//  Created by Eskil Sviggum on 09/10/2022.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrecompiledMetalFunction : NSObject

@property id<MTLCommandQueue> commandQueue;
@property id<MTLComputePipelineState> pipelineState;
@property NSUInteger mx;

+(PrecompiledMetalFunction*) precompiledMetalFunctionWithCommandQueue: (id<MTLCommandQueue>)commandQueue piplineState: (id<MTLComputePipelineState>)pipelineState andMx: (NSUInteger)mx;

@end

NS_ASSUME_NONNULL_END
