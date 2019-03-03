//
//  EAIntroPage+customPage.m
//  Squareness
//
//  Created by Stefan Stolevski on 3/3/19.
//  Copyright © 2019 Stefan Stolevski. All rights reserved.
//

#import "EAIntroPage+customPage.h"

@implementation EAIntroPage (customPage)
+ (EAIntroPage *)customPage {
    EAIntroPage *page = [EAIntroPage page];
    page.showTitleView = NO;
    page.titlePositionY = [UIScreen mainScreen].bounds.size.height/2.0;
    page.descPositionY = [UIScreen mainScreen].bounds.size.height/2.0;
    page.titleFont = [UIFont systemFontOfSize:36.0 weight:UIFontWeightUltraLight];
    page.descFont = [UIFont systemFontOfSize:15.0 weight:UIFontWeightUltraLight];
    page.titleColor = [UIColor darkTextColor];
    page.descColor = [UIColor darkTextColor];
    page.bgColor = [UIColor colorWithWhite:1.0 alpha:0.91];
    return page;
}
@end
