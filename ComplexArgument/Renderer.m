//
//  Renderer.m
//  ComplexArgument
//
//  Created by Eskil Gjerde Sviggum on 07/11/2022.
//

#import "Renderer.h"

@interface Renderer ()
- (instancetype)initWithSize: (int)size;
@end

@implementation Renderer

static Renderer *sharedRenderer = nil;

+(instancetype)sharedRenderer {
    if (sharedRenderer == nil) {
        sharedRenderer = [[Renderer alloc] initWithSize: 2000];
    }
    return sharedRenderer;
}

-(GKNoise*)makeBillowNoise {
    double frequency = 0.5;
    NSInteger octaveCount = 2;
    double persistence = 0.5;
    double lacunarity = 0.5;
    int32_t seed = arc4random();
    
    GKNoiseSource *source = [[GKBillowNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed:seed];
    return [[GKNoise alloc] initWithNoiseSource:source];
}

-(GKNoise*)makePerlinNoise {
    double frequency = 0.5;
    NSInteger octaveCount = 2;
    double persistence = 0.5;
    double lacunarity = 0.5;
    int32_t seed = arc4random();
    
    GKNoiseSource *source = [[GKPerlinNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed:seed];
    return [[GKNoise alloc] initWithNoiseSource:source];
}

-(GKNoise*)makeSineNoiseWithFrequency: (CGFloat)frequency {
    GKNoiseSource *source = [[GKSpheresNoiseSource alloc] initWithFrequency: frequency];
    return [[GKNoise alloc] initWithNoiseSource:source];
}

-(GKNoise*)makeVoronoiNoise {
    double frequency = 0.5;
    double displacement = 0.5;
    int32_t seed = arc4random();
    
    GKNoiseSource *source = [[GKVoronoiNoiseSource alloc] initWithFrequency:frequency displacement:displacement distanceEnabled:YES seed:seed];
    return [[GKNoise alloc] initWithNoiseSource:source];
}

- (instancetype)initWithSize: (int)size {
    self = [super init];
    if (self) {
        NSLog(@"Making Screensaver");
        self.a = simd_make_float2(0.4, 0.4);
        self.b = simd_make_float2(0.4, 0.4);
        self.sqrtPow = 0.5;
        self.power = -1;
        self.t = 0;
        self.deltaT = 0.01;
        self.isRendering = false;
        
        if (size == 0) {
            self.size = 1000;
        } else {
            self.size = size;
        }
        
        self.noiseGenerators = @[
            [self makeVoronoiNoise]
        ];
        
        self.metalFunctions = [[MetalFunctions alloc] init];
        self.texture = [self.metalFunctions makeTextureOfSize: (NSUInteger)self.size];
        self.modularMetalFunction = [self.metalFunctions precompileMetalFunctionWithName: @"modular"];
        
        self.imageViews = [NSMutableArray array];
    }
    return self;
}

- (NSImage*)imageFromTexture: (id<MTLTexture>)texture
{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSDictionary<CIImageOption, id> *options = @{
        kCIImageColorSpace: CFBridgingRelease(colorSpace)
    };
    CIImage *ciImage = [CIImage imageWithMTLTexture: texture options: options];
    NSCIImageRep *ciImageRep = [[NSCIImageRep alloc] initWithCIImage: ciImage];
    NSImage *image = [[NSImage alloc] initWithSize: ciImage.extent.size];
    [image addRepresentation: ciImageRep];
    
    return image;
}

- (void)animateOneFrame {
    if (self.isRendering) {
        return;
    }
    self.isRendering = true;
    
    GKNoise *sqrtPowNoise = [self.noiseGenerators objectAtIndex: 0];
    vector_float2 position = simd_make_float2(self.t, 0);
    
    self.a = simd_make_float2(cosf(self.t) * 3, sinf(self.t) * 3);
    self.b = simd_make_float2(-sinf(self.t / 5) * 2, -sinf(self.t / 5) * 2);
    self.sqrtPow = 0.5 * [sqrtPowNoise valueAtPosition: position] + 0.5;
    
    [self.metalFunctions modularWithFunction: self.modularMetalFunction
                                     texture: self.texture
                                           a: self.a
                                           b: self.b
                                       power: self.power
                                     sqrtPow: self.sqrtPow];
    
    NSImage *image = [self imageFromTexture: self.texture];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageViews enumerateObjectsUsingBlock:^(NSImageView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
            [imageView setImage: image];
        }];
        self.isRendering = false;
    });
    
    self.t += self.deltaT;
}

- (void)addImageView: (NSImageView*)imageView {
    [self.imageViews addObject:imageView];
}

//- (void)setSize:(int)size {
//    self.texture = [self.metalFunctions makeTextureOfSize: (NSUInteger)size];
//}

@end
