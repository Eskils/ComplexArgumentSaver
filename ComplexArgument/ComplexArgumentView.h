//
//  ComplexArgumentView.h
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import "MetalFunctions.h"
#import <GameplayKit/GameplayKit.h>
#import <ScreenSaver/ScreenSaver.h>

@interface ComplexArgumentView : ScreenSaverView

@property CVDisplayLinkRef displayLink;
@property simd_float2 a;
@property simd_float2 b;
@property float power;
@property MetalFunctions *metalFunctions;
@property id<MTLTexture> texture;
@property PrecompiledMetalFunction* modularMetalFunction;
@property NSImageView *imageView;
@property int size;
@property void *buffer;
@property NSArray<GKNoise*> *noiseGenerators;
@property float t;
@property float deltaT;
@property bool isRendering;

- (void)animateOneFrame;

@end
