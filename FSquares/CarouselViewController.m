//
//  CarouselViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/19/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "CarouselViewController.h"
#import "UIImage+Resize.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import "SIAlertView.h"
#import "UIImage+Border.h"
#import "UIView+Divide.h"
#import "UIImage+Rotate.h"
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "EAIntroPage+customPage.h"
#import "EAIntroView.h"
#import "UIImage+fixOrientation.h"
#import "FTPopOverMenu.h"
#import "InstagramActivityIndicator.h"

@interface CarouselViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentInteractionControllerDelegate, EAIntroDelegate>

@property(assign, nonatomic) NSUInteger selectedIndex;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *photosItem;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *cameraItem;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *shareItem;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property(strong, nonatomic) UIBarButtonItem *squareSizeBarButtonItem;
@property (nonatomic, assign) BOOL imageRotated;
@property (nonatomic, retain) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) EAIntroView *introView;
@end

@implementation CarouselViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageRotated = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.titleView = [self buttonForTitleView];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"]
                                                                              style:UIBarButtonItemStylePlain target:self action:@selector(toggleHelp)];
    infoBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *fixedBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                              target:nil
                                              action:nil];
    fixedBarButtonItem.width = 25.0;
    
    self.squareSizeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"M"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onSquareSizeButtonTapped:event:)];
    self.squareSizeBarButtonItem.tintColor = [UIColor whiteColor];
    [self.squareSizeBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:25.0 weight:UIFontWeightRegular], NSFontAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    
    UIBarButtonItem *gridBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grid"]
                                                                          style:UIBarButtonItemStylePlain target:self action:@selector(applyGrid)];
    gridBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *settingsBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    self.navigationItem.leftBarButtonItems = @[infoBarButtonItem, fixedBarButtonItem, gridBarButtonItem];
    
    self.navigationItem.rightBarButtonItems = @[settingsBarButtonItem, fixedBarButtonItem, self.squareSizeBarButtonItem];
    
    [self.photosItem setTarget:self];
    [self.photosItem setAction:@selector(selectPhotoFromAlbum)];
    [self.cameraItem setTarget:self];
    [self.cameraItem setAction:@selector(takePhoto)];
    [self.shareItem setTarget:self];
    [self.shareItem setAction:@selector(shareImage)];
    [self.saveItem setTarget:self];
    [self.saveItem setAction:@selector(saveImage)];
    [self.resetItem setTarget:self];
    [self.resetItem setAction:@selector(resetImage)];
    
    //configure carousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.backgroundColor = [UIColor blackColor];
    _carousel.centerItemWhenSelected = YES;
    
    
    self.scrollView.scrollEnabled = YES;
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGFloat scrollViewHeight = screenFrame.size.width * self.sharedModel.image.size.height / self.sharedModel.image.size.width;
    self.scrollView.contentSize = CGSizeMake(screenFrame.size.width, scrollViewHeight);
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    CGImageRef newCgIm = CGImageCreateCopy(self.sharedModel.originalImage.CGImage);
    self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                 scale:self.sharedModel.originalImage.scale
                                           orientation:self.sharedModel.originalImage.imageOrientation];
    CGImageRelease(newCgIm);
    
    [self divideOriginalImage];
    [self divideProcessedImage];
    [self addGestureRecognizersToSubviews];
    
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    self.sharedModel.selectedSubImageView = self.scrollView.subviews[1];
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.carousel reloadData];
    });
}

-(void)onSquareSizeButtonTapped:(UIBarButtonItem *)sender
                          event:(UIEvent *)event
{
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuWidth = 70.0;
    configuration.menuRowHeight = 60.0;
    configuration.textColor = [UIColor whiteColor];
    configuration.textFont = [UIFont systemFontOfSize:15.0 weight:UIFontWeightUltraLight];
    configuration.textAlignment = NSTextAlignmentCenter;
    configuration.allowRoundedArrow = YES;
    configuration.separatorColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor blackColor];
    
    NSArray *squareSizeArray = @[@"XS", @"S", @"M", @"L"];
    [FTPopOverMenu showFromEvent:event withMenuArray:squareSizeArray imageArray:nil configuration:configuration doneBlock:^(NSInteger selectedIndex) {
        [self squareSizeChanged:selectedIndex];
        self.squareSizeBarButtonItem.title = squareSizeArray[selectedIndex];
    } dismissBlock:nil];
}

