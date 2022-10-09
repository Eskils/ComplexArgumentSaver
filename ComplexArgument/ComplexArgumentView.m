//
//  ComplexArgumentView.m
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import "ComplexArgumentView.h"

@implementation ComplexArgumentView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        
        self.a = simd_make_float2(0.4, 0.4);
        self.b = simd_make_float2(0.4, 0.4);
        self.power = 2;
        self.t = 0;
        self.deltaT = 0.001;
        self.isRendering = false;
        
        self.size = (int)MAX(frame.size.width, frame.size.height);
        if (self.size == 0) {
            self.size = 1000;
        }
        
        double frequency = 2;
        NSInteger octaveCount = 100;
        double persistence = 0.5;
        double lacunarity = 0.21;
        
        self.noiseGenerators = @[
            [[GKNoise alloc] initWithNoiseSource: [[GKPerlinNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed: arc4random()]],
            [[GKNoise alloc] initWithNoiseSource: [[GKPerlinNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed: arc4random()]],
            [[GKNoise alloc] initWithNoiseSource: [[GKPerlinNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed: arc4random()]],
            [[GKNoise alloc] initWithNoiseSource: [[GKPerlinNoiseSource alloc] initWithFrequency:frequency octaveCount:octaveCount persistence:persistence lacunarity:lacunarity seed: arc4random()]],
        ];
        
        self.metalFunctions = [[MetalFunctions alloc] init];
        self.texture = [self.metalFunctions makeTextureOfSize: (NSUInteger)self.size];
        self.modularMetalFunction = [self.metalFunctions precompileMetalFunctionWithName: @"modular"];
        
        self.buffer = malloc( sizeof(uint8_t) * self.size * self.size * 4 );
        
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)setupImageView: (NSImageView*)imageview withRect: (NSRect)rect
{
    [self addSubview: imageview];
    [imageview setFrame: rect];
}

- (NSImage*)imageFromTexture: (id<MTLTexture>)texture
{
    NSUInteger bytesPerRow = 4 * self.size;
    MTLRegion region = MTLRegionMake2D(0, 0, self.size, self.size);
    [texture getBytes: self.buffer bytesPerRow:bytesPerRow fromRegion: region mipmapLevel: 0];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint32_t bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGContextRef context = CGBitmapContextCreate(self.buffer, self.size, self.size, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size: NSMakeSize(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage))];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    
    return image;
}

- (void)startAnimation
{
    [super startAnimation];
    
    /*CVDisplayLinkRef displayLink;
    CVDisplayLinkCreateWithCGDisplay(CGMainDisplayID(), &displayLink);
    if (displayLink) {
        self.displayLink = displayLink;
        CVDisplayLinkSetOutputHandler(displayLink, ^CVReturn(CVDisplayLinkRef  _Nonnull displayLink, const CVTimeStamp * _Nonnull inNow, const CVTimeStamp * _Nonnull inOutputTime, CVOptionFlags flagsIn, CVOptionFlags * _Nonnull flagsOut) {
            @autoreleasepool {
                [self animateOneFrame];
                return kCVReturnSuccess;
            }
        });
        CVDisplayLinkStart(displayLink);
    }*/
}

- (void)stopAnimation
{
    [super stopAnimation];
    /*if (self.displayLink) {
        CVDisplayLinkStop(self.displayLink);
        CVDisplayLinkRelease(self.displayLink);
    }*/
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    self.imageView = [[NSImageView alloc] init];
    [self setupImageView: self.imageView withRect: rect];
    [self startAnimation];
}

- (void)animateOneFrame
{
    if (self.isRendering) {
        return;
    }
    
    GKNoise *aReNoise = [self.noiseGenerators objectAtIndex: 0];
    GKNoise *aImNoise = [self.noiseGenerators objectAtIndex: 1];
    GKNoise *bReNoise = [self.noiseGenerators objectAtIndex: 2];
    GKNoise *bImNoise = [self.noiseGenerators objectAtIndex: 3];
    
    vector_float2 position = simd_make_float2(self.t, 0);
    
    self.a = simd_make_float2([aReNoise valueAtPosition:position], [aImNoise valueAtPosition:position]);
    self.b = simd_make_float2([bReNoise valueAtPosition:position], [bImNoise valueAtPosition:position]);
    self.isRendering = true;
    [self.metalFunctions modularWithFunction: self.modularMetalFunction texture: self.texture a: self.a b: self.b power: self.power];
    self.isRendering = false;
    NSImage *image = [self imageFromTexture: self.texture];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageView setImage: image];
    });
    
    self.t += self.deltaT;
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
