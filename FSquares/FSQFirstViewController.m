//
//  FSQFirstViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "UIImage+Resize.h"
#import "FSQModelController.h"
#import "CarouselViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "SIAlertView.h"
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
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertMessage];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [alert dismissAnimated:YES];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleColor = [UIColor lightGrayColor];
    alertView.messageColor = [UIColor grayColor];
    
    
    [alertView show];

}

- (IBAction)displayInfo:(UIButton *)sender {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Usage" andMessage:@"Import an image from the photo library. Pick a square area from the image and apply an effect using the carousel in the bottom. By clicking the grid button above the image, you can apply effects to all the squares randomly. Using the in-app settings, you can apply a grid around the squares, change the square size or remove/select an effect from the carousel. If you need to undo the applied effects for a particular square, just double tap on the square"];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [alert dismissAnimated:YES];
                          }];
 
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleColor = [UIColor lightGrayColor];
    alertView.messageColor = [UIColor grayColor];

    
    [alertView show];

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
