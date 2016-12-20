//
//  Utils.m
//
//  Created by tmaas510 on 07/04/15.
//  Copyright (c) 2015 tmaas510. All rights reserved.
//

#import "Utils.h"

@implementation Utils

#pragma mark - NSUserDefaults - MT
+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getObjectFromUserDefaultsForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - Image
+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    //Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    //Draw your image
    [image drawInRect:rect];
    
    //Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - NSDate->NSString
//    NSDate *date = [Utils dateFromString:dict[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"];
//format: @"dd-MM-yyyy",
+ (NSDate*)dateFromString:(NSString*)datestring format:(NSString*)format timezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    if ([timezone isEqualToString:@"Local"]) {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    } else {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timezone]];
    }
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:datestring];
    
    return dateFromString;
}
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format timezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    if ([timezone isEqualToString:@"Local"]) {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    } else {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timezone]];
    }
    
    NSString *stringDate = [dateFormatter stringFromDate:date];
    
    return stringDate;
}

#pragma mark - Other - MT
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString*)generateChatRoom:(NSString*)id1 second:(NSString*)id2{
    NSString *chatroom = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];

    return chatroom;
}

#pragma mark - Customise view - MT
+(void)CustomiseView:(UIView *)view withColor:(UIColor*)color withWidth:(float)width withCorner:(float)corner{
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
    view.layer.cornerRadius = corner;
    view.layer.masksToBounds = YES;
}

+(void)WhiteEdgeButton:(UIView *)view{
    view.layer.borderColor = [[UIColor whiteColor] CGColor];
    view.layer.borderWidth = 2;
    view.layer.cornerRadius = 2;
    view.layer.masksToBounds = YES;
}

+(void)CustomiseViewWithoutBorder:(UIView *)view{
    view.layer.cornerRadius = 6;
    view.layer.masksToBounds = YES;
}

+(void)addBottomView:(UIView *)view withText:(NSString*)string withSuperView:(UIView*)supeview{
    view = [[UIView alloc]init];
    [view setBackgroundColor:[UIColor blueColor]];
    view.frame = CGRectMake(0, supeview.superview.bounds.size.height - 44, supeview.bounds.size.width, 44);
    [supeview addSubview:view];
    
    UILabel *tle = [[UILabel alloc]initWithFrame:CGRectMake(0,0, view.frame.size.width, 44)];
    tle.text = string;
    tle.textColor = [UIColor whiteColor];
    tle.textAlignment = NSTextAlignmentCenter;
    [tle setFont:[UIFont boldSystemFontOfSize:21]];
    [tle setBackgroundColor:[UIColor clearColor]];
    tle.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    tle.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    tle.layer.shadowOpacity = 1.0f;
    tle.layer.shadowRadius = 1.0f;
    [view addSubview:tle];
}

+(void)addAttributeStr:(UILabel*)label withFirStr:(NSString*)fir secStr:(NSString*)sec {
    NSString *text = [NSString stringWithFormat:@"%@%@", fir, sec];
    NSDictionary *attribs = @{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:label.font};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:text attributes:attribs];
    UIFont *generalFont = [UIFont systemFontOfSize:16];
    NSRange first = [text rangeOfString:fir];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:generalFont} range:first];
    NSRange second = [text rangeOfString:sec];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:16];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:boldFont} range:second];
    label.attributedText = attributedText;
}

+(void)addAttributeStr2:(UILabel*)label withFirStr:(NSString*)fir secStr:(NSString*)sec {
    NSString *text = [NSString stringWithFormat:@"%@%@", fir, sec];
    NSDictionary *attribs = @{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:label.font};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:text attributes:attribs];
    UIFont *generalFont = [UIFont systemFontOfSize:14];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
    NSRange first = [text rangeOfString:fir];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:boldFont} range:first];
    NSRange second = [text rangeOfString:sec];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:label.textColor, NSFontAttributeName:generalFont} range:second];
    label.attributedText = attributedText;
}

// calculate time
+ (NSString *)calculateTime:(NSDate *)end {
    NSString *result;
    
    NSDate *now = [NSDate date];
    NSLog(@"now = %@", now);
    NSLog(@"end = %@", end);
    
    NSTimeInterval tDur = [end timeIntervalSinceDate:now];
    NSLog(@"duration = %f", tDur);
    NSString *dd, *hh, *mm;
    
    mm = [NSString stringWithFormat:@"%dm",(int)(((NSUInteger)tDur % 3600) / 60)]; // ((tDur / 60) % 60)
    hh = [NSString stringWithFormat:@"%dh",(int)(((NSUInteger)tDur % 86400) / 3600)];
    dd = [NSString stringWithFormat:@"%dd",(int)(tDur/86400)];
    
    if(tDur < 3600){
        result = [NSString stringWithFormat:@"Poll ends in %@", mm];
    }else if(tDur < 86400){
        result = [NSString stringWithFormat:@"Poll ends in %@ %@", hh, mm];
    }else{
        result = [NSString stringWithFormat:@"Poll ends in %@ %@ %@", dd, hh, mm];
    }
    
    return result;
}

+ (BOOL)calculateTimeInterval:(NSDate *)end {
    
    NSDate *now = [NSDate date];
    NSLog(@"now = %@", now);
    NSLog(@"end = %@", end);
    
    NSTimeInterval tDur = [end timeIntervalSinceDate:now];
    NSLog(@"duration = %f", tDur);
    NSString *dd, *hh, *mm;
    
    mm = [NSString stringWithFormat:@"%dm",(int)(((NSUInteger)tDur % 3600) / 60)]; // ((tDur / 60) % 60)
    hh = [NSString stringWithFormat:@"%dh",(int)(((NSUInteger)tDur % 86400) / 3600)];
    dd = [NSString stringWithFormat:@"%dd",(int)(tDur/86400)];
    
    if(tDur > 86400){
        return NO;
    }else{
        return YES;
    }
    
    
}

#pragma mark - UIAlertView - MT
+(void)createAlert:(NSString *)title withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//    [alertController addAction:ok];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
}

+(NSString*)getNickname:(NSString*)name {
    return [NSString stringWithFormat:@"@%@", name];
}

@end

@implementation NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring{
    NSRange range = [self rangeOfString:substring];
    BOOL found = (range.location != NSNotFound);
    return found;
}

@end
