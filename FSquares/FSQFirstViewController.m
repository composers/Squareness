//
//  FSQFirstViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "CarouselViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "SIAlertView.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
#import "UIImage+Rotate.h"
#import "UIImage+Resize.h"
#import <Social/Social.h>


@interface FSQFirstViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, assign) BOOL imageRotated;
@end

@implementation FSQFirstViewController

- (instancetype)initWithModel:(FSQModelController *)model
{
    self = [super initWithModel:model];
    if (self) {
        _imageRotated = NO;
    }
    return self;
}

- (IBAction)selectPhotoFromAlbum:(UIButton *)sender
{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (IBAction)takePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.delegate = self;
        photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:photoPicker animated:YES completion:NULL];
    }
    else
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"I n f o"
                                                         andMessage:@"Camera not available"];
        
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
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image)
    {
        if (image.size.height < image.size.width)
        {
            image = [image imageRotatedByDegrees:90];
            self.imageRotated = YES;
        }
        else
        {
            self.imageRotated = NO;
        }
                
        //Find the closes height (upper limit) that is a multiple of 320 (full largest squares)
        int temp1 = (int) 960 * image.size.height/image.size.width;
        int temp2;
        if (temp1 % 320 == 0)
        {
            temp2 = (temp1 / 320);
        }
        else
        {
            temp2 = (temp1 / 320) + 1;
        }
        CGSize newSize = CGSizeMake(960.0, temp2 * 320);
        
        image = [image scaleImageToSize:newSize];
        
        self.sharedModel.originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                     scale:image.scale
                                               orientation:image.imageOrientation];
        CGImageRelease(newCgIm);
        
        [photoPicker dismissViewControllerAnimated:YES completion:nil];
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
        CGFloat scrollViewHeight = screenFrame.size.width * self.sharedModel.image.size.height / self.sharedModel.image.size.width;
        carouselController.scrollView.contentSize = CGSizeMake(screenFrame.size.width, scrollViewHeight);
        
        [carouselController divideOriginalImage];
        [carouselController divideProcessedImage];
        [carouselController addGestureRecognizersToSubviews];
        
        self.sharedModel.selectedSubImageView = carouselController.scrollView.subviews[1];
        [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
        
        [carouselController.carousel reloadData];
    }
    else
    {
        //user chose cancel
    }
}

- (IBAction)saveImage:(UIButton *)sender {
    
    [self startLoading];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sharedModel generateImageFromSubimages];
        
        UIImage *imageToSave;
        if (self.imageRotated)
        {
            imageToSave = [self.sharedModel.image imageRotatedByDegrees:-90];
        }
        else
        {
            imageToSave = self.sharedModel.image;
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self stopLoading];
    if(error)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"e r r o r"
                                                         andMessage:@"Unable to save to photo library"];
        
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
}

- (IBAction)resetImage:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef newCgIm = CGImageCreateCopy(self.sharedModel.originalImage.CGImage);
        self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                     scale:self.sharedModel.originalImage.scale
                                               orientation:self.sharedModel.originalImage.imageOrientation];
        CGImageRelease(newCgIm);
        
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [carouselController divideProcessedImage];
            [carouselController addGestureRecognizersToSubviews];
            
            self.sharedModel.selectedSubImageView = carouselController.scrollView.subviews[1];
            
            [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
            
            [carouselController.carousel reloadData];
        });
    });
}

- (IBAction)shareImage:(UIButton *)sender
{
    [self.sharedModel generateImageFromSubimages];
    
    UIImage *imageToShare;
    if (self.imageRotated)
    {
        imageToShare = [self.sharedModel.image imageRotatedByDegrees:-90];
    }
    else
    {
        imageToShare = self.sharedModel.image;
    }
    
    SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [mySLComposerSheet setInitialText:@"#squareness\nAvailable on the App Store\n"];
    [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/mk/app/squareness/id914835206?mt=8"]];
    [mySLComposerSheet addImage:imageToShare];
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Post Canceled");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Post Sucessful");
                break;
                
            default:
                break;
        }
    }];
    
    [self presentViewController:mySLComposerSheet animated:YES completion:nil];
}

- (IBAction)displayInfo:(UIButton *)sender {
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"p h o t o";
    page1.desc = @"Import a photo or take one with the camera. Pick a square area from the photo and apply an effect using the carousel in the bottom. You can always play around with the default image before choosing your own.";
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
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

@end
