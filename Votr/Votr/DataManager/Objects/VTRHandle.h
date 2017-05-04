//
//  VTRHandle.h
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRHandle : BaseDataObject
@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (nonatomic) FIRDatabaseHandle handle;
+ (instancetype)handle:(FIRDatabaseHandle)handle withRef:(FIRDatabaseReference*)ref;
@end
