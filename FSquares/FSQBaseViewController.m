//
//  FSQBaseViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 3/19/16.
//  Copyright © 2016 Stefan Stolevski. All rights reserved.
//

#import "FSQBaseViewController.h"

@interface FSQBaseViewController ()

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


@end