- (void)applyRandomFilters:(id)sender{
    if (self.sharedModel.filterNamesChosen.count > 0)
    {
        InstagramActivityIndicator *indicator = [[InstagramActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        indicator.lineWidth = 3;
        indicator.strokeColor = [UIColor whiteColor];
        indicator.numSegments = 15;
        indicator.rotationDuration = 10;
        indicator.animationDuration = 1.0;
        [self.view addSubview:indicator];
        [indicator startAnimating];
        self.navigationItem.titleView = indicator;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *subview in self.scrollView.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    if (arc4random() % 20 < 7)
                    {
                        UIImageView *subImageView = (UIImageView *)subview;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            subImageView.image = [self.sharedModel processImage:subImageView.image
                                                                 withFilterName:[self.sharedModel.filterNamesChosen objectAtIndex:(arc4random() % self.sharedModel.filterNamesChosen.count)]];
                            [self.sharedModel.subImages setObject:subImageView.image forKey:[NSNumber numberWithInteger:subImageView.tag]];
                        });

                    }
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.navigationItem.titleView = [self buttonForTitleView];
            });
        });
    }
    else
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"No  effects  selected" andMessage:@"Add some effects into the list from the effects palette"];
        
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

- (UIButton *)buttonForTitleView
{
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self
               action:@selector(applyRandomFilters:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"random" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

- (void)divideOriginalImage
{
    self.sharedModel.originalSubImages = [self.scrollView addImage:self.sharedModel.originalImage
                                                    withSquareSize:self.sharedModel.squareSize];
}

- (void)divideProcessedImage
{
    self.sharedModel.subImages = [self.scrollView addImage:self.sharedModel.image
                                            withSquareSize:self.sharedModel.squareSize];
}

- (void)addGestureRecognizersToSubviews
{
    for (UIView *subveiw in self.scrollView.subviews)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        [subveiw addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(doubletapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [subveiw addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPressAction:)];
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 0.5;
        [subveiw addGestureRecognizer:longPress];
    }
}


- (void)putBorderWithWidth:(float)borderWidth
{
    for (UIView *subview in self.scrollView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *subImageView = (UIImageView *)subview;
            subImageView.image = [subImageView.image imageWithBorder:borderWidth];
            [self.sharedModel.subImages setObject:subImageView.image
                                           forKey:[NSNumber numberWithInteger:subImageView.tag]];
        }
    }
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];

    self.sharedModel.selectedSubImageView = (UIImageView *)gesture.view;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (void)doubletapAction:(UITapGestureRecognizer*)gesture
{
    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];

    UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
    
    UIImage *originalSubImage = [self.sharedModel.originalSubImages objectForKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    [touchedSubImageView setImage:originalSubImage];
    
    [self.sharedModel.subImages setObject:originalSubImage forKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    self.sharedModel.selectedSubImageView = touchedSubImageView;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (void)longPressAction:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint previousPoint = self.sharedModel.selectedSubImageView.frame.origin;
        UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
        CGPoint currentPoint = touchedSubImageView.frame.origin;
        
        if (previousPoint.x == currentPoint.x)
        {
            for (UIImageView *imageView in self.sharedModel.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.x == currentPoint.x)
                    {
                        if((imageView.frame.origin.y >= previousPoint.y && imageView.frame.origin.y <= currentPoint.y) || (imageView.frame.origin.y <= previousPoint.y && imageView.frame.origin.y >= currentPoint.y))
                        {
                            imageView.image = [self.sharedModel processImage:imageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
                            [self.sharedModel.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
        
        if (previousPoint.y == currentPoint.y)
        {
            for (UIImageView *imageView in self.sharedModel.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.y == currentPoint.y)
                    {
                        if((imageView.frame.origin.x >= previousPoint.x && imageView.frame.origin.x <= currentPoint.x) || (imageView.frame.origin.x <= previousPoint.x && imageView.frame.origin.x >= currentPoint.x))
                        {
                            imageView.image = [self.sharedModel processImage:imageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
                            [self.sharedModel.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
    }
    

    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];
    
    self.sharedModel.selectedSubImageView = (UIImageView *)gesture.view;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}




#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return self.sharedModel.filterNamesChosen.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //NSLog(@"filter index %lu", (unsigned long)index);
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.height - 5, carousel.frame.size.height - 5)];
        view.contentMode = UIViewContentModeCenter;
    }
    
    if (self.sharedModel.selectedSubImageView.image)
    {
        UIImage *outputImage = [self.sharedModel processImage:[self.sharedModel.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[self.sharedModel.filterNamesChosen objectAtIndex:index]];
        
        ((UIImageView *)view).image = outputImage;
        
        if (index == self.selectedIndex)
        {
            [view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [view.layer setBorderWidth: WHITE_BORDER_WIDTH];
        }
        else
        {
            [view.layer setBorderWidth:0.0];
        }
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    //NSLog(@"carousel item selected %ld", (long)index);
    
    self.selectedIndex = index;
    
    self.sharedModel.filterNameSelectedCI = [self.sharedModel.filterNamesChosen objectAtIndex:index];

    self.sharedModel.selectedSubImageView.image = [self.sharedModel processImage:self.sharedModel.selectedSubImageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
    [self.sharedModel.subImages setObject:self.sharedModel.selectedSubImageView.image forKey:[NSNumber numberWithInteger:self.sharedModel.selectedSubImageView.tag]];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.06f;
    }
    return value;
}

- (void)selectPhotoFromAlbum
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

- (void)takePhoto
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
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Info"
                                                         andMessage:@"Camera not available"];
        
        [alertView addButtonWithTitle:@"OK"
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
        
        image = [image fixOrientation];
        
        self.sharedModel.largestSquareSize = image.size.width * image.scale / 2.0;
        
        self.sharedModel.originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                     scale:image.scale
                                               orientation:image.imageOrientation];
        CGImageRelease(newCgIm);
        
        [photoPicker dismissViewControllerAnimated:YES completion:nil];
        
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        CGFloat scrollViewHeight = screenFrame.size.width * self.sharedModel.image.size.height / self.sharedModel.image.size.width;
        self.scrollView.contentSize = CGSizeMake(screenFrame.size.width, scrollViewHeight);
        
        [self divideOriginalImage];
        [self divideProcessedImage];
        [self addGestureRecognizersToSubviews];
        
        self.sharedModel.selectedSubImageView = self.scrollView.subviews[1];
        [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
        
        [self.carousel reloadData];
    }
    else
    {
        //user chose cancel
    }
}

- (void)saveImage
{
    
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
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"error"
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

- (void)resetImage
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef newCgIm = CGImageCreateCopy(self.sharedModel.originalImage.CGImage);
        self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                     scale:self.sharedModel.originalImage.scale
                                               orientation:self.sharedModel.originalImage.imageOrientation];
        CGImageRelease(newCgIm);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self divideProcessedImage];
            [self addGestureRecognizersToSubviews];
            
            self.sharedModel.selectedSubImageView = self.scrollView.subviews[1];
            
            [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
            
            [self.carousel reloadData];
        });
    });
}

- (void)shareImage
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

- (void)toggleHelp
{
    if (self.introView) {
        [self.introView removeFromSuperview];
        self.introView = nil;
        return;
    }
    
    EAIntroPage *page1 = [EAIntroPage customPage];
    page1.title = @"photo";
    page1.desc = @"Pick or take a photo. Then tap anywhere and apply an effect using the list in the bottom. You can always play around with the default image before choosing your own.";
    
    EAIntroPage *page2 = [EAIntroPage customPage];
    page2.title = @"random";
    page2.desc = @"Using the random button, you can apply effects to all the squares randomly. Only the effects included in the list are used.";
    
    EAIntroPage *page3 = [EAIntroPage customPage];
    page3.title = @"restore";
    page3.desc = @"If you need to undo the applied effects for a particular square, just double tap on that square. If you need to start over with the original photo, tap on the restore button.";
    
    EAIntroPage *page4 = [EAIntroPage customPage];
    page4.title = @"stripes";
    page4.desc = @"You can apply effects to horizontal or vertical stripes. Tap on a square, and then long-press on another square that is on the same vertical or horizontal line.";
    
    EAIntroPage *page5 = [EAIntroPage customPage];
    page5.title = @"configure";
    page5.desc = @"Using the configure menu, you can add or remove effects from the list.";
    
    self.introView = [[EAIntroView alloc] initWithFrame:self.view.bounds
                                               andPages:@[page1, page2, page3, page4, page5]];
    self.introView.pageControl.pageIndicatorTintColor = [UIColor darkTextColor];
    self.introView.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    [self.introView.skipButton setTitleColor:[UIColor grayColor]
                               forState:UIControlStateNormal];
    self.introView.delegate = self;
    [self.introView showInView:self.view
               animateDuration:0.2];
}

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped
{
    [self.introView removeFromSuperview];
    self.introView = nil;
}

- (void)squareSizeChanged:(NSUInteger)index {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sharedModel generateImageFromSubimages];
        [self.sharedModel setSquareSizeType:index];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self divideOriginalImage];
            [self divideProcessedImage];
            [self addGestureRecognizersToSubviews];
            
            self.sharedModel.selectedSubImageView = self.scrollView.subviews[1];
            [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
        });
    });
}
- (void)applyGrid
{
    [self putBorderWithWidth:BLACK_BORDER_WIDTH];
}

@end
