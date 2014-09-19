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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for (UIView *square in self.view.subviews) {
        if ([square isKindOfClass:[UIButton class]]) {
            continue;
        }
        [square.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [square.layer setBorderWidth: 2.0];
    }
    

    self.saveImageButton.enabled = NO;
    self.saveImageButton.alpha = 0.3;
    
    self.resetImageButton.enabled = NO;
    self.resetImageButton.alpha = 0.3;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.9
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated{
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [modelController putSubImageViews:[modelController divideImage:modelController.image] InView:carouselController.scrollView];
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
      [carouselController.scrollView removeGestureRecognizer:carouselController.tapBackground];
        
        self.saveImageButton.enabled = YES;
        self.saveImageButton.alpha = 1.0;
        
        self.resetImageButton.enabled = YES;
        self.resetImageButton.alpha = 1.0;
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
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Squareness" andMessage:@"Ready to give your image all the squareness it needs and create new and exciting digital art? With this app, you divide an image into squares and apply different effect to each! Just tap on a square and choose an effect from the carousel in the bottom of the screen. If you are feeling lazy, you can always let the app apply random effects using the button above the image. If you get bored try changing the square size..."];
    
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
        
        [modelController putSubImageViews:[modelController divideImage:modelController.image] InView:carouselController.scrollView];
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
        
        if (modelController.gridStatus == YES) {
            [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
        }
    
    
        modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
        
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
        
        [carouselController.carousel reloadData];
    
}




@end
