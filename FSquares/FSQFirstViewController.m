//
//  FSQFirstViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "UIImage+Resize.h"
#import "FSQModelController.h"
#import "MLPSpotlight.h"
#import "CarouselViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"


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
    //[MLPSpotlight addSpotlightInView:self.view atPoint:self.view.center];
    
    
    
    for (UIView *square in self.view.subviews) {
        if ([square isKindOfClass:[UIButton class]]) {
            continue;
        }
        [square.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [square.layer setBorderWidth: 2.0];
    }


    
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

- (IBAction)takePhotoWithCamera:(UIButton *)sender {
  
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
  
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        modelController.image = image;
        
        [photoPicker dismissViewControllerAnimated:YES completion:nil];
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
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
    }
    else{
        //user chose cancel
    }
}

- (IBAction)saveImage:(UIButton *)sender {
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    if (modelController.gridStatus == YES) {
        [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    }
    modelController.image = [modelController snapshot:carouselController.scrollView];
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
