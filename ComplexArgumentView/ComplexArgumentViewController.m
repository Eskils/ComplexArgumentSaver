//
//  ComplexArgumentViewController.m
//  ComplexArgumentView
//
//  Created by Eskil Sviggum on 09/10/2022.
//

#import "ComplexArgumentViewController.h"

@interface ComplexArgumentViewController ()

@property CVDisplayLinkRef displayLink;
@property ComplexArgumentView *complexArgumentView;

@end

@implementation ComplexArgumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.view setWantsLayer: YES];
    [self.view.layer setBackgroundColor: NSColor.systemRedColor.CGColor];
    
    self.complexArgumentView = [[ComplexArgumentView alloc] init];
    [self.view addSubview: self.complexArgumentView];
    
    [self.complexArgumentView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [NSLayoutConstraint activateConstraints: @[
       [self.complexArgumentView.topAnchor       constraintEqualToAnchor: self.view.topAnchor],
       [self.complexArgumentView.bottomAnchor    constraintEqualToAnchor: self.view.bottomAnchor],
       [self.complexArgumentView.leadingAnchor   constraintEqualToAnchor: self.view.leadingAnchor],
       [self.complexArgumentView.trailingAnchor  constraintEqualToAnchor: self.view.trailingAnchor],
    ]];
}

- (void)viewDidAppear
{
    [self.complexArgumentView startAnimation];
}

- (void)viewDidDisappear
{
    [self.complexArgumentView stopAnimation];
}

@end
