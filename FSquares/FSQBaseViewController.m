//
//  FSQBaseViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 3/19/16.
//  Copyright © 2016 Stefan Stolevski. All rights reserved.
//

#import "FSQBaseViewController.h"
#import "InstagramActivityIndicator.h"

@interface FSQBaseViewController ()
@property (nonatomic, strong) InstagramActivityIndicator *loadingIndicator;
@end

@implementation FSQBaseViewController
- (instancetype)initWithModel:(FSQModelController *)model
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.sharedModel = model;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithModel:nil];
    if (self) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Use initWithModel instead"
                                     userInfo:nil];
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingIndicator = [[InstagramActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.lineWidth = 6;
    self.loadingIndicator.strokeColor = [UIColor whiteColor];
    self.loadingIndicator.numSegments = 15;
    self.loadingIndicator.rotationDuration = 10;
    self.loadingIndicator.animationDuration = 1.0;
    self.loadingIndicator.center = self.view.center;
}

- (void)startLoading
{
    self.view.userInteractionEnabled = NO;
    [self.view addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
}

- (void)stopLoading
{
    [self.loadingIndicator stopAnimating];
    [self.loadingIndicator removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}


@end
