//
//  NSString+ContainsString.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/13/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (COntainsString)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;

@end
