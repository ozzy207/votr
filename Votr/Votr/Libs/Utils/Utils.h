//
//  Utils.h
//
//  Created by tmaas510 on 07/04/15.
//  Copyright (c) 2015 tmaas510. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key;
+ (id)getObjectFromUserDefaultsForKey:(NSString *)key;
    
+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;
+ (NSString*)generateChatRoom:(NSString*)id1 second:(NSString*)id2;

+ (NSDate*)dateFromString:(NSString*)datestring format:(NSString*)format timezone:(NSString *)timezone;
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format timezone:(NSString *)timezone;

+(void)CustomiseView:(UIView *)view withColor:(UIColor*)color withWidth:(float)width withCorner:(float)corner;
+(void)WhiteEdgeButton:(UIView *)view;
+(void)CustomiseViewWithoutBorder:(UIView *)view;
+(void)addBottomView:(UIView *)view withText:(NSString*)string withSuperView:(UIView*)supeview;
+(void)createAlert:(NSString *)title withMessage:(NSString*)message;
+(void)addAttributeStr:(UILabel*)label withFirStr:(NSString*)fir secStr:(NSString*)sec;
+(void)addAttributeStr2:(UILabel*)label withFirStr:(NSString*)fir secStr:(NSString*)sec;

+(NSString*)getNickname:(NSString*)name;
+ (NSString *)calculateTime:(NSDate *)end;
+ (BOOL)calculateTimeInterval:(NSDate *)end;

@end


@interface NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring;
@end
