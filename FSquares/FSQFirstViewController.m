//
//  FSQFirstViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "FSQModelController.h"
#import "CarouselViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "SIAlertView.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
#import "UIImage+Rotate.h"
#import "UIImage+Resize.h"


@interface FSQFirstViewController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;

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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(squareFalling) withObject:self afterDelay:0.4];
}

-(void)squareFalling{
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.littleSquare]];
    [self.animator addBehavior:gravityBehavior];
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.littleSquare]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collisionBehavior];
    
    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.littleSquare]];
    elasticityBehavior.elasticity = 0.3f;
    [self.animator addBehavior:elasticityBehavior];
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
    
    if (image)
    {
        if (image.size.height < image.size.width)
        {
            image = [image imageRotatedByDegrees:90];
        }
        
        int imageWidth = (int)image.size.width;
        int imageHeight = (int)image.size.height;
        
        int newWidth = imageWidth - imageWidth % 160;
        int newHeight = imageHeight - imageHeight % 160;
        
        CGSize newSize = CGSizeMake(newWidth, newHeight);
        
        image = [image resizedImageToSize:newSize];
        
        modelController.originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        modelController.image = [UIImage imageWithCGImage:newCgIm scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(newCgIm);
        
        [photoPicker dismissViewControllerAnimated:YES completion:nil];
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        
        //TODO: No need to put in view original subImages -> change this
        modelController.originalSubImages = [modelController divideImage:modelController.originalImage withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
        //
        
        modelController.subImages = [modelController divideImage:modelController.image withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
        
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
                
        carouselController.carousel.delegate = carouselController;
        carouselController.carousel.dataSource = carouselController;
        
        modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
        
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
        
        [carouselController.carousel reloadData];
    }
    else
    {
        //user chose cancel
    }
}

- (IBAction)saveImage:(UIButton *)sender {
    
    modelController.image = [modelController generateImageFromSubimages:modelController.subImages];
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
        alertTitle   = @"e r r o r";
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
    alertView.titleColor = [UIColor darkGrayColor];
    alertView.messageColor = [UIColor darkGrayColor];
    alertView.alpha = 0.85;
    
    
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
    page4.title = @"s t r i p e s";
    page4.desc = @"You can apply an effect to horizontal or vertical stripes of squares. Just tap on a square, and then long-press on another square that is on the same vertical or horizontal line.";
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lines.ico"]];
    page4.titleIconPositionY = 200;
    page4.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page4.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page4.descColor = [UIColor grayColor];
    
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"c o n f i g u r e";
    page5.desc = @"Using the in-app settings, you can apply a grid around the squares, change the square size or add/remove effects from the carousel. By default, all available effects are included.";
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_settings_icon.ico"]];
    page5.titleIconPositionY = 200;
    
    page5.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page5.descFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    page5.descColor = [UIColor grayColor];
    
    EAIntroView *introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4, page5]];
    
    page1 = nil;
    page2 = nil;
    page3 = nil;
    page4 = nil;
    page5 = nil;
    
    [introView setDelegate:self];
    
    [introView showInView:self.sidePanelController.view animateDuration:0.2];
}

- (void)introDidFinish:(EAIntroView *)introView{
    introView = nil;
}

- (IBAction)resetImage:(UIButton *)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGImageRef newCgIm = CGImageCreateCopy(modelController.originalImage.CGImage);
        modelController.image = [UIImage imageWithCGImage:newCgIm scale:modelController.originalImage.scale orientation:modelController.originalImage.imageOrientation];
        CGImageRelease(newCgIm);
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        modelController.subImages = [modelController divideImage:modelController.image withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
        
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
        
        modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
        
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
        
        [carouselController.carousel reloadData];
    });
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
