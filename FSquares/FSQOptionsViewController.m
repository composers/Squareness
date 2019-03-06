//
//  FSQOptionsViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQOptionsViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "CarouselViewController.h"
#import "TNCheckBoxGroup.h"

@implementation FSQOptionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createChooseFiltersCheckbox];
}

- (void)createChooseFiltersCheckbox{

    NSMutableArray *filtersData = [[NSMutableArray alloc] initWithCapacity:self.sharedModel.filterNamesUI.count];
    
    for (int i = 0; i < self.sharedModel.filterNamesUI.count; i++)
    {
        TNRectangularCheckBoxData *checkboxData = [[TNRectangularCheckBoxData alloc] init];
        checkboxData.identifier = [self.sharedModel.filterNamesCI objectAtIndex:i];
        checkboxData.labelText = [self.sharedModel.filterNamesUI objectAtIndex:i];
        checkboxData.labelColor = [UIColor blackColor];
        checkboxData.borderColor = [UIColor blackColor];
        checkboxData.rectangleColor = [UIColor blackColor];
        checkboxData.borderWidth = checkboxData.borderHeight = 20;
        checkboxData.rectangleWidth = checkboxData.rectangleHeight = 18;
        
        if([self.sharedModel.filterNamesChosen containsObject:checkboxData.identifier])
        {
            checkboxData.checked = YES;
        }
        else
        {
            checkboxData.checked = NO;
        }
        
        [filtersData addObject:checkboxData];
    }
    
    TNCheckBoxGroup *chooseFiltersCheckbox = [[TNCheckBoxGroup alloc] initWithCheckBoxData:filtersData style:TNCheckBoxLayoutVertical];
    [chooseFiltersCheckbox create];
    chooseFiltersCheckbox.position = CGPointMake(20, 20);
    [self.chooseFiltersCheckboxContainer addSubview:chooseFiltersCheckbox];
    UIScrollView *scrollView = (UIScrollView *)self.chooseFiltersCheckboxContainer;
    scrollView.contentSize = CGSizeMake(0, chooseFiltersCheckbox.frame.size.height + 20);
    [scrollView.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [scrollView.layer setBorderWidth: 2.0];
    scrollView.layer.cornerRadius = 6.0;
    scrollView.showsVerticalScrollIndicator = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chooseFiltersUpdate:)
                                                 name:GROUP_CHANGED
                                               object:chooseFiltersCheckbox];
}


- (void)chooseFiltersUpdate:(NSNotification *)notification {
    
    [self.sharedModel.filterNamesChosen removeAllObjects];
    TNCheckBoxGroup *chooseFiltersCheckbox = notification.object;
    
    for (TNRectangularCheckBoxData *checkboxData in chooseFiltersCheckbox.checkedCheckBoxes)
    {
        [self.sharedModel.filterNamesChosen addObject:checkboxData.identifier];
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];

    [carouselController.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [carouselController.carousel reloadData];
    //    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
