//
//  FSQFirstViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
//#import "UIImage+Resize.h"
#import "FSQModelController.h"
#import "CarouselViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "SIAlertView.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
//#import <FacebookSDK/FacebookSDK.h>


@interface FSQFirstViewController ()

@end

@implementation FSQFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)selectPhotoFromAlbum:(UIButton *)sender {
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        modelController.originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        modelController.image = [UIImage imageWithCGImage:newCgIm scale:image.scale orientation:image.imageOrientation];
        
        [photoPicker dismissViewControllerAnimated:YES completion:nil];
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        modelController.originalSubImageViews = [modelController divideOriginalImage];
        [modelController putSubImageViews:[modelController divideImage] InView:carouselController.scrollView];
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
        
        if (modelController.gridStatus == YES) {
            [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
        }
        if (modelController.gridStatus == NO) {
            [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
        }
        
        
        carouselController.carousel.delegate = carouselController;
        carouselController.carousel.dataSource = carouselController;
        
        modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
        
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
      
      [carouselController.carousel reloadData];
    }
    else{
        //user chose cancel
        
    }
}

- (IBAction)saveImage:(UIButton *)sender {
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    

    [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
    }
    
    modelController.image = [modelController scrollViewSnapshot:carouselController.scrollView];
    UIImageWriteToSavedPhotosAlbum(modelController.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    
    if(!error)
    {
        alertTitle   = @"p h o t o   s a v e d";
        alertMessage = @"photo saved to the photo library";
    }
    else
    {
        alertTitle   = @"E r r o r";
        alertMessage = @"Unable to save to photo library";
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertMessage];
    
    [alertView addButtonWithTitle:@"O K"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [alert dismissAnimated:YES];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleColor = [UIColor grayColor];
    alertView.messageColor = [UIColor grayColor];
    
    
    [alertView show];

}

- (IBAction)displayInfo:(UIButton *)sender {
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"p h o t o";
    page1.desc = @"Import a photo from the photo library. Pick a square area from the photo and apply an effect using the carousel in the bottom. You can always play around with the default image before choosing your own.";
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_mountain.ico"]];
    page1.titleIconPositionY = 200;
    page1.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page1.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page1.descColor = [UIColor grayColor];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"r a n d o m n e s s";
    page2.desc = @"Using the grid button above the image, you can apply effects to all the squares randomly. Only the effects included in the carousel are taken into consideration.";
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"random_icon.ico"]];
    page2.titleIconPositionY = 200;
    page2.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page2.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page2.descColor = [UIColor grayColor];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"r e s e t";
    page3.desc = @"If you need to undo the applied effects for a particular square, just double tap on the square. If you need to start over with the original photo, tap on the reset button.";
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_grid.ico"]];
    page3.titleIconPositionY = 200;
    page3.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page3.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page3.descColor = [UIColor grayColor];

    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"c o n f i g u r e";
    page4.desc = @"Using the in-app settings, you can apply a grid around the squares, change the square size or add/remove effects from the carousel. By default, all available effects are included.";
    
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_settings_icon.ico"]];
    page4.titleIconPositionY = 200;
    
    page4.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page4.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page4.descColor = [UIColor grayColor];
    
    EAIntroView *introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4]];
    
    page1 = nil;
    page2 = nil;
    page3 = nil;
    page4 = nil;
    
    [introView setDelegate:self];
    
    [introView showInView:self.sidePanelController.view animateDuration:0.2];
}

- (void)introDidFinish:(EAIntroView *)introView{
    introView = nil;
}

- (IBAction)resetImage:(UIButton *)sender {
    CGImageRef newCgIm = CGImageCreateCopy(modelController.originalImage.CGImage);
    
    modelController.image = [UIImage imageWithCGImage:newCgIm scale:modelController.originalImage.scale orientation:modelController.originalImage.imageOrientation];
    
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        [modelController putSubImageViews:[modelController divideImage] InView:carouselController.scrollView];
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
        
        if (modelController.gridStatus == YES) {
            [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
        }
    
    
        modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
        
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
        
        [carouselController.carousel reloadData];
    
}




- (IBAction)shareImage:(UIButton *)sender {
//    // If the Facebook app is installed and we can present the share dialog
//    if ([FBDialogs canPresentShareDialogWithPhotos]) {
//        FBPhotoParams *params = [[FBPhotoParams alloc] init];
//        
//        // Note that params.photos can be an array of images.  In this example
//        // we only use a single image, wrapped in an array.
//        params.photos = @[modelController.image];
//        
//        [FBDialogs presentShareDialogWithPhotoParams:params
//                                         clientState:nil
//                                             handler:^(FBAppCall *call,
//                                                       NSDictionary *results,
//                                                       NSError *error) {
//                                                 if (error) {
//                                                     NSLog(@"Error: %@",
//                                                           error.description);
//                                                 } else {
//                                                     NSLog(@"Success!");
//                                                 }
//                                             }];
//
//       
//    } else {
//        // The user doesn't have the Facebook for iOS app installed.  You
//        // may be able to use a fallback.
//    }
}


@end
