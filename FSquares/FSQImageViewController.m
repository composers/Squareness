//
//  FSQImageViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQImageViewController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "NSString+ContainsString.h"
#import "FSQModelController.h"
#import "FSQProcessSquareViewController.h"

@implementation FSQImageViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle: @"process image"
                                                                  image: nil //or your icon
                                                                    tag: 0];
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    CGFloat additionalHeight = self.tabBarController.tabBar.frame.size.height;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + additionalHeight);
    self.view = scrollView;
    
    FSQModelController *modelController = [FSQModelController sharedInstance];
    [modelController divideImage:modelController.image withBlockSize:modelController.gridSquareSize andPutInView:self.view];
    [modelController addGestureRecognizersToSubviewsFromViewController:self];
   }

- (void)viewWillAppear:(BOOL)animated{
    FSQModelController *modelController = [FSQModelController sharedInstance];
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:80/80 aroundImageViewsFromView:self.view];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:self.view];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.processedImage = [FSQModelController imageWithView:self.view];
}

- (void)tap:(UITapGestureRecognizer*)gesture
{

  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.selectedSubImageView = [modelController getImageViewWithTag:gesture.view.tag fromView:gesture.view.superview];
  
  if (modelController.usePreselectedFilterStatus == YES) {
    modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
    
  }
  
  if (modelController.usePreselectedFilterStatus == NO) {
    FSQProcessSquareViewController *processSquareController = [[FSQProcessSquareViewController alloc] init];
    [self presentViewController:processSquareController animated:YES completion:nil];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.image = nil;
  modelController.processedImage = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
