//
//  ComplexArgumentView.m
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import "ComplexArgumentView.h"

@implementation ComplexArgumentView {
    NSImageView *imageView;
    CGSize originalSize;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        self.renderer = [Renderer sharedRenderer];
        
//        if ((int)frame.size.width > self.renderer.size) {
//            self.renderer.size = (int)frame.size.width;
//        }
        
        self->originalSize = frame.size;
        
        NSImageView *imageView = [[NSImageView alloc] init];
        [self setupImageView: imageView withRect: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.renderer addImageView:imageView];
        
        self->imageView = imageView;
        
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)setupImageView: (NSImageView*)imageview withRect: (NSRect)rect
{
    [self addSubview: imageview];
    [imageview setImageScaling: NSImageScaleAxesIndependently];
    [imageview setFrame: rect];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)animateOneFrame
{
    [imageView setFrame: self.bounds];
    [self.renderer animateOneFrame];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void)viewDidChangeBackingProperties {
    [imageView setFrame: CGRectMake(0, 0, originalSize.width, originalSize.height)];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    NSRect converted = [self convertRectToBacking: self.bounds];
    [imageView setFrame: converted];
}

@end
