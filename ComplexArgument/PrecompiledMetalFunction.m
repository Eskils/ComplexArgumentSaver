//
//  PrecompiledMetalFunction.m
//  ComplexArgument
//
//  Created by Eskil Sviggum on 09/10/2022.
//

#import "PrecompiledMetalFunction.h"

@implementation PrecompiledMetalFunction

+(PrecompiledMetalFunction*) precompiledMetalFunctionWithCommandQueue: (id<MTLCommandQueue>)commandQueue piplineState: (id<MTLComputePipelineState>)pipelineState andMx: (NSUInteger)mx
{
    PrecompiledMetalFunction *precompiledFunction = [[PrecompiledMetalFunction alloc] init];
    precompiledFunction.commandQueue = commandQueue;
    precompiledFunction.pipelineState = pipelineState;
    precompiledFunction.mx = mx;
    return precompiledFunction;
}

@end
