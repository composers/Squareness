//
//  FSQBaseViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 3/19/16.
//  Copyright © 2016 Stefan Stolevski. All rights reserved.
//

#import "FSQBaseViewController.h"
#import "DDIndicator.h"

@interface FSQBaseViewController ()
@property (nonatomic, strong) DDIndicator *loadingIndicator;
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
    self.loadingIndicator = [[DDIndicator alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
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
