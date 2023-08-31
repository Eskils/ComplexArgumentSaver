//
//  ComplexArgumentView.h
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#import "MetalFunctions.h"
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <ScreenSaver/ScreenSaver.h>
#import "Renderer.h"

@interface ComplexArgumentView : ScreenSaverView

@property Renderer *renderer;

- (void)animateOneFrame;

@end
