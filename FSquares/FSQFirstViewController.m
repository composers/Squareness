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
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


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
    UIImageView *cameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
    cameraImageView.image = [UIImage imageNamed:@"camera_gray.png"];
    cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    page1.titleIconView = cameraImageView;
    page1.titleIconPositionY = 200;
    page1.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page1.descFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    page1.descColor = [UIColor grayColor];
    page1.bgColor = [UIColor blackColor];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"r a n d o m n e s s";
    page2.desc = @"Using the grid button above the image, you can apply effects to all the squares randomly. Only the effects included in the carousel are taken into consideration.";
    
    UIImageView *randomnessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
    randomnessImageView.image = [UIImage imageNamed:@"randomness_gray.png"];
    randomnessImageView.contentMode = UIViewContentModeScaleAspectFit;

    page2.titleIconView = randomnessImageView;
    page2.titleIconPositionY = 200;
    page2.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page2.descFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    page2.descColor = [UIColor grayColor];
    page2.bgColor = [UIColor blackColor];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"r e s e t";
    page3.desc = @"If you need to undo the applied effects for a particular square, just double tap on the square. If you need to start over with the original photo, tap on the reset button.";
    UIImageView *resetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
    resetImageView.image = [UIImage imageNamed:@"reset_gray.png"];
    resetImageView.contentMode = UIViewContentModeScaleAspectFit;
    page3.titleIconView = resetImageView;
    page3.titleIconPositionY = 200;
    page3.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page3.descFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    page3.descColor = [UIColor grayColor];
    page3.bgColor = [UIColor blackColor];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"s t r i p e s";
    page4.desc = @"You can apply an effect to horizontal or vertical stripes of squares. Just tap on a square, and then long-press on another square that is on the same vertical or horizontal line.";
    UIImageView *stripesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
    stripesImageView.image = [UIImage imageNamed:@"stripes_gray.png"];
    stripesImageView.contentMode = UIViewContentModeScaleAspectFit;
    page4.titleIconView = stripesImageView;
    page4.titleIconPositionY = 200;
    page4.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page4.descFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    page4.descColor = [UIColor grayColor];
    page4.bgColor = [UIColor blackColor];
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"c o n f i g u r e";
    page5.desc = @"Using the in-app settings, you can apply a grid around the squares, change the square size or add/remove effects from the carousel. By default, all available effects are included.";
    
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_settings_icon.ico"]];
    page5.titleIconPositionY = 200;
    page5.titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    page5.descFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    page5.descColor = [UIColor grayColor];
    page5.bgColor = [UIColor blackColor];
    
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

-(void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
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

@end
