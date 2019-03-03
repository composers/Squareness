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
#import "EAIntroPage+customPage.h"
#import "EAIntroView.h"
#import "UIImage+Rotate.h"
#import "UIImage+Resize.h"
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


@interface FSQFirstViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, assign) BOOL imageRotated;
@property (nonatomic, retain) UIDocumentInteractionController *documentInteractionController;
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
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (status == PHAuthorizationStatusDenied) {
        [self openAppSettings];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            } else {
                [self openAppSettings];
            }
        }];
    }
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}

- (IBAction)takePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if(authStatus == AVAuthorizationStatusDenied){
            [self openAppSettings];
        } else if(authStatus == AVAuthorizationStatusRestricted){
            // restricted, normally won't happen
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
            // not determined?!
            [AVCaptureDevice requestAccessForMediaType:mediaType
                                     completionHandler:^(BOOL granted) {
                if(granted){
                    [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                } else {
                    [self openAppSettings];
                }
            }];
        } else {
            // impossible, unknown authorization status
        }
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
                
        //Find the closes height (upper limit) that is a multiple of largest square size
        int temp1 = (int)LARGEST_SQUARE_SIZE * 3 * image.size.height/image.size.width;
        int temp2;
        if (temp1 % (int)LARGEST_SQUARE_SIZE == 0)
        {
            temp2 = (temp1 / LARGEST_SQUARE_SIZE);
        }
        else
        {
            temp2 = (temp1 / LARGEST_SQUARE_SIZE) + 1;
        }
        
        CGSize newSize = CGSizeMake(LARGEST_SQUARE_SIZE * 3, temp2 * LARGEST_SQUARE_SIZE);
        
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
        
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        CGFloat scrollViewHeight = screenFrame.size.width * self.sharedModel.image.size.height / self.sharedModel.image.size.width;
        carouselController.scrollView.contentSize = CGSizeMake(screenFrame.size.width, scrollViewHeight);
        
        [carouselController divideOriginalImage];
        [carouselController divideProcessedImage];
        [carouselController addGestureRecognizersToSubviews];
        
        self.sharedModel.selectedSubImageView = carouselController.scrollView.subviews[1];
        [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
        
        [carouselController.carousel reloadData];
        
        [self.sidePanelController showCenterPanelAnimated:NO];
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
                                                         andMessage:@"Unable to save. Check your app settings"];
        
        [alertView addButtonWithTitle:@"Go to settings"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [alert dismissAnimated:YES];
                                  [self openAppSettings];
                              }];
        [alertView addButtonWithTitle:@"Cancel"
                                 type:SIAlertViewButtonTypeCancel
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
            [self.sidePanelController showCenterPanelAnimated:YES];
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
    
    //Create path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"squarenessPhoto.png"];
    
    //Save image
    [UIImagePNGRepresentation(imageToShare) writeToFile:filePath atomically:YES];
    CGRect rect = CGRectMake(0, 0, 0, 0);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIGraphicsEndImageContext();
    
    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc]
                                                            initWithFormat:@"file://%@", filePath]];
    self.documentInteractionController.UTI = @"com.instagram.photo";
    self.documentInteractionController = [self setupControllerWithURL:igImageHookFile
                              usingDelegate:self];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    [self.documentInteractionController presentOpenInMenuFromRect:rect
                                 inView:self.view
                               animated:YES];
}

- (IBAction)displayInfo:(UIButton *)sender {
    
    EAIntroPage *page1 = [EAIntroPage customPage];
    page1.title = @"photo";
    page1.desc = @"Pick or take a photo. Then tap anywhere and apply an effect using the list in the bottom. You can always play around with the default image before choosing your own.";
    
    EAIntroPage *page2 = [EAIntroPage customPage];
    page2.title = @"randomize";
    page2.desc = @"Using the randomize button, you can apply effects to all the squares randomly. Only the effects included in the list are used.";
    
    EAIntroPage *page3 = [EAIntroPage customPage];
    page3.title = @"reset";
    page3.desc = @"If you need to undo the applied effects for a particular square, just double tap on that square. If you need to start over with the original photo, tap on the reset button.";
    
    EAIntroPage *page4 = [EAIntroPage customPage];
    page4.title = @"stripes";
    page4.desc = @"You can apply effects to horizontal or vertical stripes. Tap on a square, and then long-press on another square that is on the same vertical or horizontal line.";
    
    EAIntroPage *page5 = [EAIntroPage customPage];
    page5.title = @"configure";
    page5.desc = @"Using the options menu, you can apply a grid around the squares, change the square size or add/remove effects from the list.";
    
    EAIntroView *introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4, page5]];
    introView.pageControl.pageIndicatorTintColor = [UIColor darkTextColor];
    introView.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    [introView.skipButton setTitleColor:[UIColor grayColor]
                               forState:UIControlStateNormal];
    [introView setDelegate:self];
    [introView showInView:self.sidePanelController.view
          animateDuration:0.2];
}

- (void)introDidFinish:(EAIntroView *)introView{
    introView = nil;
}

- (void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = sourceType;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)openAppSettings {
    NSURL *appSettingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:appSettingsURL]) {
        [[UIApplication sharedApplication] openURL:appSettingsURL
                                           options:@{}
                                 completionHandler:nil];
    }
}

- (UIDocumentInteractionController *)setupControllerWithURL:(NSURL*)fileURL
                                              usingDelegate:(id<UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

@end
