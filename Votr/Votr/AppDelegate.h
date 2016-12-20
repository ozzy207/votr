//
//  AppDelegate.h
//  Votr
//
//  Created by Thomas Maas on 12/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

