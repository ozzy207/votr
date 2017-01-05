//
//  Branding.m
//
//  Created by Edward Kim on 4/23/16.
//  Copyright © 2016 DEDStop, LLC All rights reserved.
//

#import "Branding.h"

@implementation Branding


#pragma mark - Life Cycle
+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static Branding *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance  intitialize];
    });
    return sharedInstance;
}

-(void)intitialize
{
    [[UINavigationBar appearance] setBarTintColor:[self color:@"A"]];
    [[UINavigationBar appearance] setTintColor:[self color:@"B"]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[self color:@"A"]}];
    
//    [[UITabBar appearance] setBarTintColor:[self color:@"A"]];
//    [[UITabBar appearance] setTintColor:[self color:@"B"]];
//    [UITabBar appearance] setTintColor:[UIColor grayColor]]; // for unselected items that are gray
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]];
}

#pragma mark - Color
- (UIColor*)color:(NSString*)code
{
    if (code == nil) {
        return [UIColor clearColor];
    }
    if (code.length == 0) {
        return [UIColor clearColor];
    }
    
    NSDictionary *dict = [self brandedDict][@"Color"];
    NSString *hex = dict[[code uppercaseString]];
    return [self colorFromHex:hex];
}

#pragma mark - Font
- (UIFont*)font:(NSInteger)code weight:(NSInteger)weightCode
{
    if (code == NSNotFound || weightCode == NSNotFound) {
        return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    if (code <= 0 || weightCode < 0) {
        return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    NSDictionary *dict = [self brandedDict][@"Font"];
    NSString *codeString = [NSString stringWithFormat:@"%ld",(long)code];
    return [UIFont systemFontOfSize:[dict[codeString] floatValue] weight:[self weight:weightCode]];
}

- (CGFloat)weight:(NSInteger)weightCode
{
    switch (weightCode) {
        case 0:
            return UIFontWeightUltraLight;
        case 1:
            return UIFontWeightThin;
        case 2:
            return UIFontWeightLight;
        case 3:
            return UIFontWeightRegular;
        case 4:
            return UIFontWeightMedium;
        case 5:
            return UIFontWeightSemibold;
        case 6:
            return UIFontWeightBold;
        case 7:
            return UIFontWeightHeavy;
        case 8:
            return UIFontWeightBlack;
        default:
            return UIFontWeightRegular;
    }
}

#pragma mark - Hex
- (UIColor*)colorFromHex:(NSString*)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00)>>8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - Branded Dict
- (NSDictionary*)brandedDict
{
    NSBundle *brandBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [brandBundle pathForResource:@"Branding" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

@end
