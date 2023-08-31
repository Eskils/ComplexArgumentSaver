//
//  Renderer.h
//  ComplexArgument
//
//  Created by Eskil Gjerde Sviggum on 07/11/2022.
//

#import "MetalFunctions.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <GameplayKit/GameplayKit.h>
#import <ScreenSaver/ScreenSaver.h>

NS_ASSUME_NONNULL_BEGIN

@interface Renderer : NSObject

@property simd_float2 a;
@property simd_float2 b;
@property float sqrtPow;
@property float power;
@property MetalFunctions *metalFunctions;
@property id<MTLTexture> texture;
@property PrecompiledMetalFunction* modularMetalFunction;
@property int size;
@property void *buffer;
@property NSArray<GKNoise*> *noiseGenerators;
@property float t;
@property float deltaT;
@property bool isRendering;
@property NSMutableArray<NSImageView*> *imageViews;

+ (instancetype)sharedRenderer;
- (void)animateOneFrame;
- (void)addImageView: (NSImageView*)imageView;

@end

NS_ASSUME_NONNULL_END
